#include "EQPlotCore_ac800n.h"
#include <memory.h>

static const float SampleRateTab[9] = {
    44100, 22050, 11025, 48000, 24000, 12000, 32000, 16000, 8000 //
};
int EQPlotCore_ac800n::CheckStability(float *a, int Q)
{
    int aQuan[2];
    for (int i = 0; i < 2; i++)
    {
        aQuan[i] = static_cast<int>(round((1 << CoeffQ) * (-a[i])));
    }
    double a1, a2;
    a1 = static_cast<double>(aQuan[0]) / static_cast<double>(1 << Q);
    a2 = static_cast<double>(aQuan[1]) / static_cast<double>(1 << Q);
    double sqr = a1 * a1 - 4 * a2;
    if (sqr < 0)
    {
        if (a2 > 1)
        {
            return -1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        double root1, root2;
        sqr = sqrt(sqr);
        root1 = (-a1 + sqr) / 2;
        root2 = (-a1 - sqr) / 2;
        if (abs(root1) > 1 || abs(root2) > 1)
        {
            return -1;
        }
        else
        {
            return 0;
        }
    }
}
int EQPlotCore_ac800n::GetBinSize(int nSection)
{
    return nSection * sizeof(SampleRateTab) / sizeof(float) * 5 * sizeof(float) + sizeof(eq_data_ac800n);
}
void EQPlotCore_ac800n::ConvertToBin(float globalgain, int EnableBit, eq_data_ac800n *bin)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(float);
    bin->enable_section = EnableBit;
    bin->global_gain = globalgain;
    bin->magic = EQ_MAGIC;
    bin->sec_num = 0;
    int *pData = bin->data;
    for (int i = 0; i < nSampleRate; i++)
    {
        for (int j = 0; j < m_nEQSection; j++)
        {
            if (EnableBit & (1 << j))
            {
                GetCoeff(pData, j, SampleRateTab[i]);
                pData += 5;
                if (i == 0)
                    bin->sec_num++;
            }
        }
    }
    bin->crc = CRC16(reinterpret_cast<unsigned char *>(&bin->sec_num), sizeof(eq_data_ac800n) - sizeof(int) - sizeof(short) + bin->sec_num * nSampleRate * 5 * sizeof(int));
}

