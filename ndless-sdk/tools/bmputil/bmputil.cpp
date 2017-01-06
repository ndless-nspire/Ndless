#include <cstdint>
#include <iostream>

#include <QCoreApplication>
#include <QFile>
#include <QStringList>
#include <QImage>

//Everything little endian
#if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
    #error "This header may only be used on little endian machines!"
#endif

struct BMPHeader {
    uint16_t    magic;
    uint32_t    file_size;
    uint32_t    creator;
    uint32_t    bmp_offset;

    uint32_t    hdr_size;
    uint32_t    width;
    int32_t     height;
    uint16_t    nplanes;
    uint16_t    bpp;
    uint32_t    compress_type;
    uint32_t    data_size;
    int32_t     hres;
    int32_t     vres;
    uint32_t    ncolors;
    uint32_t    nimpcolors;
} __attribute__((packed));

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    if(a.arguments().length() != 3)
    {
        std::cerr << "Usage: " << argv[0]  << " <input> <output>" << std::endl
                  << "The direction is automatically chosen." << std::endl;
        return 1;
    }

    QFile input(a.arguments()[1]);
    QByteArray header;
    if(!input.open(QFile::ReadOnly) || (header = input.read(sizeof(BMPHeader))).size() != sizeof(BMPHeader))
    {
        std::cerr << "Couldn't read input file!" << std::endl;
        return 1;
    }

    BMPHeader *input_header = reinterpret_cast<BMPHeader*>(header.data());
    bool is_bmp = input_header->magic == 0x4d42,
         is_v3 = input_header->hdr_size == 40,
         is_v4 = input_header->hdr_size == 52;

    if(is_bmp && ((is_v3 && input_header->compress_type == 65543) || (is_v4 && input_header->compress_type == 0x3)))
    {
        //Is a TI BMP
        if(input_header->height < 0)
            input_header->height = -input_header->height;

        // Quick hack: Just ignore the bytes that make the difference between v4 and v3
        if(is_v4)
            input.read(12);

        QImage output(input_header->width, input_header->height, QImage::Format_ARGB32);
        qint64 size = input_header->width * input_header->height * 2;
        QByteArray rgbdata = input.read(size);
        if(rgbdata.size() != size)
        {
            std::cerr << "Couldn't read input file!" << std::endl;
            return 1;
        }

        QByteArray alphadata;
        if(input_header->compress_type == 65543)
        {
            alphadata = input.read(size / 2);
            if(alphadata.size() != size / 2)
            {
                std::cerr << "Couldn't read input file!" << std::endl;
                return 1;
            }
        }
        else // No alpha
            alphadata = QByteArray(size / 2, 0xFF);

        auto alphaptr = reinterpret_cast<const uint8_t *>(alphadata.data());
        auto rgbptr = reinterpret_cast<const uint16_t *>(rgbdata.data());
        bool flipped = is_v4;

        for(unsigned int line = 0; line < static_cast<unsigned int>(input_header->height); ++line)
        {
            auto outptr = reinterpret_cast<QRgb *>(output.scanLine(flipped ? (input_header->height - 1 - line) : line));
            for(unsigned int x = 0; x < input_header->width; ++x)
            {
                uint16_t rgb565 = *rgbptr++;
                *outptr++ = qRgba(((rgb565 >> 11) & 0b11111) << 3, ((rgb565 >> 5) & 0b111111) << 2, (rgb565 & 0b11111) << 3, *alphaptr++);
            }
        }

        if(!output.save(a.arguments()[2]))
        {
            std::cerr << "Couldn't save to output file!" << std::endl;
            return 1;
        }
    }
    else
    {
        //Is a normal BMP
        QImage input_bmp(a.arguments()[1]);
        if(input_bmp.isNull())
        {
            std::cerr << "Couldn't read input file!" << std::endl;
            return 1;
        }

        //Times three: 2 byte RGB565 + 1 byte alpha
        size_t data_size = input_bmp.width() * input_bmp.height() * 3;

        BMPHeader header;
        header.magic = 0x4D42;
        header.file_size = sizeof(header) + data_size;
        header.creator = 0;
        header.bmp_offset = sizeof(header);
        header.hdr_size = 0x28;
        header.width = input_bmp.width();
        header.height = input_bmp.height();
        header.nplanes = 1;
        header.bpp = 16;
        header.compress_type = 65543;
        header.data_size = data_size;
        header.hres = header.vres = header.ncolors = header.nimpcolors = 0;

        QByteArray buffer(data_size + sizeof(header), 0);
        memcpy(buffer.data(), &header, sizeof(header));
        auto rgbptr = reinterpret_cast<uint16_t *>(buffer.data() + sizeof(header));
        auto alphaptr = reinterpret_cast<uint8_t *>(buffer.data() + sizeof(header) + input_bmp.width() * input_bmp.height() * 2);
        for(unsigned int y = 0; y < static_cast<unsigned int>(header.height); ++y)
        {
            for(unsigned int x = 0; x < header.width; ++x)
            {
                QRgb pixel = input_bmp.pixel(x, y);
                unsigned char r = qRed(pixel) >> 3, g = qGreen(pixel) >> 2, b = qBlue(pixel) >> 3;
                *rgbptr++ = r << 11 | g << 5 | b;
                *alphaptr++ = qAlpha(pixel);
            }
        }

        QFile output(a.arguments()[2]);
        if(!output.open(QFile::WriteOnly) || !output.write(buffer))
        {
            std::cerr << "Couldn't save to output file!" << std::endl;
            return 1;
        }
    }

    return 0;
}
