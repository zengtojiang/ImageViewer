//
//  FileManager+Library.h
//  FileManager
//
//  Created by guowei huang on 12-3-13.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "FileManager.h"
#define LIBRARY_DIRECTORY 	[NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]]

@interface FileManager(Library)
/*
 创建目录
 dirName----------目录名
 */
+(BOOL)createDirInLibrary:(NSString *)dirName;

/*
 删除目录或文件
 dirName-----------目录,文件名
 */
+(BOOL)deleteDirOrFileInLibrary:(NSString *)dirName;

/*
 拷贝文件
 fileNameSrc--------源文件名
 fileNameDst--------目标文件名
 */
+(BOOL)copyFileInLibrary:(NSString *)fileNameSrc toPath:(NSString *)fileNameDst;

//移动目录或文件
+(BOOL)moveFileInLibrary:(NSString *)fileNameSrc toPath:(NSString *)fileNameDst;

//写文件--删除原有内容，还是在原有内容上追加;写入的内容格式，是NSData,NSString,NSArray,NSDictionary
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)writeData:(NSData *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)writeString:(NSString *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)writeArray:(NSArray *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)writeDictionary:(NSDictionary *)data toFileInLibrary:(NSString *)fileName;

/*
 追加文件内容
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)appendData:(NSData *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)appendString:(NSString *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)appendArray:(NSArray *)data toFileInLibrary:(NSString *)fileName;
/*
 写文件
 data---------------写入的文件数据
 fileName-----------文件路径
 */
+(BOOL)appendDictionary:(NSDictionary *)data toFileInLibrary:(NSString *)fileName;
//读文件内容---读出的内容格式，是NSData,NSString,NSArray,NSDictionary
/*
 读文件内容
 data---------------读出的文件内容
 fileName-----------文件路径
 */
+(BOOL)readData:(NSMutableData *)data fromFileInLibrary:(NSString *)fileName;
/*
 读文件内容
 data---------------读出的文件内容
 fileName-----------文件路径
 */
+(BOOL)readString:(NSMutableString *)data fromFileInLibrary:(NSString *)fileName;
/*
 读文件内容
 data---------------读出的文件内容
 fileName-----------文件路径
 */
+(BOOL)readArray:(NSMutableArray *)data fromFileInLibrary:(NSString *)fileName;
/*
 读文件内容
 data---------------读出的文件内容
 fileName-----------文件路径
 */
+(BOOL)readDictionary:(NSMutableDictionary *)data fromFileInLibrary:(NSString *)fileName;

//目录是否存在
+(BOOL)isDirExistsInLibrary:(NSString *)dirName;

//文件是否存在
+(BOOL)isFileExistsInLibrary:(NSString *)fileName;
@end
