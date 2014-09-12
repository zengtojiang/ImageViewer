//
//  ZLAppDelegate.m
//  Meizi
//
//  Created by mac  on 12-12-7.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLAppDelegate.h"
#import "ParseOperation.h"
#import "ZLHomeViewController.h"
#import <FileManager/FileManager.h>
#import <FileManager/FileManager+Documents.h>

@interface ZLAppDelegate()

@property (nonatomic, retain) NSOperationQueue *parseQueue;
#define MAX_CACHE_IMAGE_COUNT   30
//缓存图片数量上限，到达该上限触发才清理
#define ZL_MAX_IMAGE_FILE_COUNT 200

//缓存视频数量上限，到达该上限触发才清理
//#define DP_MAX_VIDEO_FILE_COUNT 200

//缓存文件修改时间距当前时间大于规定时间的清理掉，单位秒
#define ZL_DELETE_IMAGE_CASHE_TIME     604800//七天7*24*60*60
@end

@implementation ZLAppDelegate
@synthesize parseQueue;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [_navigationController release];
    [parseQueue release];
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [imageDict release];
    [loadingCache release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kParseEntityErrorNotif object:nil];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleBlackTranslucent;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    imageDict=[[NSMutableDictionary alloc] initWithCapacity:60];
    loadingCache=[[NSMutableArray alloc] initWithCapacity:10];
    parseQueue = [NSOperationQueue new];
    [parseQueue setMaxConcurrentOperationCount:7];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    /*
     // Override point for customization after application launch.
     self.viewController = [[[ZLViewController alloc] initWithNibName:@"ZLViewController" bundle:nil] autorelease];
     self.viewController.managedObjectContext = self.managedObjectContext;
     self.window.rootViewController = self.viewController;
     [self.window makeKeyAndVisible];
     */
    // Override point for customization after application launch.
    
    self.viewController = [[[ZLHomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    self.viewController.managedObjectContext = self.managedObjectContext;
    self.navigationController=[[[UINavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    //NSLog(@"navigationcontroller:%@",NSStringFromCGRect(self.navigationController.view.frame));
    //self.navigationController.view.frame=[[UIScreen mainScreen] bounds];
    //self.navigationController.navigationBar.barStyle=UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor=ZL_BAR_COLOR;
    self.navigationController.navigationBar.translucent=YES;
    self.navigationController.view.backgroundColor=ZL_BG_COLOR;
    //self.navigationController.navigationBar.tintColor=[UIColor colorWithRed:68/255 green:85/255 blue:102/255 alpha:1.0];
   
    [self onRefreshData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parseError:)
                                                 name:kParseEntityErrorNotif
                                               object:nil];
    
    return YES;
}

-(void)onRefreshData{
    /*
   NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //[defaults setObject:[NSDate date] forKey:@"origindate"];
    //[defaults setInteger:0 forKey:@"mode"];
    int mode=0;
    if ([defaults integerForKey:@"mode"]==0) {
        NSDate *date1=[defaults objectForKey:@"origindate"];
        NSDate *date2=[NSDate date];
        if (date1!=nil) {
            if ([date2 timeIntervalSinceDate:date1]>=2*24*60*60) {
                mode=1;
                [defaults setInteger:1 forKey:@"mode"];
            }
        }
        else{
            [defaults setObject:[NSDate date] forKey:@"origindate"];
        }
    }else{
        mode=1;
    }
    [defaults synchronize];
     */
    //http://feed.feedsky.com/meizitu
    //@"http://feed.feedsky.com/leica";//@"http://feed.feedsky.com/midui";//@"http://feed.feedsky.com/meizitu";//@"http://fotomen.cn/feed/";//
    static NSString *feedURLStringLeica=@"http://feed.feedsky.com/midui/";
    
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithURLPath:feedURLStringLeica mode:0];
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
    
    // have our rootViewController observe the ParseOperation's save operation with its managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self.viewController
                                             selector:@selector(mergeChanges:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:parseOperation.managedObjectContext];
    
    [self.viewController setRefreshState:YES];
}

//清理旧文件
-(void)deleteOldFiles
{
    //创建文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    NSString *imagePath=[documentsDirectory stringByAppendingPathComponent:@"images"];
    
    NSArray *imagsArray = [fileManager contentsOfDirectoryAtPath:imagePath error:nil];
    if (imagsArray&&[imagsArray count]>ZL_MAX_IMAGE_FILE_COUNT)
    {
        //更改到待操作的目录下
        [fileManager changeCurrentDirectoryPath:[imagePath stringByExpandingTildeInPath]];
        for (NSString *pathItem in imagsArray)
        {
            NSDictionary *fileAtt=[fileManager attributesOfItemAtPath:pathItem error:nil];
            //NSDictionary *fileAtt=[fileManager attributesOfFileSystemForPath:pathItem error:nil];
            if (fileAtt)
            {
                //TRACE(@"fileattr:%@ \npath:%@",fileAtt,pathItem);
                NSDate *modidate=[fileAtt fileModificationDate];
                if (abs([modidate timeIntervalSinceNow])>ZL_DELETE_IMAGE_CASHE_TIME)
                {
                    [fileManager removeItemAtPath:[pathItem stringByExpandingTildeInPath] error:nil];
                }
            }
        }
    }
}

-(void)onReceiveFileData:(NSDictionary *)fileData{
    ZLTRACE(@"获取文件成功");
    if (fileData)
    {
        ZLRequest *request=[fileData objectForKey:@"request"];
        NSData   *data=[fileData objectForKey:@"data"];
        if (request)
        {
            [loadingCache removeObject:request.url];
            if (data)
            {
                UIImage *img=[UIImage imageWithData:data];
                if (img)
                {
                    if ([imageDict count]>=MAX_CACHE_IMAGE_COUNT)
                    {
                        [imageDict removeAllObjects];
                    }
                    [imageDict setObject:img forKey:request.url];
                    if (request.delegate!=nil&&[request.delegate respondsToSelector:@selector(onReceiveImage:withRequest:)]) {
                        [request.delegate onReceiveImage:img withRequest:request];
                    }
                    //[self.viewController onReceiveImageData:img ofRequest:request];
                }
            }
        }
    }
}

-(void)onFailedToLoadFile:(ZLRequest *)request{
    ZLTRACE(@"获取文件失败");
    [loadingCache removeObject:request.url];
    if (request.delegate!=nil&&[request.delegate respondsToSelector:@selector(onFaild:)]) {
        [request.delegate onFaild:request];
    }
}

-(UIImage *)getImageDataWithRequest:(ZLRequest *)request{
    ZLTRACE(@"url:%@",request.url);
    NSString *url=request.url;
    UIImage *imgData=[imageDict objectForKey:url];
    if (imgData!=nil)
    {
        ZLTRACE(@"从内存中获取图片");
        return imgData;
    }
    else{
        ZLTRACE(@"内存中没有");
        if ([loadingCache containsObject:url])
        {
            ZLTRACE(@"已经在请求文件");
            return nil;
        }
        else{
            [loadingCache addObject:url];
        }
        [self.parseQueue addOperationWithBlock:^(void){
            NSString *fileName=[NSString stringWithFormat:@"%d",url.hash];
            NSString *filepath=[self dpLocalImagePath:fileName];
            ZLTRACE(@"load file:%@",filepath);
            if (filepath&&[FileManager isFileExistsInDocument:filepath])
            {
                ZLTRACE(@"file path:%@ exists",filepath);
                NSMutableData *imgData=[[NSMutableData alloc] init];
                [FileManager readData:imgData fromFileInDocument:filepath];
                if (imgData&&imgData.length)
                {
                    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:request,@"request",imgData,@"data", nil];
                    [self performSelectorOnMainThread:@selector(onReceiveFileData:) withObject:dic waitUntilDone:NO];
                }
                else{
                    [self performSelectorOnMainThread:@selector(onFailedToLoadFile:) withObject:request waitUntilDone:NO];
                }
                [imgData release];
            }
            else
            {
                ZLTRACE(@"从网络获取");
                NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                if (data&&data.length)
                {
                    [FileManager writeData:data toFileInDocument:filepath];
                    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:request,@"request",data,@"data", nil];
                    [self performSelectorOnMainThread:@selector(onReceiveFileData:) withObject:dic waitUntilDone:NO];
                }
                else{
                    [self performSelectorOnMainThread:@selector(onFailedToLoadFile:) withObject:request waitUntilDone:NO];
                }
            }
        }];
    }
    ZLTRACE(@"end");
    return nil;
}


//获取本地文件位置
-(NSString *)dpLocalImagePath:(NSString *)imgurl
{
    BOOL dir=[FileManager isDirExistsInDocument:@"images"];
    if (!dir)
    {
        dir=[FileManager createDirInDocument:@"images"];
    }
    if (dir)
    {
        return [NSString stringWithFormat:@"images/%@",imgurl];
    }
    return nil;
}

- (void)applicationSignificantTimeChange:(UIApplication *)application{
    [self onRefreshData];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self deleteOldFiles];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    ZLTRACE(@"");
    [self onRefreshData];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful
            // during development. If it is not possible to recover from the error, display an alert
            // panel that instructs the user to quit the application by pressing the Home button.
            //
            ZLTRACE(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        }
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    if (imageDict)
    {
        [imageDict removeAllObjects];
    }
}

- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:nil
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"好"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    [self.viewController setRefreshState:NO];
}


// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)parseError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kParseErrorMsgKey]];
}

#pragma mark -
#pragma mark Core Data stack

// Returns the path to the application's documents directory.
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [NSManagedObjectContext new];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
//
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it
//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"NewModel.sqlite"];
	
	// set up the backing store
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:storePath]) {
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Model" ofType:@"sqlite"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
		}
	}
	
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        
        // Typical reasons for an error here include:
        // The persistent store is not accessible
        // The schema for the persistent store is incompatible with current managed object model
        // Check the error message to determine what the actual problem was.
        //
		ZLTRACE(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
    return persistentStoreCoordinator;
}

@end