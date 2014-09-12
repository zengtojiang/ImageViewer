//
//  ZLCollectionViewController.h
//  Meizi
//
//  Created by mac  on 12-12-20.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLRequest.h"

@interface ZLCollectionViewController : UIViewController<NSFetchedResultsControllerDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView  *theCollectionView;
    UICollectionViewFlowLayout *theFlowLayout;
@private
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(void)setRefreshState:(BOOL)refresh;

-(void)onReceiveImageData:(UIImage *)img ofRequest:(ZLRequest *)request;
@end
