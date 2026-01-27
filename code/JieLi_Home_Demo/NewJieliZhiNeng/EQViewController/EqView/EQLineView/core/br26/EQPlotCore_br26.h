#ifndef EQPlotCore_br26_H
#define EQPlotCore_br26_H
#include "common.h"
#include "EQPlotCore_ac800n.h"

class EQPlotCore_br26 : public EQPlotCore_ac800n
{
  public:
    EQPlotCore_br26(float *FreqToPlot, int nFreqPlot, SOS_Para *para, int nEQSection);
    ~EQPlotCore_br26() override;
    void GetOnlineCoeff(int nSection,int enable,online_para_ac800n *para) override;
    void GetCoeff(int *coeff, int nSection, float SampleRate) override;
    void GetCoeff(int *coeff, int nSection) override;
};
#endif
