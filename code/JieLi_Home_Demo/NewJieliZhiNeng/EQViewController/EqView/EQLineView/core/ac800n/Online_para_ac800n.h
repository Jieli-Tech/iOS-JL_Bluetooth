#ifndef Online_para_ac800n_h
#define Online_para_ac800n_h
#define EQ_ONLINE_SECTION 1
#define EQ_ONLINE_GLOBAL_GAIN 2
#define EQ_ONLINE_LIMITER 3
typedef struct
{
    char tag[2];                   //EQ
    unsigned short crc16;          //crc16=(type+seg_num+reserved+data)
    unsigned char type;            //<EQ_ONLINE_TYPE
    unsigned char seg_num;         //<当前调节的段：0到9
    unsigned short enable_section; //<current section is enable or not
    int data[45];                  ///<data
} online_para_ac800n;
#endif