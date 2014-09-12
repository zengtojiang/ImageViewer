//
//  ZLTitleView.h
//  Meizi
//
//  Created by mac  on 12-12-13.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZLTitleView : UIView
{
    UILabel *titleLabel;
    UILabel *pageLabel;
}

-(void)setPageTitle:(NSString *)title;
-(void)setPageIndex:(NSString *)page;
@end
