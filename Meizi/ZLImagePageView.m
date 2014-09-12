//
//  ZLImagePageView.m
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLImagePageView.h"

@interface ZLImagePageView() {
    CGFloat vWidth;
    CGFloat vHeight;
    CGFloat vMatch;
}

@end

@implementation ZLImagePageView
@synthesize request;
@synthesize hasImage;
//@synthesize pageImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        
        pageImage=[[UIImageView alloc] initWithFrame:self.bounds];
        pageImage.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        pageImage.center=self.center;
        pageImage.backgroundColor=[UIColor clearColor];
        [self addSubview:pageImage];
        [pageImage release];
        vWidth=frame.size.width;
        vHeight=frame.size.height;
        vMatch=vWidth/vHeight;
        
        activity=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        //activity.center=self.center;
        [self addSubview:activity];
         activity.center=CGPointMake(vWidth/2, vHeight/2);
        [activity release];
        [activity startAnimating];
        
        request=[[ZLRequest alloc] init];
        hasImage=NO;
        
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

-(void)dealloc{
    [request release];
    [super dealloc];
}

-(void)setPageImage:(UIImage *)image{
    if (image)
    {
        [activity stopAnimating];
        hasImage=YES;
        CGFloat fWidth;
        CGFloat fHeight;
        
        CGFloat oWidth=image.size.width;
        CGFloat oHeight=image.size.height;
        CGFloat oMatch=oWidth/oHeight;
        if (oMatch>=vMatch)
        {
            fWidth=vWidth;
            fHeight=fWidth/oMatch;
        }
        else{
            fHeight=vHeight;
            fWidth=fHeight*oMatch;
        }
        pageImage.frame=CGRectMake((vWidth-fWidth)/2, (vHeight-fHeight)/2, fWidth, fHeight);
        pageImage.image=image;
    }
}

@end
