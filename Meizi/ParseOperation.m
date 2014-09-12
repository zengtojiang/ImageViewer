/*
 
 */

#import "ParseOperation.h"
#import "Entity.h"
#import "ImageEntity.h"
#import "ZLAppDelegate.h"

// NSNotification name for reporting errors
NSString *kParseEntityErrorNotif = @"ParseEntityErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kParseErrorMsgKey = @"ParseEntityErrorMsgKey";


@interface ParseOperation () <NSXMLParserDelegate>
    @property (nonatomic, retain) Entity *currentParseItem;
    @property (nonatomic, retain) NSMutableArray *currentParseBatch;
    @property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
    @property (nonatomic,retain) NSMutableArray* imgArray;
@end

@implementation ParseOperation

@synthesize currentParseItem, currentParsedCharacterData, currentParseBatch, managedObjectContext;
@synthesize imgArray;

-(id)initWithURLPath:(NSString *)path mode:(int)mode{
    if(self=[super init]){
        rssPath=[path copy];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
       // [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        //Tue, 11 Dec 2012 18:12:08 +0800 
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzzz"];
        
        // setup our Core Data scratch pad and persistent store
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self.managedObjectContext setUndoManager:nil];
        
        ZLAppDelegate *appDelegate = (ZLAppDelegate *)[[UIApplication sharedApplication] delegate];
        [self.managedObjectContext setPersistentStoreCoordinator:appDelegate.persistentStoreCoordinator];
        self.imgArray=[NSMutableArray array];
        parsedItemCounter = 0;
    }
    return self;
}
// a batch of earthquakes are ready to be added
- (void)addParsedItemsToList:(NSArray *)entityItems {
    assert([NSThread isMainThread]);
    //Entity
    /*
    NSFetchRequest *fetchEntityRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent1 = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];
    fetchEntityRequest.entity = ent1;
    // narrow the fetch to these two properties
    fetchEntityRequest.propertiesToFetch = [NSArray arrayWithObjects:@"guid", @"date", nil];
     */
    //IageEntity
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"ImageEntity" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = ent;
   
    // narrow the fetch to these two properties
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"url", @"date", nil];
    NSEntityDescription *entDesc = [NSEntityDescription entityForName:@"ImageEntity" inManagedObjectContext:self.managedObjectContext];
    // before adding the earthquake, first check if there's a duplicate in the backing store
    NSError *error = nil;
    for (Entity *entityItem in entityItems) {
        NSDate *itemDate=entityItem.date;
        NSString *guid=entityItem.guid;
        NSString *pictures=entityItem.pics;
        NSString *title=entityItem.title;
        //Insert Entity
        /*
        fetchEntityRequest.predicate = [NSPredicate predicateWithFormat:@"guid = %@ AND date = %@", guid, itemDate];
        
        NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchEntityRequest error:&error];
        if (fetchedItems.count == 0) {
            // we found no duplicate earthquakes, so insert this new one
            [self.managedObjectContext insertObject:entityItem];
        }
         */
        //Insert ImageEntity
       // ZLTRACE(@"date:%@ guid:%@ pics:%@",itemDate,guid,pictures);
        if (pictures&&pictures.length>0)
        {
            NSArray *picArray=[pictures componentsSeparatedByString:@"#"];
            for (NSString * picItem in picArray)
            {
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url = %@ AND date = %@", picItem, itemDate];
                
                NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                if (fetchedItems.count == 0) {
                    // create an earthquake managed object, but don't insert it in our moc yet
                    ImageEntity *entity = [[ImageEntity alloc] initWithEntity:entDesc insertIntoManagedObjectContext:nil];
                    entity.date=itemDate;
                    entity.guid=guid;
                    entity.url=picItem;
                    entity.title=title;
                    [self.managedObjectContext insertObject:entity];
                    [entity release];

                }

            }
        }
    }

    [fetchRequest release];
    
    if (![managedObjectContext save:&error]) {
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
     
// the main function for this NSOperation, to start the parsing
- (void)main {
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    //
    //To suppress the leak in NSXMLParser
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
	NSURL *url = [NSURL URLWithString:rssPath];
    NSData *data=[NSData dataWithContentsOfURL:url];
    
    //NSString *str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //ZLTRACE(@"#####data:%@##",str);
    //[str release];
     
    if (data&&[data length]>0)
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        [parser parse];
        
        // depending on the total number of earthquakes parsed, the last batch might not have been a
        // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
        // the array and, if necessary, send it to the main thread.
        //
        // first check if the operation has been cancelled, proceed if not
        //
        if (![self isCancelled]) {
            if ([self.currentParseBatch count] > 0) {
                [self performSelectorOnMainThread:@selector(addParsedItemsToList:)
                                       withObject:self.currentParseBatch
                                    waitUntilDone:NO];
            }
        }
        self.currentParseBatch = nil;
        self.currentParseItem = nil;
        self.currentParsedCharacterData = nil;
        [parser release];
    }
    else{
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:@"网络不可用"
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        
        [self performSelectorOnMainThread:@selector(handleError:)
                               withObject:noConnectionError
                            waitUntilDone:NO];

    }
}

