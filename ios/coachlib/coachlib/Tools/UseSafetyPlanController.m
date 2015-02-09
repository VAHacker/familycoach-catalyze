//
//  RelaxationIntroController.m
//  iStressLess
//

/*
#import "UseSafetyPlanController.h"
#import "ManageSymptomsNavController.h"
#import "ContactsListDelegate.h"
#import "QuestionInstance.h"
#import "iStressLessAppDelegate.h"

@implementation UseSafetyPlanController

-(void) addNextButton {
} 

-(void) editTapped {
    BaseExerciseController *cvc = (BaseExerciseController*)[self getSiblingControllerWithName:@"@first"];
    cvc.exerciseContent = self.exerciseContent;
    [self.navigationController pushViewControllerAndRemoveOldOne:cvc];
}

-(void) configureFromContent {
	[super configureFromContent];
	
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTapped)] autorelease];

    NSMutableArray *rsrcs = [[NSMutableArray alloc] init];
    
    NSArray *a = [self getChildContentList];
    for (int i=0;i<a.count;i++) {
        NSManagedObject *mo = [a objectAtIndex:i];
        NSString *text = [mo valueForKey:@"mainText"];
        NSString *special = [mo valueForKey:@"special"];
        [self addText:text];
        if (special) {
            if ([special hasPrefix:@"contacts"]) {
                ContactsListDelegate *contactsList = [[ContactsListDelegate alloc] initWithStorageID:[special substringFromIndex:9] andAllowEditing:FALSE];
                contactsList.owner = self;
                [self.dynamicView addSubview:contactsList.tableView];
            } else if ([special hasPrefix:@"packing"]) {
                NSString *storeAs = [special substringFromIndex:8];
                                
                if (storeAs) {
                    NSString *list = [[iStressLessAppDelegate instance] getSetting:storeAs];
                    if (list) {
                        NSArray *ids = [list componentsSeparatedByString:@"|"];

                        QuestionInstance *questionInstance = [[QuestionInstance alloc] initWithPlayer:nil andID:nil];
                        [questionInstance setChoicesWithStrings:ids];
                        questionInstance.viewCon = nil;
                        questionInstance.maxAnswers = INT_MAX;
                        questionInstance.minAnswers = 0;
                        
                        [rsrcs addObject:questionInstance];
                        
                        #define ROW_HEIGHT 40
                        CGRect bounds = [self.contentView bounds];
                        CGRect tableFrame = bounds;
                        tableFrame.origin.y += 10;
                        tableFrame.size.height = 10+ROW_HEIGHT*[ids count];
                        UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
                        [table setDelegate:questionInstance];
                        [table setDataSource:questionInstance];
                        table.rowHeight = ROW_HEIGHT;
                        table.opaque = FALSE;
                        table.backgroundColor = [UIColor clearColor];	
                        table.scrollEnabled = NO;
                        [self.dynamicView addSubview:table];
                        [table release];
                    }
                }
            }
        }
    }
    
    toRelease = rsrcs;
    [self addThumbs];
}

-(void)dealloc {
    [super dealloc];
    [toRelease release];
}

@end
*/