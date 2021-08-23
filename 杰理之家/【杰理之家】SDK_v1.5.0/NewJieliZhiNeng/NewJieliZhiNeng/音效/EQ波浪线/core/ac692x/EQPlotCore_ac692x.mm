#include "EQPlotCore_ac692x.h"
#include "EQPlotCore.h"
#include <memory.h>

#define EQ_ONLINE_SECTION       1
#define EQ_ONLINE_GLOBAL_GAIN   2
#define EQ_ONLINE_LIMITER       3

static const float SampleRateTab[9] = {
    44100, 22050, 11025, 48000, 24000, 12000, 32000, 16000, 8000 //
};

static const int EQ_MAGIC = 0xa5a0;
static const int CoeffQ = 20;

int EQPlotCore_ac692x::GetBinSize(int nSection)
{
    return nSection * sizeof(SampleRateTab) / sizeof(float) * 5 * sizeof(float) + sizeof(eq_data_ac692x) + nSection * sizeof(float);
}
void EQPlotCore_ac692x::ConvertToBin(float globalgain, SOS_Para *para, eq_data_ac692x *bin)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(float);
    bin->enable_section = 0;
    bin->global_gain = (int)globalgain;
    bin->magic = EQ_MAGIC;
    bin->sec_num = 0;
    int *pData = bin->data;

    for (int j = 0; j < m_nEQSection; j++)
    {
        if (para[j].fEnable)
        {
            bin->enable_section |= (1 << j);
            GetCoeff(pData, j);
            pData[45] = (int)para[j].Gain;
            pData += 46;

            bin->sec_num++;
        }
    }
    bin->crc = CRC16(reinterpret_cast<unsigned char *>(&bin->sec_num),
                     sizeof(eq_data_ac692x) - sizeof(int) - sizeof(short) + bin->sec_num * nSampleRate * 5 * sizeof(int) + bin->sec_num * sizeof(int));
}

EQPlotCore_ac692x::EQPlotCore_ac692x(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection)
    : EQPlotCore_HardWareVerison(FreqToPlot, nFreqPlot, para, nEQSection)
{
}

EQPlotCore_ac692x::~EQPlotCore_ac692x()
{
}

void EQPlotCore_ac692x::GetEQPlotData(float *PlotData, SOS_Para *para, int nSection,float globalGain)
{
    SOS_Para *pPara = m_Para + nSection;
    memcpy(pPara, para, sizeof(SOS_Para));
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    for (int j = 0; j < nSampleRate; j++)
        SOSIIR_Generate_Core(para, m_coeff + 5 * j + nSection*nSampleRate * 5, SampleRateTab[j]);
    EQPlotCore::CalcPlotData(nSection);
    for (int i = 0; i < m_nFreqPlot; i++)
    {
        Complex tmp = (pow(10.f, globalGain / 20));
        for (int j = 0; j < m_nEQSection; j++)
            tmp += m_plotdata[i + j*m_nFreqPlot] *(pow(10.f, m_Para[j].Gain / 20) - 1)*(pow(10.f,globalGain/20));
        PlotData[i] = 10 * log10(tmp.mod());
    }
}

void EQPlotCore_ac692x::GetOnlineCoeff(int nSection, SOS_Para *sospara, online_para_ac692x *para)
{
    para->enable_section = sospara->fEnable;
    if (para->enable_section)
    {
        GetCoeff(para->data, nSection);
        para->freq_gain = (int)(sospara->Gain);
    }
    else
    {
        memset(para->data, 0, sizeof(para->data));
        para->freq_gain = (int)(sospara->Gain);
    }
    para->type = EQ_ONLINE_SECTION;
    para->seg_num = nSection;
}
void EQPlotCore_ac692x::GetOnlineGlobalGain(float globalGain, online_para_ac692x *para)
{
    para->enable_section = 1;
    para->seg_num = 0;
    para->type = EQ_ONLINE_GLOBAL_GAIN;
    para->data[0] = (int)globalGain;
}
