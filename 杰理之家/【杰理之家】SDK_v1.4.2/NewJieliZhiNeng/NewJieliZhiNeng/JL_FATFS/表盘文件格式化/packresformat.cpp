#include "packresformat.h"
#include <algorithm>

namespace {

#ifdef _MSC_VER
#pragma pack(1)
#endif

#ifdef _MSC_VER
#define MY_ALIGN_PACK
#else
#define MY_ALIGN_PACK __attribute__((packed))
#endif

struct MY_ALIGN_PACK JL_WARNING_TONE_CONFIG_DATA
{
    uint16_t headFlag;
    uint16_t u16Crc;
    uint16_t u16Version;
    uint32_t u32Length;
    uint8_t u8Index;
    uint8_t u8NameOffset;
    uint8_t u8NameLength;
    uint8_t u8DataOffset;
    uint32_t u32DataLength;
    char szData[0];
};

struct MY_ALIGN_PACK JL_TONE_INDEX_ITEM
{
    uint16_t u16Crc;
    uint8_t u8Length;
    uint8_t u8Index;
    char szName[1];
};

struct MY_ALIGN_PACK JL_TONE_INDEX_HEAD
{
    uint32_t u32Tag; // 'TIDX'
    uint16_t u16Crc;
    uint16_t u16Res;
    uint32_t u32Res;
    uint32_t u32Count;
};

struct MY_ALIGN_PACK JL_TONE_INDEX
{
    JL_TONE_INDEX_HEAD stHead;
    JL_TONE_INDEX_ITEM stItem[1];
};

struct MY_ALIGN_PACK JL_FILE_HEAD
{
    uint16_t u16Crc;
    uint16_t u16DataCrc;
    uint32_t u32Address;
    uint32_t u32Length;
#define JL_FILE_ATTR_ENC 0x80
#define JL_FILE_ATTR_COMPRESS 0x40
#define JL_FILE_ATTR_RESERVED 0x10

#define JL_FILE_ATTR_UBOOT 0x00
#define JL_FILE_ATTR_APP 0x01
#define JL_FILE_ATTR_REG 0x02
#define JL_FILE_ATTR_DIR 0x03
#define JL_FILE_ATTR_UPDATE 0x04
    //#define JL_FILE_ATTC_SUBDIR   0x05
    uint8_t u8Attribute;
#define JL_RESERVER_FILE_OPTION_ERASE 0x00
#define JL_RESERVER_FILE_OPTION_NULL 0x01
#define JL_RESERVER_FILE_OPTION_PROTECT 0x02
#define JL_RESERVER_FILE_OPTION_ABSOLUTE 0x80
    uint8_t u8Res;
    uint16_t u16Index;
    char szFileName[16];
};

#ifdef _MSC_VER
#pragma pack()
#endif

} // namespace

PackResFormat::PackResFormat() {}

PackResFormat::~PackResFormat() {}

bool PackResFormat::parse(const void *_buf, size_t size)
{
    const uint8_t *buf = (const uint8_t *) _buf;
    m_buf              = buf;
    if (!m_buf) {
        return false;
    }
    if (size < 3 * sizeof(JL_FILE_HEAD)) {
        return false;
    }
    JL_FILE_HEAD *dirHead   = (JL_FILE_HEAD *) buf;
    JL_FILE_HEAD *indexHead = dirHead + 1;
    JL_FILE_HEAD *toneHead  = indexHead + 1;

    JL_TONE_INDEX *toneIndex = (JL_TONE_INDEX *) (buf + indexHead->u32Address);

    JL_TONE_INDEX_ITEM *item = &(toneIndex->stItem[0]);
    for (unsigned i = 0; i < toneIndex->stHead.u32Count; ++i) {
        auto storeName = std::string(item->szName);
        item           = (JL_TONE_INDEX_ITEM *) ((const uint8_t *) item + item->u8Length);
        m_infos.emplace_back(storeName, toneHead->u32Address, toneHead->u32Length);
        ++toneHead;
    }

    return true;
}

const std::vector<PackResFormat::Info> &PackResFormat::infos() const
{
    return m_infos;
}

size_t PackResFormat::getFileSize(const std::string &name) const
{
    auto f = std::find_if(m_infos.begin(), m_infos.end(),
                          [&](const Info &i) { return i.name == name; });
    if (f == m_infos.end()) {
        return 0;
    }
    return f->len;
}

size_t PackResFormat::getFileContent(const std::string &name, void *buf, size_t bufSize) const
{
    if (!m_buf) {
        return 0;
    }
    auto f = std::find_if(m_infos.begin(), m_infos.end(),
                          [&](const Info &i) { return i.name == name; });
    if (f == m_infos.end()) {
        return 0;
    }
    size_t fileSize = f->len;
    size_t readSize = fileSize > bufSize ? bufSize : fileSize;
    memcpy(buf, (const uint8_t *) m_buf + f->offset, readSize);
    return readSize;
}
