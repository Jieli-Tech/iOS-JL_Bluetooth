//
//  FatsObject.m
//  QCY_Demo
//
//  Created by 杰理科技 on 2020/11/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FatsObject.h"
#include "ff.h"
#include "diskop.h"
#include "diskio.h"
#include <stdio.h>
#include <memory>

JL_ManagerM *JLCmdManager = nil;
static BOOL isTransferFace = NO;
static NSInteger allDatalength  = 0;
static NSInteger sentDatalength = 0;
static FatsCreateFile_BK fatsCreateFile_BK = nil;

FATFS m_fatFs[FF_VOLUMES];
extern "C" void diskio_initialization(UINT diskSize);

class RealIoOpeartion : public IoOperation {
public:
    ~RealIoOpeartion () override {}
    
#if IS_FROM_BLE
    /*--- 从蓝牙【读】数据 ---*/
    bool read(void *buf, uint32_t offset, uint32_t size) override {
        __block uint8_t isOk = 0;
        __block NSInteger dataLen = 0;

        JLModel_Device *model = [JLCmdManager outputDeviceModel];
        
        uint16_t flashMtu = model.flashInfo.mFlashMtu;
        if (flashMtu == 0) flashMtu = 128;

        [JLCmdManager cmdReadFromFlashAllDataOffset:(uint32_t)offset Size:size Mtu:flashMtu
                                             Result:^(uint8_t flag,NSData * _Nonnull data) {
            isOk = flag;
            dataLen = data.length;
            BYTE *readBuf = (BYTE *)[data bytes];
            memcpy(buf, readBuf, size);
        }];
        NSLog(@"--->Fats Read Data:%ld",(long)dataLen);
        if (isOk == 0) {
            return true;
        }else{
            return false;
        }
    }

    /*--- 往蓝牙【写】数据 ---*/
    bool write(const void *buf, uint32_t offset, uint32_t size) override {
        __block uint8_t isOk = 0;
        NSData *data = [NSData dataWithBytes:buf length:size];

        JLModel_Device *model = [JLCmdManager outputDeviceModel];
        uint16_t flashMtu = model.flashInfo.mFlashMtu;
        if (flashMtu == 0) flashMtu = 128;

        [JLCmdManager cmdWriteToFlashAllData:data Offset:(uint32_t)offset
                                       Mtu:flashMtu Result:^(uint8_t flag, uint32_t size) {
            isOk = flag;
            
            /*--- 计算传输文件百分比 ---*/
            if (isTransferFace == YES) {
                sentDatalength = sentDatalength + size;
                float pgs = (float)sentDatalength/(float)allDatalength;
                float progress = 0.0f;
                
                if (pgs > 0.9f) {
                    progress = 0.99f;
                }else{
                    progress = pgs;
                }
                fatsCreateFile_BK(progress);
            }
        }];
        if(isOk == 0){
            NSLog(@"--->Fats Wtite Data:%u",size);
            return true;
        }else{
            return false;
        }
    }
    
    bool readFlag(bool &flag) override {
        printf("--->Fats Read Flag...\n");

        __block JLModel_Flash *flash = nil;
        [JLCmdManager cmdGetFlashInfoResult:^(JLModel_Flash * _Nullable model) {
            flash = model;
        }];
        
        if (flash) {
            if (flash.mFlashStatus == 0x00) {
                flag = true;
            }else{
                flag = false;
            }
            return true;
        }else{
            return false;
        }
        // flag == true, 表示上次升级处于正常状态，false表示上次升级失败
    }

    bool writeFlag(bool isSuccessed) override {
        printf("--->Fats Write Flag...\n");
        // isSuccessed
        //   true  表示升级成功，
        //   false 表示失败
        uint8_t isOk = 0x00;
        if (isSuccessed == false) isOk = 0x01;
        
        __block uint8_t mFlag = 0;
        [JLCmdManager cmdWriteProtectFlashFlag:isOk Result:^(uint8_t flag) {
            mFlag = flag;
        }];
        [JL_Tools mainTask:^{
            UIWindow *win = [DFUITools getWindow];
            [DFUITools showText:@"Write FLAG" onView:win delay:1.0];
        }];
        if (mFlag == 0) {
            return true;
        }else{
            return false;
        }
    }
    
#else
    /*--- 从本地【读】数据 ---*/
    bool read(void *buf, uint32_t offset, uint32_t size) override {
        NSString *path = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@"test_fatfs.img"];
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        NSData *readData = [data subdataWithRange:NSMakeRange((unsigned int)offset, size)];

        BYTE *readBuf = (BYTE *)[readData bytes];
        memcpy(buf, readBuf, size);
        
        printf("--->(LOCAL)Fats Read Data:%ld \n",(long)size);
        return true;
    }

    /*--- 往本地【写】数据 ---*/
    bool write(const void *buf, uint32_t offset, uint32_t size) override {
        NSString *path = [JL_Tools listPath:NSDocumentDirectory MiddlePath:@"" File:@"test_fatfs.img"];
        NSData *data = [NSData dataWithBytes:buf length:size];
        [JL_Tools writeData:data Seek:offset File:path];
        printf("--->(LOCAL)Fats Wtite Data:%ld \n",(long)size);
        
        
        /*--- 计算传输文件百分比 ---*/
        if (isTransferFace == YES) {
            sentDatalength = sentDatalength + data.length;
            float pgs = (float)sentDatalength/(float)allDatalength;
            float progress = 0.0f;
            
            if (pgs > 1.0f) {
                progress = 0.9999f;
            }else{
                progress = pgs;
            }
            fatsCreateFile_BK(progress);
        }
        
        return true;
    }
    
    bool readFlag(bool &flag) override {
        flag = true; // flag == true, 表示上次升级处于正常状态，false表示上次升级失败
        return true;
    }

    bool writeFlag(bool isSuccessed) override {
        // isSuccessed
        //   true  表示升级成功，
        //   false 表示失败
        return true;
    }
