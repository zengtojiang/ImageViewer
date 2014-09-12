//
//  ZLRootViewController.m
//  EarthQuake
//
//  Created by mac  on 12-12-2.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLRootViewController.h"
#import "Entity.h"
#import "ImageEntity.h"
#import "ZLAppDelegate.h"
#import "ZLImageCell.h"
#import "ZLImagePageView.h"
#import "ZLZoomImageView.h"


@interface ZLNSSortDescriptor:NSSortDescriptor

@end

@implementation ZLNSSortDescriptor
- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2{
    NSString *aString=((ImageEntity *)object1).url;
    NSString *bString=((ImageEntity *)object2).url;
    ZLTRACE(@"string1:%@ string2:%@",aString,bString);
    int date1=[[[[[aString componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    
    int date2=[[[[[bString componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    ZLTRACE(@"index1:%d index2 :%d",date1,date2);
    if (date1>date2) {
        return NSOrderedDescending;
    }
    return NSOrderedAscending;
}

@end

@interface ZLRootViewController (){
    CGFloat mainWidth;
    CGFloat mainHeight;
    int     pageCount;
    int     currentPage;
}
-(void)onRefresh;

-(void)toggleHideNavigationBar;
@end

#define IMAGEVIEW_TAG_INDEX_BASE 100

@implementation ZLRootViewController

@synthesize managedObjectContext, fetchedResultsController;
@synthesize theGuid;

-(id)init{
    if (self=[super init])
    {
        theAppDelegate=(ZLAppDelegate *)[UIApplication sharedApplication].delegate;
        mainWidth=ZLSCREEN_WIDTH;
        mainHeight=ZLSCREEN_HEIGHT;
    }
    return self;
}

-(void)dealloc
{
    
    for (int i=0; i<pageCount; i++) {
        ZLZoomImageView *theZoomView=(ZLZoomImageView *)[theScrollView viewWithTag:i+IMAGEVIEW_TAG_INDEX_BASE];
        if (theZoomView!=nil) {
            ZLImagePageView *theImageView=theZoomView.imageView;
            if (theImageView!=nil) {
                theImageView.request.delegate=nil;
            }
        }
    }
    [fetchedResultsController release];
	[managedObjectContext release];
    [theGuid release];
    [super dealloc];
}

-(void)toggleHideNavigationBar{
    if (pageCount) {
        navigationbarHidden=!navigationbarHidden;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:.3];
        [[UIApplication sharedApplication] setStatusBarHidden:navigationbarHidden withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:navigationbarHidden animated:NO];
        theScrollView.frame=CGRectMake(0, navigationbarHidden?0:-20, mainWidth, mainHeight);
        theToolbar.frame=CGRectMake(0, navigationbarHidden?(mainHeight):(mainHeight-44-20), mainWidth, 44);
        [UIView commitAnimations];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=ZL_BG_COLOR;
    //self.view.frame=[[UIScreen mainScreen] bounds];
   // NSLog(@"RootViewController:%@",NSStringFromCGRect(self.view.frame));
    theScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, -20, mainWidth, mainHeight)];
    theScrollView.delegate=self;
    [self.view addSubview:theScrollView];
    theScrollView.pagingEnabled=YES;
    //theScrollView.alwaysBounceHorizontal=YES;
    theScrollView.showsHorizontalScrollIndicator=NO;
    theScrollView.showsVerticalScrollIndicator=NO;
    theScrollView.backgroundColor=ZL_BG_COLOR;
    //theScrollView.backgroundColor=[UIColor blackColor];
    theScrollView.maximumZoomScale=3;
    theScrollView.minimumZoomScale=1;
    theScrollView.bouncesZoom=YES;
    [theScrollView release];
    
    theToolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, mainHeight-44-20, mainWidth, 44)];
    //theToolbar.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    //theToolbar.barStyle=UIBarStyleBlack;
    theToolbar.tintColor=ZL_BAR_COLOR;
    //theToolbar.tintColor=[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
    [theToolbar setTranslucent:YES];
    UIBarButtonItem *saveBar =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSave)];
    
    UIBarButtonItem *spaceBar=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    pageItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    UIBarButtonItem *weiboBar=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    [theToolbar setItems:[NSArray arrayWithObjects:saveBar,spaceBar,pageItem,spaceBar,weiboBar, nil]];
    [saveBar release];
    [spaceBar release];
    [weiboBar release];
    [pageItem release];
    //titleView=[[ZLTitleView alloc] initWithFrame:CGRectMake(0, ZLSCREEN_HEIGHT-60, mainWidth, 60)];
    [self.view addSubview:theToolbar];
    [theToolbar release];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
   // self.tableView.rowHeight = 64;
    
    NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        ZLTRACE(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    [self reloadScrollView];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self toggleHideNavigationBar];
}
-(void)onRefresh
{
    ZLAppDelegate *appDelegate=(ZLAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate onRefreshData];
}

#pragma mark - ZLRequestDelegate
-(void)onReceiveImage:(UIImage *)img withRequest:(ZLRequest *)request{
//-(void)onReceiveImageData:(UIImage *)data ofRequest:(ZLRequest *)request{
    //ZLImagePageView *view=(ZLImagePageView *)[theScrollView viewWithTag:request.index.row];
    ZLTRACE(@"index:%d",request.index.row);
    ZLZoomImageView *scrollView=(ZLZoomImageView *)[theScrollView viewWithTag:request.index.row];
    if (scrollView) {
        ZLImagePageView *view=scrollView.imageView;
        if (view&&img&&[request.url isEqualToString:view.request.url])
        {
            ZLTRACE(@"set image");
            [view setPageImage:img];
        }
    }
}

-(void)onSave{
    if (pageCount==0) {
        return;
    }
    ZLZoomImageView *scrollView=(ZLZoomImageView *)[theScrollView viewWithTag:IMAGEVIEW_TAG_INDEX_BASE+currentPage];
    if (scrollView) {
        ZLImagePageView *picItem=scrollView.imageView;
        UIImage *imgData=[theAppDelegate getImageDataWithRequest:picItem.request];
        if (imgData)
        {
            UIImageWriteToSavedPhotosAlbum(imgData, nil, nil, nil);
        }
    }
    /*
    ZLImagePageView *picItem=(ZLImagePageView *)[theScrollView viewWithTag:IMAGEVIEW_TAG_INDEX_BASE+currentPage];
    UIImage *imgData=[theAppDelegate getImageDataWithRequest:picItem.request];
    if (imgData)
    {
        UIImageWriteToSavedPhotosAlbum(imgData, nil, nil, nil);
    }
     */
}

-(void)onCompose{
    if (pageCount==0) {
        return;
    }
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        ZLTRACE(@"available");
        ImageEntity *entity=[fetchedResultsController.fetchedObjects objectAtIndex:currentPage];
        SLComposeViewController *scc=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        [scc setInitialText:[NSString stringWithFormat:@"%@",entity.title]];
        //[scc setInitialText:[NSString stringWithFormat:@"%@\n链接：%@",entity.title,entity.url]];
        ZLZoomImageView *scrollView=(ZLZoomImageView *)[theScrollView viewWithTag:IMAGEVIEW_TAG_INDEX_BASE+currentPage];
        if (scrollView) {
            ZLImagePageView *picItem=scrollView.imageView;
            UIImage *imgData=[theAppDelegate getImageDataWithRequest:picItem.request];
            if (imgData)
            {
               [scc addImage:imgData];
            }
        }
        /*
        ZLImagePageView *picItem=(ZLImagePageView *)[theScrollView viewWithTag:IMAGEVIEW_TAG_INDEX_BASE+currentPage];
        UIImage *imgData=[theAppDelegate getImageDataWithRequest:picItem.request];
        if (imgData)
        {
              [scc addImage:imgData];
        }
         */
        [scc setCompletionHandler:^(SLComposeViewControllerResult result){
            if (result==SLComposeViewControllerResultDone) {
                ZLTRACE(@"send weibo success");
            }else if(result==SLComposeViewControllerResultCancelled){
                ZLTRACE(@"send weibo cancelled");
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            //ZLTRACE([NSString stringWithFormat:@"weibo result %d",result]);
        }];
        [self presentViewController:scc animated:YES completion:nil];
        
    }else{
        UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"" message:@"请先在\"设置\"中设置您的新浪微博账号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    theScrollView=nil;
    theToolbar=nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    theScrollView=nil;
    theToolbar=nil;
}


-(void)reloadScrollView{
    ZLTRACE(@"");
    NSArray *array=fetchedResultsController.fetchedObjects;
    if (array&&[array count])
    {
        for (UIView *subView in theScrollView.subviews)
        {
            [subView removeFromSuperview];
        }
        currentPage=0;
            
        pageCount=[array count];
        ZLTRACE(@"count:%d",pageCount);
        [theScrollView setContentSize:CGSizeMake(pageCount*mainWidth, mainHeight)];
        for (int i=0; i<pageCount; i++)
        {
             ZLTRACE(@"insert:%d",i);
            ImageEntity *entity=[array objectAtIndex:i];
            ZLZoomImageView *zoomImage=[[ZLZoomImageView alloc] initWithFrame:CGRectMake(i*mainWidth, 0, mainWidth, mainHeight)];
            zoomImage.tag=i+IMAGEVIEW_TAG_INDEX_BASE;
            zoomImage.imageView.request.url=entity.url;
            zoomImage.imageView.request.delegate=self;
            zoomImage.imageView.request.index=[NSIndexPath indexPathForRow:i+IMAGEVIEW_TAG_INDEX_BASE inSection:0];
            [zoomImage.imageView addTarget:self action:@selector(toggleHideNavigationBar) forControlEvents:UIControlEventTouchUpInside];
            [theScrollView addSubview:zoomImage];
            [zoomImage release];
            /*
            ZLImagePageView *image=[[ZLImagePageView alloc] initWithFrame:CGRectMake(i*mainWidth, 0, mainWidth, mainHeight)];
            image.tag=i+IMAGEVIEW_TAG_INDEX_BASE;
            image.request.url=entity.url;
            image.request.delegate=self;
            image.request.index=[NSIndexPath indexPathForRow:i+IMAGEVIEW_TAG_INDEX_BASE inSection:0];
            [theScrollView addSubview:image];
            [image addTarget:self action:@selector(toggleHideNavigationBar) forControlEvents:UIControlEventTouchUpInside];
            [image release];
             */
        }
        [self onChangePage:0];
        theScrollView.contentOffset=CGPointMake(currentPage*mainWidth, 0);
    }
}


-(void)onChangePage:(int)_pageIndex
{
    ZLTRACE(@"page1:%d page2:%d",currentPage,_pageIndex);
    ZLZoomImageView *imagescroll0=(ZLZoomImageView *)[theScrollView viewWithTag:currentPage];
    if (imagescroll0) {
        [imagescroll0 setZoomScale:1.0 animated:YES];
    }
    currentPage=_pageIndex;
    pageItem.title=[NSString stringWithFormat:@"%d/%d",currentPage+1,pageCount];
    for (int i=IMAGEVIEW_TAG_INDEX_BASE+currentPage; i<=IMAGEVIEW_TAG_INDEX_BASE+currentPage+3; i++)
    {
        //ZLImagePageView *picItem=(ZLImagePageView *)[theScrollView viewWithTag:i];
        ZLZoomImageView *imagescroll=(ZLZoomImageView *)[theScrollView viewWithTag:i];
        ZLImagePageView *picItem=imagescroll.imageView;
        if (picItem&&!picItem.hasImage)
        {
            ZLTRACE(@"index:%d url:%@",i,picItem.request.url);
            UIImage *imgData=[theAppDelegate getImageDataWithRequest:picItem.request];
            if (imgData)
            {
                [picItem setPageImage:imgData];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int page = floor((scrollView.contentOffset.x - mainWidth / 2) / mainWidth) + 1;
    if (page!=currentPage&&page<pageCount&&page>=0)
    {
        [self onChangePage:page];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

#pragma mark -
#pragma mark Core Data

- (NSFetchedResultsController *)fetchedResultsController {
    ZLTRACE(@"");
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        ZLTRACE(@"1");
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageEntity"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"guid = %@", theGuid]];
        // Edit the sort key as appropriate.
        ZLTRACE(@"GUID:%@###",theGuid);
        ZLNSSortDescriptor *sortDescriptor = [[ZLNSSortDescriptor alloc] initWithKey:@"url" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptor release];
        [sortDescriptors release];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:managedObjectContext
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        
    }
	
	return fetchedResultsController;
}

// this is called from mergeChanges: method,
// requested to be made on the main thread so we can update our table with our new earthquake objects
//
/*
- (void)updateContext:(NSNotification *)notification
{
    
	NSManagedObjectContext *mainContext = [self managedObjectContext];
	[mainContext mergeChangesFromContextDidSaveNotification:notification];
    
    // keep our number of earthquakes to a manageable level, remove earthquakes older than 2 weeks
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageEntity"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
     NSError *error = nil;
 
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", self.twoWeeksAgo];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *olderEarthquakes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    Entity *earthquake;
    for (earthquake in olderEarthquakes) {
        [self.managedObjectContext deleteObject:earthquake];
    }
    */
    // update our fetched results after the merge
    //
/*
	if (![self.fetchedResultsController performFetch:&error]) {
		// Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful
        // during development. If it is not possible to recover from the error, display an alert
        // panel that instructs the user to quit the application by pressing the Home button.
        //
        ZLTRACE(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
    [fetchRequest release];
     
	[self reloadScrollView];
}

// this is called via observing "NSManagedObjectContextDidSaveNotification" from our ParseOperation
- (void)mergeChanges:(NSNotification *)notification {
    
    ZLTRACE(@"mergeChanges");
    [self setRefreshState:NO];
	NSManagedObjectContext *mainContext = [self managedObjectContext];
    if ([notification object] == mainContext) {
        // main context save, no need to perform the merge
        return;
    }
    [self performSelectorOnMainThread:@selector(updateContext:) withObject:notification waitUntilDone:YES];
}*/
@end
