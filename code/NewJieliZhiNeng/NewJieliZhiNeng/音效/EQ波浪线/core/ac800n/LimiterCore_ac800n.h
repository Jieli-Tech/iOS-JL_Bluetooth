#ifndef LimiterCore_ac800n_H
#define LimiterCore_ac800n_H
#include "Online_para_ac800n.h"
typedef struct
{
    int magic;
    unsigned int crc16;
    float AttackTime;
    float ReleaseTime;
    float Threshold;
    int Enable;
}limiter_data_ac800n;
void Limiter_ConvertToBin(float AttackTime,float ReleaseTime,float Threshold,int enable,limiter_data_ac800n *bin);
void Limiter_GetOnlinePara(float AttackTime,float ReleaseTime,float Threshold,int enable,online_para_ac800n *para);
#endif