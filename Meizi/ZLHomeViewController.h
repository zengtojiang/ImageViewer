//
//  ZLHomeViewController.h
//  Meizi
//
//  Created by mac  on 13-1-19.
//  Copyright (c) 2013年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLRequest.h"

@interface ZLHomeViewController : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *theTableView;
    
    UIBarButtonItem *refreshBar;
    UIBarButtonItem *activityBar;
@private
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    
    NSDate *twoWeeksAgo;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *twoWeeksAgo;
-(void)setRefreshState:(BOOL)refresh;


//-(void)onReceiveImageData:(UIImage *)img ofRequest:(ZLRequest *)request;
@end
