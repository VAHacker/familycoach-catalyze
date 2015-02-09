//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "PickPackingListController.h"
#import "QuestionInstance.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"
#import "GTableView.h"

@implementation PickPackingListController

-(void) addNextButton {
}

-(void) addChoices {    
    NSMutableArray *choices = [[NSMutableArray alloc] init];
    NSArray *children = [self getChildContentList];
    for (int i=0;i<[children count];i++) {
        NSManagedObject *mo = [children objectAtIndex:i];
        [choices addObject:[mo valueForKey:@"displayName"]];
    }
    
	NSString *storeAs = [self.content getExtraString:@"storeAs"];

	questionInstance = [[QuestionInstance alloc] initWithPlayer:nil andID:storeAs];
	[questionInstance setChoicesWithStrings:choices];
	questionInstance.viewCon = nil;
	questionInstance.maxAnswers = INT_MAX;
	questionInstance.minAnswers = 0;

    if (storeAs) {
        NSString *list = [[iStressLessAppDelegate instance] getSetting:storeAs];
        if (list) {
            NSArray *ids = [list componentsSeparatedByString:@"|"];
            for (int i=0;i<[ids count];i++) {
                NSString *idAsString = [ids objectAtIndex:i];
                [questionInstance selectItem:idAsString];
            }
        }
    }

    //	[viewCon addQuestion:questionInstance];
	
//	UIView *label = [viewCon createLabel:[NSString stringWithCString:question]];
    
    #define ROW_HEIGHT 40
//    questionInstance.headerView = label;
    CGRect bounds = [self.contentView bounds];
    CGRect tableFrame = bounds;
    tableFrame.origin.y += 10;
    tableFrame.size.height = 10+ROW_HEIGHT*[choices count];
    UITableView *table = [[GTableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
        table.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    }
    [table setDelegate:questionInstance];
    [table setDataSource:questionInstance];
    table.rowHeight = ROW_HEIGHT;
    table.opaque = FALSE;
    table.backgroundColor = [UIColor clearColor];
    table.backgroundView = nil;
    table.scrollEnabled = NO;
    [self.dynamicView addSubview:table];
    [table release];
    [choices release];
	//[questionInstance release];
//	[label release];
    
}

-(void) configureFromContent {
	[super configureFromContent];
    [self addChoices];
/*
	NSString *s = [[self nextContent] valueForKey:@"displayName"];
	if (!s) s = @"Next";
	[self addButton:BUTTON_ADVANCE_EXERCISE withText:s];
*/ 
}

@end
