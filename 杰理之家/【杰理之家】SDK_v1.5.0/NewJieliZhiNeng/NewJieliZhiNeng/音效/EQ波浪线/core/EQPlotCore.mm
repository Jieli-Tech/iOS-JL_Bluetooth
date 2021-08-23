#include <cmath>
#include <memory.h>
#include "EQPlotCore.h"

static const float SampleRateTab[9] =
{
    44100, 22050, 11025, 48000, 24000, 12000, 32000, 16000, 8000
};
int EQPlotCore::SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate)
{//coeff -> a1 a2 b0 b1/b0 b2/b0
    if (para->type != bandpass && para->CenterFrequency >= SampleRate / 2 || !para->fEnable )
    {
        memset(coeff, 0, sizeof(float)* 5);
        coeff[2] = 1.f;
        return -1;
    }
    else
    {
        float BandWidth = para->CenterFrequency / para->QVaule;
        if (para->CenterFrequency > SampleRate / 2 || BandWidth == 0 || (BandWidth / 2 + para->CenterFrequency) > SampleRate / 2)
        {
            memset(coeff, 0, sizeof(float)* 5);
            coeff[2] = 1.f;
            return -1;
        }
    }
    float PI = atan(1.f) * 4;
    float w0 = 2 * PI*para->CenterFrequency / SampleRate;
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
        coeff[2] = (1 + alpha*A) / a0;
        coeff[3] = (-2 * cos(w0)) / a0;
        coeff[4] = (1 - alpha*A) / a0;
        coeff[0] = (-2 * cos(w0)) / a0;
        coeff[1] = (1 - alpha / A) / a0;
        break;
    case highshelf:
        A = pow(10.f, para->Gain / 40.f);
        alpha = sin(w0) / 2 * sqrt((A + 1 / A)*(1 / para->QVaule - 1) + 2);
        a0 = (A + 1) - (A - 1)*cos(w0) + 2 * sqrt(A)*alpha;
        coeff[2] = (A*((A + 1) + (A - 1)*cos(w0) + 2 * sqrt(A)*alpha)) / a0;
        coeff[3] = (-2 * A*((A - 1) + (A + 1)*cos(w0))) / a0;
        coeff[4] = (A*((A + 1) + (A - 1)*cos(w0) - 2 * sqrt(A)*alpha)) / a0;
        coeff[0] = (2 * ((A - 1) - (A + 1)*cos(w0))) / a0;
        coeff[1] = ((A + 1) - (A - 1)*cos(w0) - 2 * sqrt(A)*alpha) / a0;
        break;
    case lowshelf:
        A = pow(10.f, para->Gain / 40.f);
        alpha = sin(w0) / 2 * sqrt((A + 1 / A)*(1 / para->QVaule - 1) + 2);
        a0 = (A + 1) + (A - 1)*cos(w0) + 2 * sqrt(A)*alpha;
        coeff[2] = (A*((A + 1) - (A - 1)*cos(w0) + 2 * sqrt(A)*alpha)) / a0;
        coeff[3] = (2 * A*((A - 1) - (A + 1)*cos(w0))) / a0;
        coeff[4] = (A*((A + 1) - (A - 1)*cos(w0) - 2 * sqrt(A)*alpha)) / a0;
        coeff[0] = (-2 * ((A - 1) + (A + 1)*cos(w0))) / a0;
        coeff[1] = ((A + 1) + (A - 1)*cos(w0) - 2 * sqrt(A)*alpha) / a0;
        break;
    default:
        break;
    }
    coeff[0] = -coeff[0];
    coeff[1] = -coeff[1];
    coeff[3] /= coeff[2];
    coeff[4] /= coeff[2];
    return 0;
}



