#ifndef DISKOP_H
#define DISKOP_H

#include <memory>
#include <vector>

class DiskOpImpl;

class IoOperation {
public:
    virtual ~IoOperation() {}
    virtual bool read(void *buf, uint32_t offset, uint32_t size) =0;
    virtual bool write(const void *buf, uint32_t offset, uint32_t size) =0;
    virtual bool writeFlag(bool isSuccessed) =0;
    virtual bool readFlag(bool &flag) =0;
};

class WriteParams {
    unsigned m_offset;
    unsigned m_size;
    std::shared_ptr<uint8_t> m_buf;

public:
    WriteParams(unsigned offset, unsigned size, uint8_t *ptr);

    unsigned offset() const { return m_offset; }
    unsigned size() const { return m_size; }
    uint8_t *buf() const { return m_buf.get(); }
};

class DiskOp {
public:
    DiskOp(unsigned imageSize, std::shared_ptr<IoOperation> ioOperation);

    ~DiskOp();

    bool backup();
    bool recovery();
    bool read(void *buf, uint32_t offset, uint32_t size);
    bool write(const void *buf, uint32_t offset, uint32_t size);

    bool begin();
    bool sync();
    bool end();
    bool cont();
    bool abort();
    unsigned opCounts();

    // helper
    bool init();
    bool deleteFile(const char *filepath);
    bool insertFile(const char *filepath,
                    const void *content,
                    size_t length);

    std::vector<WriteParams> unfinishedWrites();

private:
    std::unique_ptr<DiskOpImpl> m_impl;
};

#endif // DISKOP_H
