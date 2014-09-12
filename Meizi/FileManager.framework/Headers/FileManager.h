//
//  FileManager.h
//  FileManager
//
//  Created by guowei huang on 12-3-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//
/*
 使用说明
 1.该头文件中的方法，路径都是绝对路径。
 2.如果文件或文件夹是存放在Documents下，请使用FileManager+Documents中的相应方法；
 3.如果文件或文件夹是存放在Library下，请使用FileManager+Library中的相应方法；
 4.如果文件或文件夹是存放在其他目录下，请先获取绝对路径，再使用该头文件中的相应方法。
 5.copy,move文件或文件夹时，目标路径要添加一个自己命名的文件或文件夹名称。
 如copy文件a.txt到目录b/中，
 [FileManager copyFile:@".../a.txt" toPath:@".../b"];无法copy成功，应该给所copy的文件取个名字，如b.txt
 [FileManager copyFile:@".../a.txt" toPath:@".../b/b.txt"];
 
 如move文件夹dir1到目录dir2/中，
 [FileManager moveFile:@".../dir1" toPath:@".../dir2"];无法move成功，应该给所move的文件夹取个名字，如dir3
 [FileManager moveFile:@".../dir1" toPath:@".../dir2/dir3"];
 */

#import <Foundation/Foundation.h>
#define COMBINE_DIRECTORY(M_DIR,FILE_NAME) [M_DIR stringByAppendingPathComponent:FILE_NAME] 

@interface FileManager : NSObject

//获取版本号
+(NSString *)getSDKVersion;
/*
 创建目录
 dirPath----------目录路径
 */
+(BOOL)createDir:(NSString *)dirPath;

/*
 删除目录或文件
 dirPath-----------目录路径
 */
+(BOOL)deleteDirOrFile:(NSString *)dirPath;

/*
 拷贝文件
 filePathSrc--------源文件路径
 filePathDst--------目标文件路径
 */
+(BOOL)copyFile:(NSString *)filePathSrc toPath:(NSString *)filePathDst;

//移动目录或文件
+(BOOL)moveFile:(NSString *)filePathSrc toPath:(NSString *)filePathDst;

//写文件--删除原有内容，还是在原有内容上追加;写入的内容格式，是NSData,NSString,NSArray,NSDictionary
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)writeData:(NSData *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)writeString:(NSString *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)writeArray:(NSArray *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)writeDictionary:(NSDictionary *)data toFile:(NSString *)filePath;

/*
 追加文件内容
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)appendData:(NSData *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)appendString:(NSString *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)appendArray:(NSArray *)data toFile:(NSString *)filePath;
/*
 写文件
 data---------------写入的文件数据
 filePath-----------文件路径
 */
+(BOOL)appendDictionary:(NSDictionary *)data toFile:(NSString *)filePath;
//读文件内容---读出的内容格式，是NSData,NSString,NSArray,NSDictionary
/*
 读文件内容
 data---------------读出的文件内容
 filePath-----------文件路径
 */
+(BOOL)readData:(NSMutableData *)data fromFile:(NSString *)filePath;
/*
 读文件内容
 data---------------读出的文件内容
 filePath-----------文件路径
 */
+(BOOL)readString:(NSMutableString *)data fromFile:(NSString *)filePath;
/*
 读文件内容
 data---------------读出的文件内容
 filePath-----------文件路径
 */
+(BOOL)readArray:(NSMutableArray *)data fromFile:(NSString *)filePath;
/*
 读文件内容
 data---------------读出的文件内容
 filePath-----------文件路径
 */
+(BOOL)readDictionary:(NSMutableDictionary *)data fromFile:(NSString *)filePath;

//目录是否存在
+(BOOL)isDirExists:(NSString *)dirPath;

//文件是否存在
+(BOOL)isFileExists:(NSString *)filePath;
@end