void EQPlotCore::CalcPlotData(int nSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    Complex *pPlotData = m_plotdata + nSection*m_nFreqPlot;
    float *pCoeff = m_coeff + 3 * 5 + nSection * 5 * nSampleRate;
    for (int i = 0; i < m_nFreqPlot; i++)
    {
        Complex num, den;
        num = ((m_ZFreq[i] * pCoeff[4] + pCoeff[3]) * m_ZFreq[i] + 1)*pCoeff[2];
        den =   -(m_ZFreq[i] * pCoeff[1] + pCoeff[0] ) * m_ZFreq[i] + 1;
        pPlotData[i] = num/den;
    }
}
/*
TODO:
when section config change, call this function to get data to plot
Parameter:
PlotData:data to plot
para:the config of the changed section
nSection:the number of the changed section
para
*/
void EQPlotCore::GetEQPlotData(float *PlotData, SOS_Para *para, int nSection, float _globalGain)
{

    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    for (int j = 0; j < nSampleRate; j++)
        SOSIIR_Generate_Core(para, m_coeff + 5 * j + nSection*nSampleRate * 5, SampleRateTab[j]);
    CalcPlotData(nSection);
    for (int i = 0; i < m_nFreqPlot; i++)
    {
		PlotData[i] = 10*log10(m_plotdata[i].mod());
		for (int j = 1; j < m_nEQSection; j++)
		{
			PlotData[i] +=  10 * log10(m_plotdata[i + j * m_nFreqPlot].mod());
		}
    }
}
/*
TODO:
Get coefficient to send
Parameter:
coeff:coefficient of the SOSIIR
nSection:the number of section go to get
*/
void EQPlotCore::GetCoeff(int *coeff, int nSection,float SampleRate)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    int SampleRate_idx = 0;
    for (; SampleRate_idx < nSampleRate; SampleRate_idx++)
    {
        if (SampleRate==SampleRateTab[SampleRate_idx])
            break;
    }
    float *pCoeff = m_coeff + nSection * 5 * nSampleRate + 5*SampleRate_idx;
    for (int j = 0; j < 5; j++)
    {
        coeff[j] = (int)round((1 << 20)*(pCoeff[j]));
    }
}
void EQPlotCore_HardWareVerison::GetCoeff(int *coeff, int nSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    float *pCoeff = m_coeff + nSection * 5 * nSampleRate;
    for (int j = 0; j < 5*nSampleRate; j++)
    {
        if ((j - 3) % 5 == 0 || (j - 4) % 5 == 0)
            coeff[j] = (int)((pCoeff[j]));
        else
            coeff[j] = (int)round((1 << 20)*(pCoeff[j]));
    }
}
void EQPlotCore::GetCoeff(int *coeff, int nSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    float *pCoeff = m_coeff + nSection * 5 * nSampleRate;
    for (int j = 0; j < 5*nSampleRate; j++)
    {
        coeff[j] = (int)round((1 << 20)*(pCoeff[j]));
    }
}

void EQPlotCore::ConvertToOldStruct(SOS_Para *para, const Tool_Info *info, eq_dbg_online_t *out)
{
    int sub_coeff[9 * 5];
    int *pCoeff = (int*)out->eq_filt_0;
    int Skip = sizeof(out->eq_filt_0) / sizeof(int);
    out->eq_cnt = m_nEQSection;
    out->eq_type = 6;
    out->eq_gain[0] = (int)(info->Limiter_Threshold * 1000);
    out->eq_gain[1] = info->Limiter_ReleaseTIme;
    out->eq_gain[2] = info->Limiter_AttackTime;
    out->eq_gain[3] = (int)(round(  pow(10.f,info->EQ_GlobalGain/20) *(1 << 20)));
    out->eq_gain[4] = (int)info->Limiter_Switch;
    for (int i = 0; i < out->eq_cnt; i++)
    {
        this->GetCoeff(sub_coeff, i);
        for (int j = 0; j < 9; j++)
        {
            memcpy(pCoeff + i * 5 + j*Skip, sub_coeff + j * 5, 5 * sizeof(int));
        }
    }
    out->crc16 = (unsigned int)CRC16((unsigned char*)out, sizeof(eq_dbg_online_t)-sizeof(out->crc16));
}
/*
TODO:
Init the PlotCore
Parameter:
FreqToPlot:point to an array which store frequency need to plot
nFreqPlot:how many frequency need to plot
para:point to an array specify all the section's config
nEQSection:total number of section
*/
EQPlotCore::EQPlotCore(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    m_ZFreq = new Complex[nFreqPlot];
    m_plotdata = new Complex[nFreqPlot*nEQSection];
    m_coeff = new float[nEQSection * 5 * nSampleRate];
    m_nFreqPlot = nFreqPlot;
    m_nEQSection = nEQSection;
    //default plot in 48k
    //Transform frequency to normalize frequency exp( j*[0,pi] )
    float PlotSampleRate = 48000;
    float PI = atan(1) * 4;
    for (int i = 0; i < nFreqPlot; i++)
    {
        double w = 2 * PI*FreqToPlot[i] / PlotSampleRate;
        m_ZFreq[i] = Complex(cos(w), -sin(w));
    }
    for (int i = 0; i < nEQSection; i++)
    {
        for (int j = 0; j < nSampleRate; j++)
            SOSIIR_Generate_Core(para + i, m_coeff + 5 * j + i*nSampleRate * 5, SampleRateTab[j]);
        CalcPlotData(i);
    }
}
EQPlotCore::~EQPlotCore()
{
    delete[] m_ZFreq;
    delete m_coeff;
    delete m_plotdata;
}

EQPlotCore_HardWareVerison::EQPlotCore_HardWareVerison(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection) :EQPlotCore(FreqToPlot, nFreqPlot, para, nEQSection)
{
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    m_Para = new SOS_Para[nEQSection];
    memcpy(m_Para, para, sizeof(SOS_Para)*nEQSection);
    for (int i = 0; i < nEQSection; i++)
    {
        for (int j = 0; j < nSampleRate; j++)
            SOSIIR_Generate_Core(para + i, m_coeff + 5 * j + i*nSampleRate * 5, SampleRateTab[j]);
        EQPlotCore::CalcPlotData(i);
    }
}
EQPlotCore_HardWareVerison::~EQPlotCore_HardWareVerison()
{
    delete m_Para;
}

