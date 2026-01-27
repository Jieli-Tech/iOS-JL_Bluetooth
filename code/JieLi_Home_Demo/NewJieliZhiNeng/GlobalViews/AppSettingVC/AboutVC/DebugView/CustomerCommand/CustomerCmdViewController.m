//
//  CustomerCmdViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/10.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "CustomerCmdViewController.h"

@interface CustomerCmdViewController ()<UITextFieldDelegate>

@property(nonatomic,strong)UITextField *sendTextFixed;
@property(nonatomic,strong)UIButton *sendBtn;
@property(nonatomic,strong)UIButton *clearBtn;
@property(nonatomic,strong)UITextView *cmdTextLab;
@property(nonatomic,strong)NSString *logText;
@property(nonatomic,strong)JL_EntityM *entity;

@end

@implementation CustomerCmdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.titleLab.text = @"自定义命令";
    _logText = @"";
    self.entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [self stepUI];
    //接收自定义数据
    [JL_Tools add:kJL_MANAGER_CUSTOM_DATA Action:@selector(noteCustomData:) Own:self];
}


-(void)stepUI{
    _sendTextFixed = [UITextField new];
    _sendTextFixed.delegate = self;
    _sendTextFixed.keyboardType = UIKeyboardTypeASCIICapable;
    _sendTextFixed.returnKeyType = UIReturnKeyDone;
    _sendTextFixed.borderStyle = UITextBorderStyleRoundedRect;
    _sendTextFixed.clearButtonMode = UITextFieldViewModeWhileEditing;
    _sendTextFixed.backgroundColor = [UIColor colorFromHexString:@"#D7DADD"];
    
    [self.view addSubview:_sendTextFixed];
    [_sendTextFixed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.offset(60);
    }];
    
    _sendBtn = [UIButton new];
    [self.view addSubview:_sendBtn];
    _sendBtn.backgroundColor = [UIColor systemBlueColor];
    _sendBtn.layer.cornerRadius = 8;
    _sendBtn.layer.masksToBounds = true;
    [_sendBtn setTitle:@"Send" forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sendTextFixed.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.offset(40);
    }];
    
    _clearBtn = [UIButton new];
    [self.view addSubview:_clearBtn];
    _clearBtn.backgroundColor = [UIColor systemGreenColor];
    _clearBtn.layer.cornerRadius = 8;
    _clearBtn.layer.masksToBounds = true;
    [_clearBtn setTitle:@"Clear Cache Log" forState:UIControlStateNormal];
    [_clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clearBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_clearBtn addTarget:self action:@selector(clearBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_sendBtn.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.offset(40);
    }];
    
    _cmdTextLab = [UITextView new];
    _cmdTextLab.font = [UIFont systemFontOfSize:13];
    _cmdTextLab.textColor = [UIColor darkTextColor];
    _cmdTextLab.editable = NO;
    [self.view addSubview:_cmdTextLab];
    
    [_cmdTextLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_clearBtn.mas_bottom).offset(10);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFixedClosed)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)textFixedClosed{
    [_sendTextFixed endEditing:true];
}

-(void)backBtnAction{
    [self dismissViewControllerAnimated:true completion:nil];
}

-(void)sendBtnAction{
    if(_sendTextFixed.text.length != 0){
        //发送自定义数据
        NSData *data = [JL_Tools HexToData:_sendTextFixed.text];
        [self addStrToLogText:[JL_Tools dataChangeToString:data] sr:true];
        [self.entity.mCmdManager.mCustomManager cmdCustomData:data
                                                            Result:^(JL_CMDStatus status,
                                                                     uint8_t sn, NSData * _Nullable data) {
            if (status == JL_CMDStatusSuccess) {
                kJLLog(JLLOG_DEBUG,@"发数成功...");
            }else{
                kJLLog(JLLOG_DEBUG,@"发数失败~");
            }
        }];
    }else{
        [DFUITools showText:@"Error for nothing to send" onView:self.view delay:1];
    }
}

-(void)clearBtnAction{
    _logText = @"";
    _cmdTextLab.text = _logText;
}


-(void)addStrToLogText:(NSString *)str sr:(BOOL)type{
    NSString *typeStr = @"send:";
    if(!type){
        typeStr = @"receive:";
    }
    NSDateFormatter *fm = [NSDateFormatter new];
    fm.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString *dateStr = [fm stringFromDate:[NSDate new]];
    NSMutableString *mstr = [NSMutableString new];
    [mstr appendFormat:@"\n%@\n%@%@\n",dateStr,typeStr,str];
    [mstr appendString:_logText];
    _logText = mstr;
    _cmdTextLab.text = _logText;
    [_cmdTextLab scrollsToTop];
}


//MARK: - received data from device
-(void)noteCustomData:(NSNotification *)note{
    NSData *data = note.object;
    NSString *recStr = [JL_Tools dataChangeToString:data];
    [self addStrToLogText:recStr sr:false];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:true];
    return true;
}

@end
