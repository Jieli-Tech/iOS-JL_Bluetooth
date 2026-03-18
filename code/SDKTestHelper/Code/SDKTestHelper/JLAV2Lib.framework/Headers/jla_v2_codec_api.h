#ifndef _JLA_V2_CODEC_h
#define _JLA_V2_CODEC_h


#ifndef u16
#define  u32  unsigned int
#define  u16  unsigned short
#define  s16  short
#define  u8  unsigned char
#endif

#define  SET_DECODE_MODE      0x80
#define  SET_DEC_CH_MODE      0x81
//#define  SET_FADE_IN_TMS      0x82    //for dec  plc  deleted
#define  SET_FADE_IN_OUT      0x82    //淡入淡出  设置生效.
#define  SET_NEW_BITRATE      0x90    //enc.
#define  GET_EDFRAME_LEN      0x91    //
#define  SET_EDFRAME_LEN      0x92    //only for dec.

#define  SET_HW_FFT_CALLBACK  0xA0    //br56_fft. 

enum
{
	JLA_V2_NORMAL_CH = 0,    //仅在此模式下,音源为双声道时输出双声道pcm数据.
	JLA_V2_L_OUT,
	JLA_V2_R_OUT,
	JLA_V2_LR_MEAN
};

enum
{
	JLA_V2_2CH_L_OR_R = 0x80
};

struct audio_decode_para
{
	u32 mode;    /*通过codec_config,cmd=SET_DECODE_MODE设置解码输出模式*/
};


struct audio_set_bitrate
{
	u32 br;
};

struct jla_v2_dec_ch_oput_para
{
	u32 mode;
	short pL;    //mode_3_channel_L_coefficient  Q13  8192:50%
	short pR;    //mode_3_channel_R_coefficient  Q13
};


struct jla_v2_codec_info
{
	u32 sr;            ///< sample rate
	u32 br;            ///< bit rate
	u16 fr_idx;        ///< 帧长索引.  JLA_V2_FRLEN[9 + 4 +1] = {32, 40, 48, 60, 64, 80, 96, 120, 128, 160, 240, 320, 400, 480};    0~13.
	u16 nch;
	u16 if_s24;        ///< 编码输入数据  或者解码输出数据位宽是否为24比特.  
};  ///< enc_para + dec_para


struct jla_v2_codec_io
{
	void* priv;
	u16(*input_data)(void* priv, u8* buf, u16 len);   //bytes 
	u16(*output_data)(void* priv, u8* buf, u16 len);   //bytes   /*解码器在struct audio_decode_para参数mode=1时判断是否输出完整*/
};


struct jla_v2_codec_ops {
	u32(*open)(void* work_buf, const struct jla_v2_codec_io* audioIO, void* para);  ///<打开解码器
	u32(*run)(void* work_buf, void* scratch);		///<解码主循环(buffer 32bit对齐)
	u32(*need_dcbuf_size)(void* para);		///<获取编解码需要的空间work_buf
	u32(*need_stbuf_size)(void* para);               ///<获取编解码需要的堆栈scratch
	u32(*codec_config)(void* work_buf, u32 cmd, void* parm);
};


extern struct jla_v2_codec_ops* get_jla_v2_enc_ops();
extern struct jla_v2_codec_ops* get_jla_v2_dec_ops();


extern const int  JLA_V2_PLC_EN;
extern const int  JLA_V2_HW_FFT;
extern const int  JLA_V2_ENCODE_I24bit_ENABLE;
extern const int  JLA_V2_DECODE_O24bit_ENABLE;
extern const int  JLA_V2_PLC_FADE_OUT_START_POINT;
extern const int  JLA_V2_PLC_FADE_OUT_POINTS;
extern const int  JLA_V2_PLC_FADE_IN_POINTS;
extern const unsigned short  JLA_V2_FRAMELEN_MASK;



#endif