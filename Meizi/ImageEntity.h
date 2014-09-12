//
//  ImageEntity.h
//  Meizi
//
//  Created by mac  on 12-12-13.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageEntity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, copy) NSString * guid;
@property (nonatomic, copy) NSString * url;
@property (nonatomic, copy) NSString * title;

@end
