//
//  ZLZoomImageView.m
//  Meizi
//
//  Created by mac  on 13-2-20.
//  Copyright (c) 2013年 icow. All rights reserved.
//

#import "ZLZoomImageView.h"

@implementation ZLZoomImageView
@synthesize imageView;


-(void)dealloc{
    //[imageView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumZoomScale=5.0;
        self.minimumZoomScale=1.0;
        self.bouncesZoom=YES;
        self.delegate=self;
        imageView=[[ZLImagePageView alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,self.frame.size.height)];
        imageView.autoresizingMask=UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        [imageView release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (imageView.hasImage) {
        return imageView;
    }
    return nil;
}

@end
