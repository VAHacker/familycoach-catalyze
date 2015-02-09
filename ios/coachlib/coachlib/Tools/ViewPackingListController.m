//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "ViewPackingListController.h"
#import "NSManagedObject+MOExtensions.h"
#import "iStressLessAppDelegate.h"
#import "GTableView.h"
#import "ContactsListDelegate.h"
#import "QuestionInstance.h"


@implementation ViewPackingListController


-(void) configureFromContent {
	NSString *storeAs = [self.content getExtraString:@"storeAs"];

	[super configureFromContent];
    
    NSMutableArray *rsrcs = [[NSMutableArray alloc] init];

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
            GTableView *table = [[GTableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
            if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
                table.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
            }
            [table setDelegate:questionInstance];
            [table setDataSource:questionInstance];
//            table.rowHeight = ROW_HEIGHT;
            table.opaque = FALSE;
            table.backgroundColor = [UIColor clearColor];
            table.backgroundView = nil;
            table.scrollEnabled = NO;
            [self.dynamicView addSubview:table];
            [table release];
            [questionInstance release];
        }
    }
    self.toRelease = rsrcs;
    [rsrcs release];
}

@end
