#ifndef PACKRESFORMAT_H
#define PACKRESFORMAT_H

#include <string>
#include <vector>

class PackResFormat
{
public:
    struct Info
    {
        std::string name;
        size_t offset;
        size_t len;

        Info(const std::string &name, size_t offset, size_t len)
            : name(name), offset(offset), len(len)
        {}
    };

    PackResFormat();
    ~PackResFormat();

    bool parse(const void *buf, size_t size);

    const std::vector<Info> &infos() const;

    size_t getFileSize(const std::string &name) const;
    size_t getFileContent(const std::string &name, void *buf, size_t bufSize) const;

private:
    std::vector<Info> m_infos;
    const void *m_buf{nullptr};
};

#endif // PACKRESFORMAT_H
