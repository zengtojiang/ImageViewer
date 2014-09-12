//
//  ZLAppDelegate.h
//  Meizi
//
//  Created by mac  on 12-12-7.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLRequest.h"

@class ZLHomeViewController;

@interface ZLAppDelegate : UIResponder <UIApplicationDelegate>{
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSMutableDictionary    *imageDict;
    
    NSMutableArray         *loadingCache;
@private
    NSOperationQueue *parseQueue;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ZLHomeViewController *viewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)onRefreshData;

-(UIImage *)getImageDataWithRequest:(ZLRequest *)request;

@end
