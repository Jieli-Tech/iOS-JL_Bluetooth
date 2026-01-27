#ifndef EQPlotCore_h__
#define EQPlotCore_h__
#include "common.h"

typedef struct EQ_DBG_ONLINE
{
    //u8 eq_flag[4];                    ///<EQ标志"EQ"
    unsigned int eq_type;                   ///<EQ类型
    unsigned int eq_cnt;                    ///<EQ段数
    unsigned int freq_gain[7][10]; ///<EQ各个频段的增益
    unsigned int eq_gain[7];             ///<EQ总增益
    unsigned int eq_filt_0[50];           ///<EQ滤波器1
    unsigned int eq_filt_1[50];           ///<EQ滤波器2
    unsigned int eq_filt_2[50];           ///<EQ滤波器3
    unsigned int eq_filt_3[50];           ///<EQ滤波器1
    unsigned int eq_filt_4[50];           ///<EQ滤波器2
    unsigned int eq_filt_5[50];           ///<EQ滤波器3
    unsigned int eq_filt_6[50];           ///<EQ滤波器1
    unsigned int eq_filt_7[50];           ///<EQ滤波器2
    unsigned int eq_filt_8[50];           ///<EQ滤波器3
    unsigned int crc16;
}eq_dbg_online_t;
struct Tool_Info
{
    float EQ_GlobalGain;
    int Limiter_AttackTime;
    int Limiter_ReleaseTIme;
    float Limiter_Threshold;
    bool Limiter_Switch;
};
class EQPlotCore
{
public:
    EQPlotCore(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection);
    virtual ~EQPlotCore();
    int GetEQSectionCount() const { return m_nEQSection; }
    virtual void GetEQPlotData(float *PlotData,SOS_Para *para,int nSection, float globalGain);
    virtual void GetCoeff(int *coeff, int nSection, float SampleRate);
    virtual void GetCoeff(int *coeff, int nSection);
    virtual void ConvertToOldStruct(SOS_Para *para, const Tool_Info *info, eq_dbg_online_t *out);
protected:
    Complex *m_ZFreq;
    float *m_coeff;
    Complex *m_plotdata;
    int m_nFreqPlot;
    int m_nEQSection;
    void CalcPlotData(int nSection);
    virtual int SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate);
};
class EQPlotCore_HardWareVerison :public EQPlotCore
{
public:
    EQPlotCore_HardWareVerison(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection);
    ~EQPlotCore_HardWareVerison() override;
    void GetEQPlotData(float *PlotData, SOS_Para *para, int nSection, float globalGain) override;
    void GetCoeff(int *coeff, int nSection) override;
    void ConvertToOldStruct(SOS_Para *para, const Tool_Info *info, eq_dbg_online_t *out) override;
protected:
    SOS_Para *m_Para;
    int SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate) override;
};
#endif // EQPlotCore_h__
