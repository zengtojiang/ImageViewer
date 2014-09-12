//
//  ZLRootViewController.h
//  EarthQuake
//
//  Created by mac  on 12-12-2.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLAppDelegate.h"
#import "ZLRequest.h"
#import "ZLTitleView.h"

@interface ZLRootViewController : UIViewController <NSFetchedResultsControllerDelegate,UIScrollViewDelegate,ZLRequestDelegate>
{
    UIScrollView    *theScrollView;
    NSString        *theGuid;
    //ZLTitleView     *titleView;
    BOOL            navigationbarHidden;
    ZLAppDelegate   *theAppDelegate;
    UIToolbar       *theToolbar;
    UIBarButtonItem *pageItem;
@private
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,copy)NSString *theGuid;

//-(void)setRefreshState:(BOOL)refresh;

//-(void)onReceiveImageData:(UIImage *)img ofRequest:(ZLRequest *)request;
@end
