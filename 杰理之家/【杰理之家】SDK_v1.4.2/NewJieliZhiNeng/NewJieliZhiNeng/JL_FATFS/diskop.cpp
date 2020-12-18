#include "diskop.h"
#include "ff.h"
#include <algorithm>
#include <cassert>
#include <set>

//#define DEBUG 0
#define LOCAL_TEST 0

//#if DEBUG
//#include <QDebug>
//#endif

#define FLASH_ERASE_SIZE 4096U
#define CACHE_UNIT_SIZE 512U
#define BITS_SIZE 8U
#define READ_UNIT_SIZE 512U // read block size
#define BPB_SIZE 4096U
#define BACKUP_AREA_SIZE 8192U

#define BACKUP_AREA_START (BPB_SIZE)
#define FAT_AREA_START (BACKUP_AREA_START + BACKUP_AREA_SIZE)

/*
 * +--------+
 * |  BPB   |
 * +--------+
 * | backup |
 * +--------+
 * | backup |
 * +--------+
 * |  FAT   |
 * +--------+
 * |  ROOT  |
 * +--------+
 * |CLUSTER |
 * +--------+
 */

struct OffBit
{
    uint32_t off;
    uint32_t bit;
};

static inline struct OffBit mapToFlagPosition(uint32_t addr)
{
    uint32_t off = addr / CACHE_UNIT_SIZE / BITS_SIZE;
    uint32_t bit = addr / CACHE_UNIT_SIZE % BITS_SIZE;
    return {off, bit};
}

class DiskOpImpl
{
    std::unique_ptr<uint8_t[]> m_cache;
    std::unique_ptr<uint8_t[]> m_backupCache;
    std::unique_ptr<uint8_t[]> m_syncFlags;
    std::unique_ptr<uint8_t[]> m_backupSyncFlags;
    std::set<uint32_t> m_dirtyBlocks;
    std::set<uint32_t> m_flashEraseAddrs;
    std::vector<uint32_t> m_pendingWrites;
    uint32_t m_imageSize;
    std::shared_ptr<IoOperation> m_io;

public:
    DiskOpImpl(uint32_t imageSize, std::shared_ptr<IoOperation> &io) : m_io(io)
    {
        imageSize += BPB_SIZE; // add bpb size
        imageSize         = ((imageSize + CACHE_UNIT_SIZE - 1) / CACHE_UNIT_SIZE) * CACHE_UNIT_SIZE;
        unsigned flagSize = imageSize / CACHE_UNIT_SIZE / BITS_SIZE;
        m_cache.reset(new uint8_t[imageSize]);
        m_backupCache.reset(new uint8_t[imageSize]);
        m_syncFlags.reset(new uint8_t[flagSize]);
        m_backupSyncFlags.reset(new uint8_t[flagSize]);

        memset(m_cache.get(), 0, imageSize);
        memset(m_backupCache.get(), 0, imageSize);
        memset(m_syncFlags.get(), 0, flagSize);
        memset(m_backupSyncFlags.get(), 0, flagSize);

        m_imageSize = imageSize;
    }

    bool ensure_sync(uint32_t offset, uint32_t size)
    {
        // first, if not synced, sync with remote
        uint32_t aligned_addr     = offset / CACHE_UNIT_SIZE * CACHE_UNIT_SIZE;
        uint32_t aligned_end_addr = (offset + size + CACHE_UNIT_SIZE - 1) / CACHE_UNIT_SIZE
                                    * CACHE_UNIT_SIZE;
        auto flag = m_syncFlags.get();
        for (uint32_t addr = aligned_addr; addr < aligned_end_addr; addr += CACHE_UNIT_SIZE) {
            if (addr >= m_imageSize || (addr + size > m_imageSize)) {
                // out-of-range error
                return false;
            }
            auto offbit = mapToFlagPosition(addr);
            assert(offbit.off < (m_imageSize / CACHE_UNIT_SIZE / BITS_SIZE) && "internal error");
            if (flag[offbit.off] & (1u << offbit.bit)) {
                // already synced
                continue;
            }
            // otherwise, we should read from remote
            // divide into READ_UNIT_SIZE
            for (uint32_t k = 0; k < CACHE_UNIT_SIZE / READ_UNIT_SIZE; ++k) {
                uint32_t adr = addr + k * READ_UNIT_SIZE;
                if (!m_io->read(m_cache.get() + adr, adr, READ_UNIT_SIZE)) {
                    return false;
                }
            }

            // then update sync bit
            flag[offbit.off] |= (1u << offbit.bit);
        }
        return true;
    }

    bool backup()
    {
        if (!ensure_sync(FAT_AREA_START, BACKUP_AREA_SIZE)) {
            return false;
        }
        return write(m_cache.get() + FAT_AREA_START, BACKUP_AREA_START, BACKUP_AREA_SIZE);
    }

