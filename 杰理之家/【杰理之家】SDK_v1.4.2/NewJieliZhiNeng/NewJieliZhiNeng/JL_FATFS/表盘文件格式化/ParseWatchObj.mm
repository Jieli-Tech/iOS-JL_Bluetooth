//
//  ParseWatchObj.m
//  Test
//
//  Created by EzioChan on 2020/12/9.
//  Copyright © 2020 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import "ParseWatchObj.h"
#include "packresformat.h"
#import <ZipZap/ZipZap.h>

//PackResFormat fmt;
//
//  QFile fin(argv[1]);
//  if (!fin.open(QIODevice::ReadOnly)) {
//      qDebug() << "open " << fin.fileName() << " err " << fin.errorString();
//      return 0;
//  }
//  auto buf = fin.readAll();
//
//  if (fmt.parse(buf.data(), buf.size())) {
//      auto &infos = fmt.infos();
//      for (auto &i : infos) {
//          qDebug() << QString::fromStdString(i.name) << ", " << i.offset << ", " << i.len;
//      }
//
//      // get file content
//      auto fileSize = fmt.getFileSize("ver"); // get file size of `ver`
//      if (fileSize != 0) {
//          auto fileBuf = std::unique_ptr<uint8_t[]>(new uint8_t[fileSize]);
//          if (fmt.getFileContent("ver", fileBuf.get(), fileSize) == fileSize) {
//              // read file content
//          } else {
//              // failed
//          }
//      }
//
//  } else {
//      // failed to parse file
//  }

static PackResFormat* prf = NULL;

@implementation ParseWatchObj

-(instancetype)init{
    if (self = [super init]) {
        if (!prf) {
            prf = new PackResFormat();
        }
    }
    return self;
}

-(NSMutableArray<WatchInfo *> *)analyzeWithPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableArray *infoArray = [NSMutableArray new];
    if (data) {
        bool p = prf->parse([data bytes], (size_t)data.length);
        if (p) {
            auto &infos = prf->infos();
            for (auto &i : infos) {
                WatchInfo *info = [WatchInfo new];
                info.name = [NSString stringWithCString:i.name.c_str() encoding:[NSString defaultCStringEncoding]];
                info.offset = i.offset;
                info.len = i.len;
                info.content = [self readFileContent:info.name];
                [infoArray addObject:info];
            }
            return infoArray;
        }else{
            NSLog(@"ParseWatchFile：parse Failed");
            return nil;
        }
    }else{
        NSLog(@"ParseWatchFile: Read local file failed");
        return nil;
    }
}


-(NSData *)readFileContent:(NSString *)fileName{
    auto fileSize = prf->getFileSize([fileName UTF8String]); // get file size of `ver`
    if (fileSize != 0) {
        auto fileBuf = std::unique_ptr<uint8_t[]>(new uint8_t[fileSize]);
        if (prf->getFileContent([fileName UTF8String], fileBuf.get(), fileSize) == fileSize) {
            NSData *data = [NSData dataWithBytes:fileBuf.get() length:fileSize];
            return data;
        } else {
            // failed
            NSLog(@"ParseWatchFile:read File Content failed");
        }
    }
    return nil;
}

-(void)dealloc{
    if (prf) {
        delete prf;
    }
}

-(BOOL)unArchiveFile:(NSString *)path saveToFold:(NSString *)path1{
    NSMutableArray *listArr = [NSMutableArray new];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ZZArchive* archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:path] error:&error];
    for (ZZArchiveEntry* entry in archive.entries)
    {
        NSString *fileNameStr = [[NSString alloc] initWithData:entry.rawFileName encoding:kCFStringEncodingUTF8];

        NSArray * arr = [fileNameStr componentsSeparatedByString:@"/"];
        NSInteger index = [fileNameStr length]-[[arr lastObject] length];
        NSString * aimPath = [fileNameStr substringToIndex:index];
        NSError * err;
        [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",path1,aimPath] withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
               
        }
        NSData * data = [entry newDataWithError:nil];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@",path1,fileNameStr] atomically:YES];
       
        //NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@",path1,fileNameStr];
        //NSLog(@"%@",fileNamePath);
        //NSMutableDictionary *fileDict = [[NSMutableDictionary alloc]init];
        //[fileDict setObject:fileNamePath forKey:@"filePath"];
        //[fileDict setObject:fileNameStr forKey:@"fileName"];
        [listArr addObject:fileNameStr];
    }
    return listArr;
}


@end

@implementation WatchInfo

@end
