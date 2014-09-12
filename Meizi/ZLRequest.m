//
//  ZLRequest.m
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLRequest.h"

@implementation ZLRequest
@synthesize url,index;
@synthesize delegate;

-(void)dealloc{
    [url release];
    [index release];
    [super dealloc];
}
@end
