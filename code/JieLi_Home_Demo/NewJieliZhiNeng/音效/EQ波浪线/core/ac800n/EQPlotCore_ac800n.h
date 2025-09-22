#ifndef EQPlotCore_ac800n_H
#define EQPlotCore_ac800n_H
#include "common.h"
#include "Online_para_ac800n.h"
#include "EQPlotCore.h"
typedef struct
{
    int magic;
    unsigned short crc;
    unsigned short sec_num;
    float global_gain;
    unsigned int enable_section; //使能的段，bit0 到bit9，共10段
    int data[0];        //nsr * nsec_num * 5
} eq_data_ac800n;
class EQPlotCore_ac800n : public EQPlotCore
{
  public:
    EQPlotCore_ac800n(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection);
    ~EQPlotCore_ac800n() override;
    virtual int GetBinSize(int ToltalSection);
    virtual void ConvertToBin(float globalgain, int EnableBit, eq_data_ac800n *bin);
    virtual void GetOnlineCoeff(int nSection,int enable,online_para_ac800n *para);
    virtual void GetOnlineGlobalGain(float globalGain,online_para_ac800n *para);
  protected:
    static const int EQ_MAGIC = 0xa5a0;
    static const int CoeffQ = 20;
    int SOSIIR_Generate_Core(SOS_Para *para, float *coeff, float SampleRate) override;
    int CheckStability(float *a, int Q);
};
#endif
