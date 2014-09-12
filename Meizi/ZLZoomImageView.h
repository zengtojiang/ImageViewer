//
//  ZLZoomImageView.h
//  Meizi
//
//  Created by mac  on 13-2-20.
//  Copyright (c) 2013年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLImagePageView.h"

@interface ZLZoomImageView : UIScrollView<UIScrollViewDelegate>
{
    ZLImagePageView *imageView;
}
@property(nonatomic,retain)ZLImagePageView *imageView;
@end