    bool recovery()
    {
        // copy fat and root system
        if (!ensure_sync(BACKUP_AREA_START, BACKUP_AREA_SIZE)) {
            return false;
        }
        // and we should write to fat and root dir
        return write(m_cache.get() + BACKUP_AREA_START, FAT_AREA_START, BACKUP_AREA_SIZE);
    }

    bool read(void *buf, uint32_t offset, uint32_t size)
    {
        // for each block, check if synced
        // which bit?
        if (!ensure_sync(offset, size)) {
            return false;
        }
        // we already sync all with remote, we should just copy from cache
        if (offset >= m_imageSize || (offset + size) > m_imageSize) {
            // out-of-range
            return false;
        }

        memcpy(buf, m_cache.get() + offset, size);
        return true;
    }

    bool write(const void *buf, uint32_t offset, uint32_t size)
    {
        uint32_t aligned_addr     = offset / CACHE_UNIT_SIZE * CACHE_UNIT_SIZE;
        uint32_t aligned_end_addr = (offset + size + CACHE_UNIT_SIZE - 1) / CACHE_UNIT_SIZE
                                    * CACHE_UNIT_SIZE;

        // 0. ensure we aligned
        if (aligned_addr != offset) {
            // we should read first block
            if (!ensure_sync(aligned_addr, CACHE_UNIT_SIZE)) {
                return false;
            }
        }
        if ((aligned_end_addr != offset + size)
            && (aligned_end_addr - aligned_addr > CACHE_UNIT_SIZE)) {
            // we should read tailing block
            if (!ensure_sync(aligned_end_addr - CACHE_UNIT_SIZE, CACHE_UNIT_SIZE)) {
                return false;
            }
        }
        if (offset >= m_imageSize || (offset + size) > m_imageSize) {
            // out-of-range
            return false;
        }

        // 1. copy to cache
        memcpy(m_cache.get() + offset, buf, size);

        // 2. update sync bit
        auto flag = m_syncFlags.get();
        for (uint32_t addr = aligned_addr; addr < aligned_end_addr; addr += CACHE_UNIT_SIZE) {
            auto offbit = mapToFlagPosition(addr);
            assert(offbit.off < (m_imageSize / CACHE_UNIT_SIZE / BITS_SIZE) && "internal error");
            flag[offbit.off] |= (1u << offbit.bit);
            m_dirtyBlocks.insert(addr);
        }

        return true;
    }

    bool beginTranscation()
    {
        if (!m_dirtyBlocks.empty()) {
            return false;
        }
        // backup cache and sync flags;
        memcpy(m_backupCache.get(), m_cache.get(), m_imageSize);
        memcpy(m_backupSyncFlags.get(), m_syncFlags.get(),
               m_imageSize / CACHE_UNIT_SIZE / BITS_SIZE);
        return true;
    }

    bool cancelTranscation()
    {
        m_dirtyBlocks.clear();
        m_flashEraseAddrs.clear();
        m_pendingWrites.clear();
        memcpy(m_cache.get(), m_backupCache.get(), m_imageSize);
        memcpy(m_syncFlags.get(), m_backupSyncFlags.get(),
               m_imageSize / CACHE_UNIT_SIZE / BITS_SIZE);
        return true;
    }

    bool contWrites()
    {
        if (m_pendingWrites.empty()) {
            m_dirtyBlocks.clear();
            return true;
        }
        // write backward
        while (!m_pendingWrites.empty()) {
            uint32_t addr = m_pendingWrites.back();
            if (!m_io->write(m_cache.get() + addr, addr, FLASH_ERASE_SIZE)) {
                return false;
            }
            m_pendingWrites.pop_back();
        }
        m_dirtyBlocks.clear();

        return true;
    }

    unsigned getOpCounts() { return m_dirtyBlocks.size(); }

    bool syncReads()
    {
        m_flashEraseAddrs.clear();
        for (auto off : m_dirtyBlocks) {
            if (memcmp(m_cache.get() + off, m_backupCache.get() + off, CACHE_UNIT_SIZE) != 0) {
            } else {
                // or, not sync with remote
                auto offbit = mapToFlagPosition(off);
                auto flag   = m_backupSyncFlags.get();
                if ((flag[offbit.off] & (1u << offbit.bit)) == 0) {
                } else {
//#if DEBUG
//                    qDebug() << "not changed: " << off;
//#endif
                    continue; // skip unchanged
                }
            }
            // we need to earse offset, we should ensure we already sync flash erase block with remote
            uint32_t erase_addr = off / FLASH_ERASE_SIZE * FLASH_ERASE_SIZE;
            if (!ensure_sync(erase_addr, FLASH_ERASE_SIZE)) {
                return false;
            }
            m_flashEraseAddrs.insert(erase_addr);
        }
        return true;
    }

