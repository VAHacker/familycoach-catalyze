//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "PCLSchedulerController.h"
#import "iStressLessAppDelegate.h"
#import "QuestionnaireContentController.h"
#import "ThemeManager.h"

@implementation PCLSchedulerController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *scheduledSetting = [NSString stringWithFormat:@"%@Scheduled",self.seriesToSchedule];
	NSString *pclScheduled = [[iStressLessAppDelegate instance] getSetting:scheduledSetting];
	if (pclScheduled == nil) pclScheduled = @"none";
    NSString *key = [managedObject valueForKey:@"name"];
	cell.accessoryType = (pclScheduled && key && [pclScheduled isEqual:key]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = [managedObject valueForKey:@"displayName"];
}

-(void) updateNextAssessmentMsg {
    NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:self.seriesToSchedule];
    NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : [NSDate date];
    NSString *scheduledSetting = [NSString stringWithFormat:@"%@Scheduled",self.seriesToSchedule];
	NSString *interval = [[iStressLessAppDelegate instance] getSetting:scheduledSetting];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    NSString *nextTimeStr = @"Never";
    if (interval && (![interval isEqualToString:@"none"])) {
        NSDate *nextTime = [QuestionnaireContentController addDelta:interval toDate:lastTime];
        nextTimeStr = nextTime ? [dateFormatter stringFromDate:nextTime] : @"Never";
    }
    NSString *lastAssessmentMsg = [NSString stringWithFormat:@"Next assessment: <b>%@</b><br/>",nextTimeStr];
    [dateFormatter release];

    ThemeManager *theme = [ThemeManager sharedManager];
    NSString *fontName = [theme stringForName:@"textFont"];
    NSString *textLinkColor = [NSString stringWithFormat:@"#%@",[theme stringForName:@"textLinkColor"]];
    float textSize = [theme floatForName:@"textSize"];
    float textMultiplier = textSize / 12.0;

    CGSize maxImageSize = CGSizeMake(400,400);
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithFloat:textMultiplier], NSTextSizeMultiplierDocumentOption,
     [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
     fontName, DTDefaultFontFamily,
     [theme colorForName:@"textColor"], DTDefaultTextColor,
     textLinkColor, DTDefaultLinkColor,
     nil];

    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:[lastAssessmentMsg dataUsingEncoding:NSUTF8StringEncoding] options:options documentAttributes:NULL];
    
    self.nextAssessmentMsgView.attributedString = string;
    [self.dynamicView setNeedsLayout];
    [string release];
}

-(void) baselineConfigureFromContent {
	[super baselineConfigureFromContent];

    self.seriesToSchedule = [self.content getExtraString:@"seriesToSchedule"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSManagedObject *lastScoreObj = [QuestionnaireContentController getLastTimeSeriesEntry:self.seriesToSchedule];
	NSDate *lastTime = lastScoreObj ? (NSDate*)[lastScoreObj valueForKey:@"time"] : nil;
    NSString *lastTimeStr = lastTime ? [dateFormatter stringFromDate:lastTime] : @"Never";
    NSString *lastAssessmentMsg = [NSString stringWithFormat:@"Last assessment: <b>%@</b>",lastTimeStr];
    [self addText:lastAssessmentMsg];
    [dateFormatter release];
    
    self.nextAssessmentMsgView = (StyledTextView*)[self viewForHTML:@"Next assessment: <b>?</b><br/>"];
    [self.dynamicView addSubview:self.nextAssessmentMsgView];
    [self updateNextAssessmentMsg];
}

/*
-(void) configureFromContent {
	[super configureFromContent];
	CGRect bounds = [self.view bounds];
	CGRect tableFrame = bounds;
	tableFrame.origin.y += 10;
	UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
	tableFrame.size.height = 10 + 40*(int)[self tableView:table numberOfRowsInSection:0];
	table.frame = tableFrame;
	table.scrollEnabled = FALSE;
	[table setDelegate:self];
	[table setDataSource:self];
    table.backgroundView = nil;
	table.rowHeight = 40;
	table.opaque = FALSE;
	table.backgroundColor = [UIColor clearColor];
	[self.dynamicView addSubview:table];
	self.tableView = table;
}
 */

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *key = [managedObject valueForKey:@"name"];
    
    NSString *dest = [self.content getExtraString:@"destination"];
    if (!dest) dest = @"assess";
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dest,@"destination", nil];

	[QuestionnaireContentController scheduleAssessmentReminderFor:self.seriesToSchedule atInterval:key andUserInfo:dict];
    [self updateNextAssessmentMsg];
	[self.tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:FALSE];
	[self.tableView reloadData];
}

-(void) dealloc {
	[super dealloc];
}

@end