#endif
};

static std::shared_ptr<DiskOp> diskOp;

extern "C" {
    int do_test_disk_io_read(void *buf, uint32_t offset, uint32_t size) {
        if (diskOp) {
            return diskOp->read(buf, offset, size);
        }
        return 0;
    }

    int do_test_disk_io_write(const void *buf, uint32_t offset, uint32_t size) {
        if (diskOp) {
            return diskOp->write(buf, offset, size);
        }
        return 0;
    }
}

// 初始化，设置接口
std::shared_ptr<DiskOp> initDiskIoContext(unsigned imageSize) {
    diskOp = std::make_shared<DiskOp>(imageSize, std::make_shared<RealIoOpeartion>());
    return diskOp;
}




@implementation FatsObject

+(void)makeCmdManager:(JL_ManagerM*)manager{
    JLCmdManager = manager;
}

+(BOOL)makeFlashSize:(uint32_t)flashSize FatsSize:(uint32_t)fatsSize{
    
#if IS_FROM_BLE
    
    diskio_initialization(flashSize); // 512 KB external flash size
    
    auto op = initDiskIoContext(fatsSize);
    if(!op->init()){
        NSLog(@"---> Fats init fail.");
        return NO;
    }
#else
    diskio_initialization(10*1024*1024); // 512 KB external flash size
    auto op = initDiskIoContext(10*1024*1024);
#endif
    
    FRESULT ret = f_mount(&m_fatFs[0], MY_SLASH_STRING, 1);
    if (ret != FR_OK) {
        printf("fmount is fail~\r\n");
        return NO;
    }else{
        printf("fmount is OK!\r\n");
        uint32_t real_data_size = flashSize - (m_fatFs->database - 8) * 512;
        if (m_fatFs->csize > 0) {
            uint32_t real_nclst = real_data_size /(m_fatFs->csize * 512) +2;//数据区用簇来计算的大小
            if (real_nclst < m_fatFs->n_fatent) {
                m_fatFs->n_fatent = real_nclst;
            }
        }
        return YES;
    }
}

static NSMutableArray *mListArray = nil;
+(NSArray*)makeListPath:(NSString*)path{
    mListArray = [NSMutableArray new];
    const char *dirname = (const char *)[path UTF8String];
    on_list_dir(dirname);
    return mListArray;
}


void on_list_dir(const char *dirname) {
    FATDIR dir;
    FRESULT ret = f_opendir(&dir, dirname);
    if (ret != FR_OK) {
        return;
    }

    auto dirnameLen = strlen(dirname);

    while (1) {
        FILINFO info;
        memset(&info, 0, sizeof(info));
        
        ret = f_readdir(&dir, &info);
        if ((ret != FR_OK) || info.fname[0] == '\0') {
            break;
        }

        auto _filepath = std::unique_ptr<char[]>(
            new char[(dirnameLen + strlen(info.fname) + 2)]);
        auto filepath = _filepath.get();

        if (dirname[dirnameLen-1] == MY_SLASH_CHAR) {
            sprintf(filepath, "%s%s", dirname, info.fname);
        } else {
            sprintf(filepath, "%s%s%s", dirname, MY_SLASH_STRING, info.fname);
        }

        NSString *fileName = [NSString stringWithCString:info.fname encoding:NSASCIIStringEncoding];
        if (fileName.length > 0) {
            [mListArray addObject:fileName];
        }else{
            [mListArray addObject:@"Unknow"];
        }

        if (info.fattrib & AM_DIR) {
            on_list_dir(filepath);
        } else {
        }
    }
    f_closedir(&dir);
}

+(BOOL)makeCreateFile:(NSString*)path
              Content:(NSData* __nullable)data
               Result:(FatsCreateFile_BK)result
{
    isTransferFace = YES;
    fatsCreateFile_BK = result;
    allDatalength = data.length + 9*1024;
    sentDatalength= 0;
    
    if (!diskOp->insertFile((const TCHAR*)[path UTF8String],
                            (const void*)[data bytes],
                            (UINT)data.length)) {
        [self updateFatsProgress:0.0];
        return NO;
    }else{
        [self updateFatsProgress:1.0f];
        return YES;
    }
}
+(void)updateFatsProgress:(float)progress{
    isTransferFace = NO;
    if (fatsCreateFile_BK) {
        fatsCreateFile_BK(progress);
        fatsCreateFile_BK = nil;
    }
}


+(BOOL)makeRemoveFile:(NSString*)path{
    if (!diskOp->deleteFile((const TCHAR*)[path UTF8String])) {
      // 失败，不用记录状态
        return NO;
    }else{
        return YES;
    }
}

+(uint32_t)makeGetFree{
    uint32_t size = 0;
    if (!diskOp->begin()) {
        return 0;
    }else{
        FATFS *fatfs;
        FRESULT ret = f_getfree("/", &size, &fatfs);

        if (ret != FR_OK) {
            diskOp->abort();
            return 0;
        }
        if (!diskOp->sync()) {
            diskOp->abort();
            return 0;
        }
        if (!diskOp->end()) {
            return 0;
        }
        return size;
    }
}


@end
