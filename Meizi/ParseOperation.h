/*
 
 */

extern NSString *kParseEntityErrorNotif;
extern NSString *kParseErrorMsgKey;

@class Entity;

@interface ParseOperation : NSOperation {
    NSString *rssPath;

@private
    NSDateFormatter *dateFormatter;
    
    // these variables are used during parsing
    Entity *currentParseItem;
    NSMutableString *currentParsedCharacterData;
    NSMutableArray  *imgArray;
    
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
    NSUInteger parsedItemCounter;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (retain) NSManagedObjectContext *managedObjectContext;

-(id)initWithURLPath:(NSString *)path mode:(int)mode;
@end