int EQPlotCore_HardWareVerison::SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate)
{
    if (para->fEnable == false)
    {
        memset(coeff, 0, sizeof(float)* 5);
        return -1;
    }
    if (para->type != bandpass)
    {
        float cutoffFreq = (para->CenterFrequency / para->QVaule)/2+para->CenterFrequency;
        if (cutoffFreq > SampleRate / 2 || para->CenterFrequency >= SampleRate / 2)
        {
            memset(coeff, 0, sizeof(float)* 5);
            //coeff[2] = 1.f;
            return -1;
        }
    }
    else
    {
        //float BandWidth = para->CenterFrequency / para->QVaule;
        float cutoffFreq = para->CenterFrequency / (para->QVaule*pow(10, para->Gain / 40.f)) / 2 + para->CenterFrequency;
        if (para->CenterFrequency > SampleRate / 2 || cutoffFreq == 0 || cutoffFreq > SampleRate / 2)
        {
            memset(coeff, 0, sizeof(float)* 5);
            //coeff[2] = 1.f;
            return -1;
        }
    }
    float PI = atan(1.f) * 4;
    float c,c2,csqr2;
    float sqr2 = sqrt(2.f);
    float d;
    float ampIn0,ampIn1,ampIn2,ampOut1,ampOut2;
    float  cutoffFreq;
    switch (para->type)
    {
    case lowpass:
        cutoffFreq = para->CenterFrequency / para->QVaule;
        c = tan((PI / SampleRate) * cutoffFreq);
        c2 = c * c;
        csqr2 = sqr2 * c;
        d = (c2 + csqr2 + 1);
        ampIn0 = 1 / d;
        ampIn1 = -(ampIn0 + ampIn0);
        ampIn2 = ampIn0;
        ampOut1 = (2 * (c2 - 1)) / d;
        ampOut2 = (1 - csqr2 + c2) / d;
        break;
    case highpass:
        cutoffFreq = para->CenterFrequency / para->QVaule;
        c = 1 / tan((PI / SampleRate) * cutoffFreq);
        c2 = c * c;
        csqr2 = sqr2 * c;
        d = (c2 + csqr2 + 1);
        ampIn0 = 1 / d;
        ampIn1 = ampIn0 + ampIn0;
        ampIn2 = ampIn0;
        ampOut1 = (2 * (1 - c2)) / d;
        ampOut2 = (c2 - csqr2 + 1) / d;
        break;
    case bandpass:
        cutoffFreq = para->CenterFrequency / (para->QVaule*pow(10, para->Gain / 40.f));
        c = 1 / tan((PI / SampleRate) * cutoffFreq);       //cutoffFreq: bandWidth
        d = 1 + c;
        ampIn0 = 1 / d;
        ampIn1 = 0;
        ampIn2 = -ampIn0;
        ampOut1 = (-c * 2 * cos(2 * PI*para->CenterFrequency / SampleRate)) / d;
        ampOut2 = (c - 1) / d;
        break;
    default:
        break;
    }
    coeff[0] = -ampOut1;
    coeff[1] = -ampOut2;
    coeff[2] = ampIn0;
    coeff[3] = ampIn1/ampIn0;
    coeff[4] = ampIn2/ampIn0;
    return 0;
}
void EQPlotCore_HardWareVerison::GetEQPlotData(float *PlotData, SOS_Para *para, int nSection,float globalGain)
{
    SOS_Para *pPara = m_Para + nSection;
    memcpy(pPara, para, sizeof(SOS_Para));
    int nSampleRate = sizeof(SampleRateTab) / sizeof(int);
    for (int j = 0; j < nSampleRate; j++)
        SOSIIR_Generate_Core(para, m_coeff + 5 * j + nSection*nSampleRate * 5, SampleRateTab[j]);
    EQPlotCore::CalcPlotData(nSection);
    for (int i = 0; i < m_nFreqPlot; i++)
    {
        Complex tmp = (pow(10.f, globalGain / 10));
        for (int j = 0; j < m_nEQSection; j++)
            tmp += m_plotdata[i + j*m_nFreqPlot] *(pow(10.f, m_Para[j].Gain / 20) - 1)*(pow(10.f,globalGain/20));
        PlotData[i] = 10 * log10(tmp.mod());
    }
}

void EQPlotCore_HardWareVerison::ConvertToOldStruct(SOS_Para *para, const Tool_Info *info, eq_dbg_online_t *out)
{
    int sub_coeff[9 * 5];
    int *pCoeff = (int*)out->eq_filt_0;
    int Skip = sizeof(out->eq_filt_0) / sizeof(int);
    out->eq_cnt = 10;
    out->eq_type = 6;
    for (int i = 0; i < 10; i++)
        out->freq_gain[6][i] = (int)para[i].Gain;
    out->eq_gain[6] = (int)info->EQ_GlobalGain;
    for (int i = 0; i < out->eq_cnt; i++)
    {
        this->GetCoeff(sub_coeff, i);
        for (int j = 0; j < 9; j++)
        {
            memcpy(pCoeff + i * 5 + j*Skip, sub_coeff + j * 5, 5 * sizeof(int));
        }
    }
    out->crc16 = (unsigned int)CRC16((unsigned char*)out, sizeof(eq_dbg_online_t)-sizeof(out->crc16));
}
