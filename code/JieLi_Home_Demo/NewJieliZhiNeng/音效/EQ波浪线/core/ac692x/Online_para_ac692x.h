#ifndef Online_para_ac692x_h
#define Online_para_ac692x_h

typedef struct
{
    unsigned char type;            //<EQ_ONLINE_TYPE
    unsigned char seg_num;         //<当前调节的段：0到9
    unsigned short enable_section; //<current section is enable or not
    int data[45];                  ///<data
    int freq_gain;                 //current freq gain
} online_para_ac692x;

#endif
