//
//  ZLImageCell.m
//  Meizi
//
//  Created by mac  on 12-12-11.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLImageCell.h"

@implementation ZLImageCell
//@synthesize imageUrl;
@synthesize request;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor blackColor];
        cellImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ZLSCREEN_WIDTH, ZLSCREEN_HEIGHT-70)];
        [self.contentView addSubview:cellImage];
        [cellImage release];
        
        request=[[ZLRequest alloc] init];
    }
    return self;
}

-(void)dealloc{
    [request release];
    //[imageUrl release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellImage:(UIImage *)img{
    if (img)
    {
        cellImage.image=img;
    }
}

@end