    bool endTranscation()
    {
        if (m_dirtyBlocks.empty()) {
            m_pendingWrites.clear();
            return true;
        }
        m_pendingWrites.clear();
        m_pendingWrites.insert(m_pendingWrites.end(), m_flashEraseAddrs.begin(),
                               m_flashEraseAddrs.end());

        std::sort(m_pendingWrites.begin(), m_pendingWrites.end(),
                  [](uint32_t a, uint32_t b) { return a < b; });

        return contWrites();
    }

    std::vector<WriteParams> getUnfinishedWrites()
    {
        std::vector<WriteParams> params;
        for (auto p : m_pendingWrites) {
            params.emplace_back(p, FLASH_ERASE_SIZE, m_cache.get() + p);
        }
        return params;
    }

    bool doUpdateBegin()
    {
#if !LOCAL_TEST
        if (!beginTranscation()) {
            return false;
        }
        if (!backup() || !syncReads() || !endTranscation()) {
            cancelTranscation();
            return false;
        }
#endif

        if (!beginTranscation()) {
            return false;
        }
        return true;
    }

    bool doUpdateEnd()
    {
        if (!syncReads() || !m_io->writeFlag(false) || !endTranscation()) {
            cancelTranscation();
            return false;
        }

        if (!m_io->writeFlag(true)) {
            return false;
        }

        return true;
    }

    bool init()
    {
#if !LOCAL_TEST
        bool isSuccessed;
        if (!m_io->readFlag(isSuccessed)) {
            return false;
        }
        if (isSuccessed) {
            // nothing to be done
            return true;
        }
        // we should do recovery
        if (!beginTranscation()) {
            return false;
        }
        if (!recovery() || !syncReads() || !endTranscation()) {
            cancelTranscation();
            return false;
        }

        if (!m_io->writeFlag(true)) {
            return false;
        }
#endif

        return true;
    }

    bool deleteFile(const char *filepath)
    {
        if (!doUpdateBegin()) {
            return false;
        }

        // backup sccuessed
        FRESULT ret = f_unlink(filepath);
        if (ret != FR_OK) {
            cancelTranscation();
            return false;
        }

        return doUpdateEnd();
    }

    bool insertFile(const char *filepath, const void *content, size_t length)
    {
        if (!doUpdateBegin()) {
            return false;
        }

        FIL fil;
        FRESULT ret = f_open(&fil, filepath, FA_WRITE | FA_CREATE_NEW);
        if (ret != FR_OK) {
            cancelTranscation();
            return false;
        }

        UINT writes;
        ret = f_write(&fil, content, length, &writes);
        if (ret != FR_OK || writes != length) {
            cancelTranscation();
            return false;
        }

        ret = f_close(&fil);
        if (ret != FR_OK) {
            cancelTranscation();
            return false;
        }

        return doUpdateEnd();
    }
};

//--- DiskOp

DiskOp::DiskOp(unsigned imageSize, std::shared_ptr<IoOperation> ioOperation)
    : m_impl(new DiskOpImpl(imageSize, ioOperation))
{}

DiskOp::~DiskOp() {}

bool DiskOp::backup()
{
    return m_impl->backup();
}

bool DiskOp::recovery()
{
    return m_impl->recovery();
}

bool DiskOp::read(void *buf, uint32_t offset, uint32_t size)
{
    return m_impl->read(buf, offset, size);
}

bool DiskOp::write(const void *buf, uint32_t offset, uint32_t size)
{
    return m_impl->write(buf, offset, size);
}

bool DiskOp::begin()
{
    return m_impl->beginTranscation();
}

bool DiskOp::sync()
{
    return m_impl->syncReads();
}

bool DiskOp::end()
{
    return m_impl->endTranscation();
}

bool DiskOp::cont()
{
    return m_impl->contWrites();
}

bool DiskOp::abort()
{
    return m_impl->cancelTranscation();
}

unsigned DiskOp::opCounts()
{
    return m_impl->getOpCounts();
}

bool DiskOp::init()
{
    return m_impl->init();
}

bool DiskOp::deleteFile(const char *filepath)
{
    return m_impl->deleteFile(filepath);
}

bool DiskOp::insertFile(const char *filepath, const void *content, size_t length)
{
    return m_impl->insertFile(filepath, content, length);
}

std::vector<WriteParams> DiskOp::unfinishedWrites()
{
    return m_impl->getUnfinishedWrites();
}

WriteParams::WriteParams(unsigned offset, unsigned size, uint8_t *ptr)
    : m_offset(offset), m_size(size)
{
    m_buf = std::shared_ptr<uint8_t>(new uint8_t[size], [](uint8_t *p) { delete[] p; });
    memcpy(m_buf.get(), ptr, size);
}
