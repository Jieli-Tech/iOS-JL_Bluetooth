#ifndef common_H
#define common_H
#include <cmath>
inline unsigned short CRC16(unsigned char *ptr, int len)
{

    unsigned short crc_ta[16] =
    {
        0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
        0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
    };
    unsigned short crc;
    unsigned char da;

    crc = 0;

    while (len-- != 0)
    {
        da = crc >> 12;
        crc <<= 4;
        crc ^= crc_ta[da ^ (*ptr / 16)];

        da = crc >> 12;

        crc <<= 4;
        crc ^= crc_ta[da ^ (*ptr & 0x0f)];
        ptr++;
    }

    return(crc);

}
class Complex
{
public:
    Complex()
    {
        real = 0;
        imag = 0;
    }
    Complex(double real, double imag)
    {
        this->real = real;
        this->imag = imag;
    }
    Complex(double real)
    {
        this->real = real;
        this->imag = 0;
    }
    void  operator =(Complex x)
    {
        real = x.real;
        imag = x.imag;
    }
    Complex  operator +(Complex x)
    {
        return Complex(real + x.real, imag + x.imag);
    }
    Complex operator -()
    {
        return Complex(-real, -imag);
    }
    Complex  operator -(Complex x)
    {
        return Complex(real - x.real, imag - x.imag);
    }
    Complex  operator *(Complex x)
    {
        return Complex(real * x.real - imag * x.imag, imag * x.real + real * x.imag);
    }
    Complex conj()
    {
        return Complex(real, -imag);
    }
    float mod()
    {
        return real*real + imag*imag;
    }
    float abs()
    {
        return sqrt(mod());
    }
    Complex  operator /(Complex x)
    {
        Complex tmp;
        double mod = x.mod();
        tmp = *this * x.conj();
        tmp.real /= mod;
        tmp.imag /= mod;
        return tmp;
    }
    void operator +=(Complex x)
    {
        *this = *this + x;
    }
    void operator -=(Complex x)
    {
        *this = *this - x;
    }
    void operator *=(Complex x)
    {
        *this = *this * x;
    }
    void operator /=(Complex x)
    {
        *this = *this / x;
    }
private:
	double real;
	double imag;
};
enum IIR_TYPE
{
    highpass = 0,
    lowpass,
    bandpass,
    highshelf,
    lowshelf,
};
typedef struct
{
    IIR_TYPE type;
    float CenterFrequency;
    float QVaule;
    float Gain;
    bool fEnable;
}SOS_Para;
#endif