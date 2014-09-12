//
//  ZLImagePageView.h
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLRequest.h"

@interface ZLImagePageView : UIControl
{
    UIImageView *pageImage;
    ZLRequest   *request;
    BOOL        hasImage;
    UIActivityIndicatorView *activity;
}
@property(nonatomic,retain)ZLRequest   *request;
@property(nonatomic,assign)BOOL hasImage;
//@property(nonatomic,readonly)UIImageView *pageImage;
-(void)setPageImage:(UIImage *)image;

@end
