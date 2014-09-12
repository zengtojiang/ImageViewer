//
//  ZLRequest.h
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ZLRequestDelegate;

@interface ZLRequest : NSObject
{
    NSString *url;
    NSIndexPath *index;
    id<ZLRequestDelegate> delegate;
}

@property(nonatomic,retain)NSIndexPath *index;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)id<ZLRequestDelegate> delegate;
@end
@protocol ZLRequestDelegate<NSObject>

-(void)onReceiveImage:(UIImage *)img withRequest:(ZLRequest *)request;
@optional
-(void)onFaild:(ZLRequest *)request;

@end

