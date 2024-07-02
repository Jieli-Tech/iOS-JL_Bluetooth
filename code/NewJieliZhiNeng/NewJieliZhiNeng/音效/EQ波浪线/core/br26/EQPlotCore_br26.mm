#include "EQPlotCore_br26.h"
#include <memory.h>

static const float SampleRateTab[9] = {
    44100, 22050, 11025, 48000, 24000, 12000, 32000, 16000, 8000 //
};

static void reorder(int *coeff, int nsec)
{
    int tmp[5];
    for (int i = 0; i < nsec; i++)
    {
        memcpy(tmp, coeff, 5 * sizeof(int));
        coeff[0] = tmp[2];
        coeff[2] = tmp[4];
        coeff[3] = tmp[0];
        coeff[4] = tmp[3];
        coeff += 5;
    }
}

EQPlotCore_br26::EQPlotCore_br26(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection) : EQPlotCore_ac800n(FreqToPlot, nFreqPlot, para, nEQSection)
{
}
EQPlotCore_br26::~EQPlotCore_br26()
{
}

void EQPlotCore_br26::GetCoeff(int *coeff, int nSection, float SampleRate)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    int SampleRate_idx = 0;
    for (; SampleRate_idx < nSampleRate; SampleRate_idx++)
    {
        if (SampleRate == SampleRateTab[SampleRate_idx])
            break;
    }
    float *pCoeff = m_coeff + nSection * 5 * nSampleRate + 5 * SampleRate_idx;
    for (int j = 0; j < 5; j++)
    {
        coeff[j] = (int)round((1 << 22) * (pCoeff[j]));
    }
    reorder(coeff, 1);
}
void EQPlotCore_br26::GetCoeff(int *coeff, int nSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    float *pCoeff = m_coeff + nSection * 5 * nSampleRate;
    for (int j = 0; j < 5 * nSampleRate; j++)
    {
        coeff[j] = (int)round((1 << 22) * (pCoeff[j]));
    }
    reorder(coeff, nSampleRate);
}
void EQPlotCore_br26::GetOnlineCoeff(int nSection, int enable, online_para_ac800n *para)
{
    para->enable_section = unsigned(enable);
    if (enable)
        GetCoeff(para->data, nSection);
    else
    {
        memset(para->data, 0, sizeof(para->data));
        const int _one = 1 << 22;
        int *ptr = para->data + 2;
        for (int i = 0; i < 9; i++)
        {
            ptr[3] = _one;
            ptr += 5;
        }
    }
    para->seg_num = nSection;
    para->tag[0] = 'E';
    para->tag[1] = 'Q';
    para->type = EQ_ONLINE_SECTION;
    para->crc16 = CRC16(reinterpret_cast<unsigned char *>(&para->type), sizeof(online_para_ac800n) - sizeof(char) * 2 - sizeof(short));
}