- (void)dealloc {
    [rssPath release];
    
    [currentParseItem release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    [dateFormatter release];
    [imgArray release];
    [managedObjectContext release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Parser constants

// Limit the number of parsed earthquakes to 100
// (a given day may have more than 100 earthquakes around the world, so we only take the first 100)
//
static const NSUInteger kMaximumNumberOfItemsToParse = 100;

// When an Earthquake object has been fully constructed, it must be passed to the main thread and
// the table view in RootViewController must be reloaded to display it. It is not efficient to do
// this for every Earthquake object - the overhead in communicating between the threads and reloading
// the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the
// constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
//
static NSUInteger const kSizeOfItemsBatch = 20;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"item";
static NSString * const kLinkElementName = @"link";
static NSString * const kTitleElementName = @"title";
static NSString * const kPubDateElementName = @"pubDate";
static NSString * const kContentElementName = @"description";//@"content";
//static NSString * const kContentElement_Name=@"content";
static NSString * const kGUIDElementName = @"guid";


#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                       qualifiedName:(NSString *)qName
                                          attributes:(NSDictionary *)attributeDict {
   // ZLTRACE(@"elementName:%@ parsedCount:%d",elementName,parsedItemCounter);
    // If the number of parsed earthquakes is greater than
    // kMaximumNumberOfItemsToParse, abort the parse.
    //
    if (parsedItemCounter >= kMaximumNumberOfItemsToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        //
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kEntryElementName]) {
        // insert new earthquake entities as we discover them
        NSEntityDescription *ent = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];
        
        // create an earthquake managed object, but don't insert it in our moc yet
        Entity *entity = [[Entity alloc] initWithEntity:ent insertIntoManagedObjectContext:nil];
        self.currentParseItem = entity;
        [entity release];
        
    }else if ([elementName isEqualToString:kTitleElementName] ||
              [elementName isEqualToString:kLinkElementName]||
              [elementName isEqualToString:kGUIDElementName]||
              [elementName isEqualToString:kContentElementName]||
              [elementName isEqualToString:kPubDateElementName]) {
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
        if ([elementName isEqualToString:kContentElementName]) {
            [self.imgArray removeAllObjects];
        }
    }
    else{
         [currentParsedCharacterData setString:@""];
       // accumulatingParsedCharacterData = NO;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                      namespaceURI:(NSString *)namespaceURI
                                     qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kEntryElementName]) {
        // note: we keep a temporary array of managed objects while we are parsing.
        // We do this to avoid inserting objects into our moc ahead of time, just in case we find duplicate earthquakes
        //ZLTRACE(@"title:%@ link:%@ picks:%@ guid:%@ date:%@",self.currentParseItem.title,self.currentParseItem.weblink,self.currentParseItem.pics,self.currentParseItem.guid,self.currentParseItem.date);
        [self.currentParseBatch addObject:self.currentParseItem];
        
        parsedItemCounter++;
        if ([self.currentParseBatch count] >= kMaximumNumberOfItemsToParse) {
            [self performSelectorOnMainThread:@selector(addParsedItemsToList:)
                                   withObject:self.currentParseBatch
                                waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }

    } else if ([elementName isEqualToString:kTitleElementName]) {
        if (self.currentParseItem != nil) {
        self.currentParseItem.title=currentParsedCharacterData;
        }
    } else if ([elementName isEqualToString:kPubDateElementName]) {
        
        if (self.currentParseItem != nil) {
            //ZLTRACE(@"####currentData:%@ date",self.currentParsedCharacterData);
            self.currentParseItem.date =
            [dateFormatter dateFromString:self.currentParsedCharacterData];
           //ZLTRACE(@"$$$2$$$title:%@ link:%@ picks:%@ guid:%@ date:%@",self.currentParseItem.title,self.currentParseItem.weblink,self.currentParseItem.pics,self.currentParseItem.guid,self.currentParseItem.date);
        }
    } else if ([elementName isEqualToString:kLinkElementName]) {
        
        if (self.currentParseItem != nil) {
            self.currentParseItem.weblink =currentParsedCharacterData;
        }
    } else if ([elementName isEqualToString:kGUIDElementName]) {
        
        if (self.currentParseItem != nil) {
            self.currentParseItem.guid =currentParsedCharacterData;
        }
    }else if ([elementName isEqualToString:kContentElementName]) {
        if (self.currentParseItem != nil&&self.currentParsedCharacterData!=nil)
        {
            NSArray *arr=[self.currentParsedCharacterData componentsSeparatedByString:@"\""];
           // ZLTRACE(@"######arrray:%@",arr);
            for (NSString *item in arr)
            {
                if ([item hasPrefix:@"http://"]&&[item hasSuffix:@"jpg"])
                {
                    [self.imgArray addObject:item ];
                }
            }
        }
        if ([self.imgArray count])
        {
            //[self.imgArray removeObject:@"http://pic.yupoo.com/fotomag/Bl4vOcGk/F8RzA.jpg"];
            self.currentParseItem.picItem=[self.imgArray objectAtIndex:0];
            self.currentParseItem.pics=[self.imgArray componentsJoinedByString:@"#"];
            //ZLTRACE(@"pics#####:%@",self.currentParseItem.pics);
            [self.imgArray removeAllObjects];
        }
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

// an error occurred while parsing the earthquake data,
// post the error as an NSNotification to our app delegate.
// 
- (void)handleError:(NSError *)parseError {
     ZLTRACE(@"%@",parseError);
    [[NSNotificationCenter defaultCenter] postNotificationName:kParseEntityErrorNotif
                                                    object:self
                                                  userInfo:[NSDictionary dictionaryWithObject:parseError
                                                                                       forKey:kParseErrorMsgKey]];
}

// an error occurred while parsing the earthquake data,
// pass the error to the main thread for handling.
// (note: don't report an error if we aborted the parse due to a max limit of earthquakes)
//
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
     ZLTRACE(@"%@",parseError);
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !didAbortParsing)
    {
        [self performSelectorOnMainThread:@selector(handleError:)
                               withObject:parseError
                            waitUntilDone:NO];
    }
}

@end
