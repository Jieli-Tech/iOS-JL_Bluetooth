#ifndef EQPlotCore_ac692x_H
#define EQPlotCore_ac692x_H

#include "common.h"
#include "Online_para_ac692x.h"
#include "EQPlotCore.h"
typedef struct
{
    int magic;
    unsigned short crc;
    unsigned short sec_num;
    int global_gain;
    unsigned int enable_section; //使能的段
    int data[0];        //nsr * nsec_num * 5 + sec_num
} eq_data_ac692x;

class EQPlotCore_ac692x : public EQPlotCore_HardWareVerison
{
  public:
    EQPlotCore_ac692x(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection);
    ~EQPlotCore_ac692x() override;
    void GetEQPlotData(float *PlotData, SOS_Para *para, int nSection, float globalGain) override;
    int GetBinSize(int ToltalSection);
    void ConvertToBin(float globalgain, SOS_Para *para,eq_data_ac692x *bin);
    void GetOnlineCoeff(int nSection,SOS_Para *sospara,online_para_ac692x *para);
    void GetOnlineGlobalGain(float globalGain,online_para_ac692x *para);
};

#endif
