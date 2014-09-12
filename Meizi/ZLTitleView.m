//
//  ZLTitleView.m
//  Meizi
//
//  Created by mac  on 12-12-13.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLTitleView.h"

@implementation ZLTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor blackColor];
        self.alpha=0.5f;
        titleLabel=[[UILabel alloc] initWithFrame:self.bounds];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.font=[UIFont boldSystemFontOfSize:24.f];
        [self addSubview:titleLabel];
        [titleLabel release];
        
        
        pageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
        pageLabel.textAlignment=NSTextAlignmentCenter;
        pageLabel.backgroundColor=[UIColor clearColor];
        pageLabel.textColor=[UIColor whiteColor];
        pageLabel.font=[UIFont boldSystemFontOfSize:12.f];
        [self addSubview:pageLabel];
        [pageLabel release];
        
        
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

-(void)setPageTitle:(NSString *)title{
    if (title)
    {
        titleLabel.text=title;
    }
    else{
        titleLabel.text=@"";
    }
}

-(void)setPageIndex:(NSString *)page{
    if (page)
    {
        pageLabel.text=page;
    }
    else{
        pageLabel.text=@"";
    }
}

@end
