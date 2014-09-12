//
//  ZLImageCell.h
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLRequest.h"

@interface ZLImageCell : UITableViewCell
{
    UIImageView *cellImage;
    ZLRequest   *request;
   // NSString    *imageUrl;
}
@property(nonatomic,retain)ZLRequest   *request;

-(void)setCellImage:(UIImage *)img;
@end
