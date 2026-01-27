#include "LimiterCore_ac800n.h"
#include "common.h"
static const int LIMITER_MAGIC = 0xa5a1;
void Limiter_ConvertToBin(float AttackTime, float ReleaseTime, float Threshold, int enable, limiter_data_ac800n *bin)
{
    bin->magic = LIMITER_MAGIC;
    bin->AttackTime = AttackTime;
    bin->ReleaseTime = ReleaseTime;
    bin->Enable = enable;
    bin->Threshold = Threshold;
    bin->crc16 = CRC16(reinterpret_cast<unsigned char *>(&bin->AttackTime),
                       sizeof(limiter_data_ac800n) - sizeof(bin->magic) - sizeof(bin->crc16));
}
void Limiter_GetOnlinePara(float AttackTime, float ReleaseTime, float Threshold, int enable, online_para_ac800n *para)
{
    para->enable_section = enable;
    para->seg_num = 0;
    para->tag[0] = 'E';
    para->tag[1] = 'Q';
    para->type = EQ_ONLINE_LIMITER;
    para->data[0] = *reinterpret_cast<int *>(&AttackTime);
    para->data[1] = *reinterpret_cast<int *>(&ReleaseTime);
    para->data[2] = *reinterpret_cast<int *>(&Threshold);
    para->crc16 = CRC16(reinterpret_cast<unsigned char *>(&para->type), sizeof(online_para_ac800n) - sizeof(char) * 2 - sizeof(short));
}
