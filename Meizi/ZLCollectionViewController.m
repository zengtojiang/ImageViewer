//
//  ZLCollectionViewController.m
//  Meizi
//
//  Created by mac  on 12-12-20.
//  Copyright (c) 2012年 icow. All rights reserved.
//

#import "ZLCollectionViewController.h"

@interface ZLCollectionViewController ()

@end

@implementation ZLCollectionViewController
@synthesize managedObjectContext, fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        theFlowLayout=[[UICollectionViewFlowLayout alloc] init];
        
    }
    return self;
}

-(void)dealloc{
    [theFlowLayout release];
    [managedObjectContext release];
    [fetchedResultsController release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    theCollectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ZLSCREEN_WIDTH, ZLSCREEN_HEIGHT-20) collectionViewLayout:theFlowLayout];
    theCollectionView.delegate=self;
    theCollectionView.dataSource=self;
    [self.view addSubview:theCollectionView];
    [theCollectionView release];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRefreshState:(BOOL)refresh{
    
}

-(void)onReceiveImageData:(UIImage *)img ofRequest:(ZLRequest *)request{
    
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
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity"
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchLimit:60];
        
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Entity"
                                              inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    /*
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
    
	[theCollectionView reloadData];
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

#pragma mark - UICollectionDataSource required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger num=0;
    if ([[self.fetchedResultsController sections] count]>0)
    {
        id<NSFetchedResultsSectionInfo> current=[[self.fetchedResultsController sections] objectAtIndex:section];
        num=[current numberOfObjects];
    }
    return num ;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

#pragma mark - UICollectionViewDataSource optional
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self.fetchedResultsController sections] count];
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
/*
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
}
 */

#pragma mark - UICollectionViewDelegate optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
}

#pragma mark - UICollectionViewDelegateFlowLayout optional

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ZLSCREEN_WIDTH/2, 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5,5,5,5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}
@end
