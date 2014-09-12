//
//  Entity.h
//  Meizi
//
//  Created by mac  on 12-12-21.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, copy) NSString * guid;
@property (nonatomic, copy) NSString * pics;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * weblink;
@property (nonatomic, copy) NSString * picItem;

@end