int EQPlotCore_ac800n::SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate)
{ //coeff -> a1 a2 b0 b1/b0 b2/b0
    if (para->CenterFrequency <= 10.f || para->CenterFrequency >= SampleRate / 2 * 0.9f || !para->fEnable)
    {
        memset(coeff, 0, sizeof(float) * 5);
        coeff[2] = 1.f;
        return -1;
    }
    float PI = atan(1.f) * 4;
    float w0 = 2 * PI * para->CenterFrequency / SampleRate;
    float alpha;
    float a0;
    float A;
    switch (para->type)
    {
    case highpass:
        alpha = sin(w0) / (2 * para->QVaule);
        a0 = 1 + alpha;
        coeff[2] = (1 + cos(w0)) / (2 * a0);
        coeff[3] = -(1 + cos(w0)) / a0;
        coeff[4] = (1 + cos(w0)) / (2 * a0);
        coeff[0] = -2 * cos(w0) / a0;
        coeff[1] = (1 - alpha) / a0;
        break;
    case lowpass:
        alpha = sin(w0) / (2 * para->QVaule);
        a0 = 1 + alpha;
        coeff[2] = (1 - cos(w0)) / (2 * a0);
        coeff[3] = (1 - cos(w0)) / a0;
        coeff[4] = (1 - cos(w0)) / (2 * a0);
        coeff[0] = -2 * cos(w0) / a0;
        coeff[1] = (1 - alpha) / a0;
        break;
    case bandpass:
        alpha = sin(w0) / (2 * para->QVaule);
        A = pow(10.f, (para->Gain / 40));
        a0 = 1 + alpha / A;
        coeff[2] = (1 + alpha * A) / a0;
        coeff[3] = (-2 * cos(w0)) / a0;
        coeff[4] = (1 - alpha * A) / a0;
        coeff[0] = (-2 * cos(w0)) / a0;
        coeff[1] = (1 - alpha / A) / a0;
        break;
    case highshelf:
        A = pow(10.f, para->Gain / 40.f);
        alpha = sin(w0) / 2 * sqrt((A + 1 / A) * (1 / para->QVaule - 1) + 2);
        a0 = (A + 1) - (A - 1) * cos(w0) + 2 * sqrt(A) * alpha;
        coeff[2] = (A * ((A + 1) + (A - 1) * cos(w0) + 2 * sqrt(A) * alpha)) / a0;
        coeff[3] = (-2 * A * ((A - 1) + (A + 1) * cos(w0))) / a0;
        coeff[4] = (A * ((A + 1) + (A - 1) * cos(w0) - 2 * sqrt(A) * alpha)) / a0;
        coeff[0] = (2 * ((A - 1) - (A + 1) * cos(w0))) / a0;
        coeff[1] = ((A + 1) - (A - 1) * cos(w0) - 2 * sqrt(A) * alpha) / a0;
        break;
    case lowshelf:
        A = pow(10.f, para->Gain / 40.f);
        alpha = sin(w0) / 2 * sqrt((A + 1 / A) * (1 / para->QVaule - 1) + 2);
        a0 = (A + 1) + (A - 1) * cos(w0) + 2 * sqrt(A) * alpha;
        coeff[2] = (A * ((A + 1) - (A - 1) * cos(w0) + 2 * sqrt(A) * alpha)) / a0;
        coeff[3] = (2 * A * ((A - 1) - (A + 1) * cos(w0))) / a0;
        coeff[4] = (A * ((A + 1) - (A - 1) * cos(w0) - 2 * sqrt(A) * alpha)) / a0;
        coeff[0] = (-2 * ((A - 1) + (A + 1) * cos(w0))) / a0;
        coeff[1] = ((A + 1) + (A - 1) * cos(w0) - 2 * sqrt(A) * alpha) / a0;
        break;
    default:
        break;
    }
    coeff[0] = -coeff[0];
    coeff[1] = -coeff[1];
    coeff[3] /= coeff[2];
    coeff[4] /= coeff[2];
    if (CheckStability(coeff, CoeffQ) != 0)
    {
        memset(coeff, 0, sizeof(float) * 5);
        coeff[2] = 1.f;
        return -1;
    }
    return 0;
}

EQPlotCore_ac800n::EQPlotCore_ac800n(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection) : EQPlotCore(FreqToPlot, nFreqPlot, para, nEQSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(float);
    //default plot in 48k
    //Transform frequency to normalize frequency exp( j*[0,pi] )
    for (int i = 0; i < nEQSection; i++)
    {
        for (int j = 0; j < nSampleRate; j++)
            SOSIIR_Generate_Core(para + i, m_coeff + 5 * j + i * nSampleRate * 5, SampleRateTab[j]);
        CalcPlotData(i);
    }
}
EQPlotCore_ac800n::~EQPlotCore_ac800n()
{
}

void EQPlotCore_ac800n::GetOnlineCoeff(int nSection, int enable, online_para_ac800n *para)
{
    para->enable_section = enable;
    if (enable)
        GetCoeff(para->data, nSection);
    else
    {
        memset(para->data, 0, sizeof(para->data));
        const int _one = 1 << 20;
        int *ptr = para->data + 2;
        for (int i = 0; i < 9; i++)
        {
            *ptr = _one;
            ptr += 5;
        }
    }
    para->seg_num = nSection;
    para->tag[0] = 'E';
    para->tag[1] = 'Q';
    para->type = EQ_ONLINE_SECTION;
    para->crc16 = CRC16(reinterpret_cast<unsigned char *>(&para->type), sizeof(online_para_ac800n) - sizeof(char) * 2 - sizeof(short));
}
void EQPlotCore_ac800n::GetOnlineGlobalGain(float globalGain, online_para_ac800n *para)
{
    para->enable_section = 1;
    para->seg_num = 0;
    para->tag[0] = 'E';
    para->tag[1] = 'Q';
    para->type = EQ_ONLINE_GLOBAL_GAIN;
    para->data[0] = *reinterpret_cast<int *>(&globalGain);
    para->crc16 = CRC16(reinterpret_cast<unsigned char *>(&para->type), sizeof(online_para_ac800n) - sizeof(char) * 2 - sizeof(short));
}
