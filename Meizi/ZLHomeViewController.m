//
//  ZLHomeViewController.m
//  Meizi
//
//  Created by mac  on 13-1-19.
//  Copyright (c) 2013年 icow. All rights reserved.
//

#import "ZLHomeViewController.h"
#import "ZLAppDelegate.h"
#import "ImageEntity.h"
#import "ZLRootViewController.h"

@interface ZLHomeViewController ()

@end

@implementation ZLHomeViewController
@synthesize managedObjectContext, fetchedResultsController;
@synthesize twoWeeksAgo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [twoWeeksAgo release];
    [refreshBar release];
    [activityBar release];
    [super dealloc];
}

/**
 *  嵌入应用推荐界面对象中实现Delegate
 */
- (UIViewController *)viewControllerForPresentingModalView{
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.frame=CGRectMake(0, -20, ZLSCREEN_WIDTH, ZLSCREEN_HEIGHT);//[[UIScreen mainScreen] bounds];
    //NSLog(@"homeViewController:%@",NSStringFromCGRect(self.view.frame));
    self.view.backgroundColor=ZL_BG_COLOR;//[UIColor colorWithRed:0x44/0xff green:0x55/0xff blue:0x66/0xff alpha:1.0];
	// Do any additional setup after loading the view.
    self.navigationItem.title=@"考拉美图";
    //self.navigationItem.titleView
    UIBarButtonItem *backBar=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem=backBar;
    [backBar release];
    if (refreshBar==nil)
    {
        refreshBar=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(onRefresh)];
    }
    
    if (activityBar==nil)
    {
        UIActivityIndicatorView *act=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [act startAnimating];
        activityBar=[[UIBarButtonItem alloc] initWithCustomView:act];
        [act release];
    }
    
    self.navigationItem.rightBarButtonItem=refreshBar;
    
    //MobiSageRecommendView *recomendView2 = [[MobiSageRecommendView alloc] initWithDelegate:self andImg:nil];
    //调整荐计划按钮位置
    //self.navigationItem.leftBarButtonItem=adBar;
    //[adBar release];
    //[recomendView2 release];
    
    theTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, -20,ZLSCREEN_WIDTH ,self.view.frame.size.height+20) style:UITableViewStylePlain];
    theTableView.autoresizingMask=UIViewAutoresizingFlexibleHeight;
    theTableView.separatorColor=[UIColor lightGrayColor];//[UIColor colorWithRed:252.0/255 green:33.0/255 blue:94.0/255 alpha:.8];
    theTableView.backgroundColor=[UIColor clearColor];
    theTableView.delegate=self;
    theTableView.dataSource=self;
    [self.view addSubview:theTableView];
    [theTableView release];
    
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ZLSCREEN_WIDTH, 44+20)];
    headView.backgroundColor=[UIColor clearColor];
    theTableView.tableHeaderView=headView;
    [headView release];
    
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-14];  // 14 days back from today
    self.twoWeeksAgo = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    [offsetComponents release];
    [gregorian release];
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
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // [UIApplication sharedApplication].statusBarHidden=NO;
    // self.navigationController.navigationBarHidden=NO;
}

-(void)onRefresh
{
    ZLAppDelegate *appDelegate=(ZLAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate onRefreshData];
}

-(void)setRefreshState:(BOOL)refresh
{
    self.navigationItem.rightBarButtonItem=refresh?activityBar:refreshBar;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = refresh;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    activityBar=nil;
    refreshBar=nil;
    theTableView=nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

// The number of rows is equal to the number of earthquakes in the array.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZLTRACE(@"");
    NSInteger numberOfRows = 0;
    if ([[fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.f;
}

// The cell uses a custom layout, but otherwise has standard behavior for UITableViewCell.
// In these cases, it's preferable to modify the view hierarchy of the cell's content view, rather
// than subclassing. Instead, view "tags" are used to identify specific controls, such as labels,
// image views, etc.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLTRACE(@"");
    
	static NSString *kEarthquakeCellID = @"EarthquakeCellID";
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEarthquakeCellID];
	if (cell == nil) {
        // No reusable cell was available, so we create a new cell and configure its subviews.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kEarthquakeCellID] autorelease];
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.textColor=ZL_TEXT_COLOR;//[UIColor whiteColor];
        //cell.backgroundView=nil;
        //cell.backgroundColor=[UIColor brownColor];
       // cell.contentView.backgroundColor=[UIColor brownColor];
        //cell.textLabel.backgroundColor=[UIColor clearColor];
        //cell.accessoryView.backgroundColor=[UIColor clearColor];
    }
    NSDictionary *imageItem=[fetchedResultsController objectAtIndexPath:indexPath];
   // NSLog(@"shuju:%@",imageItem);
    // get the specific earthquake for this row
    //ImageEntity *earthquake = (ImageEntity *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=[imageItem objectForKey:@"title"];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *imageItem=[fetchedResultsController objectAtIndexPath:indexPath];
   // int num=
    //NSLog(@"num:%@",[imageItem objectForKey:@"num"]);
    ZLRootViewController *itemController = [[ZLRootViewController alloc] init];
    itemController.managedObjectContext = self.managedObjectContext;
    itemController.theGuid=[imageItem objectForKey:@"guid"];
    itemController.navigationItem.title=[imageItem objectForKey:@"title"];
    //[UIApplication sharedApplication].statusBarHidden=YES;
    [self.navigationController pushViewController:itemController animated:YES];
    [itemController release];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor =ZL_BG_COLOR;
}
#pragma mark -
#pragma mark Core Data

- (NSFetchedResultsController *)fetchedResultsController {
    ZLTRACE(@"");
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageEntity"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        /*
        NSExpression * titleExpression = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"url"]]];
        NSExpressionDescription * titleExpressionDescription = [[NSExpressionDescription alloc] init];
        [titleExpressionDescription setExpression:titleExpression];
        [titleExpressionDescription setExpressionResultType:NSDoubleAttributeType];
        [titleExpressionDescription setName:@"num"];
         */
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setPropertiesToGroupBy:[NSArray arrayWithObjects:
                                              @"guid",@"title",nil]];
        [fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"guid",@"title",nil]];
        //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:titleExpressionDescription,@"guid",@"title",nil]];
        //[titleExpressionDescription release];
        [fetchRequest setResultType:NSDictionaryResultType];
        
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
        [sortDescriptor release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
}

// this is called from mergeChanges: method,
// requested to be made on the main thread so we can update our table with our new earthquake objects
//
- (void)updateContext:(NSNotification *)notification
{
	NSManagedObjectContext *mainContext = [self managedObjectContext];
	[mainContext mergeChangesFromContextDidSaveNotification:notification];
    
    // keep our number of earthquakes to a manageable level, remove earthquakes older than 2 weeks
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageEntity"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date < %@", self.twoWeeksAgo];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *olderEarthquakes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    ImageEntity *earthquake;
    for (earthquake in olderEarthquakes) {
        [self.managedObjectContext deleteObject:earthquake];
    }
    
    // update our fetched results after the merge
    //
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
	[theTableView reloadData];
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
}

@end
