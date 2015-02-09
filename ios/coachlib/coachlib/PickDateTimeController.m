//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "PickDateTimeController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "GTableView.h"
#import "SelectionCell.h"
#import "ThemeManager.h"

@implementation PickDateTimeController

+(UIImage*)highlightedImage:(UIImage*)image withColor:(UIColor*)color {
    CIImage *beginImage = [CIImage imageWithCGImage:[image CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    [filter setDefaults]; // 3
    [filter setValue:beginImage forKey:kCIInputImageKey];
    
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [filter setValue:[CIVector vectorWithX:red Y:green Z:blue W:0] forKey:@"inputBiasVector"];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg scale:image.scale orientation:UIImageOrientationUp];
    CFRelease(cgimg);
    return newImg;
}

-(void)configureFromContent {
    [super configureFromContent];
    
    self.alarmDestination = [self.content getExtraString:@"alarmDestination"];
    self.alarmAction = [self.content getExtraString:@"alarmAction"];
    self.alarmBody = [self.content getExtraString:@"alarmBody"];
    self.alarmInfo = [self.content getExtraString:@"alarmInfo"];
    
    self.itemContent = [self.content getChildByName:@"@item"];
    self.defaultValue = [self.content getExtraString:@"defaultValue"];
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    self.alarmSelectionVariable = [self.content getExtraString:@"alarmSelectionVariable"];
    self.useDuration = [self.content getExtraBoolean:@"duration"];
    self.dateOnly = [self.content getExtraBoolean:@"dateOnly"];
    self.timeOnly = [self.content getExtraBoolean:@"timeOnly"];
    self.futureOnly = [self.content getExtraBoolean:@"futureOnly"];
    self.alarmID = self.alarmSelectionVariable ? (NSString*)[self getVariable:self.alarmSelectionVariable] : nil;
    
    if (!self.useDuration) {
        if (!self.defaultValue || ![self.defaultValue isEqualToString:@"nil"]) {
            NSDate *date = (NSDate*)[self getVariable:self.selectionVariable];
            if (!date) date = [NSDate date];
            [self setVariable:self.selectionVariable to:date];
        }
    } else {
        NSNumber *duration = (NSNumber*)[self getVariable:self.selectionVariable];
        if (duration) [self setVariable:self.selectionVariable to:duration];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

/*
 - (void)unsetAlarm {
 if (!self.alarmSelectionVariable || !self.alarmID) return;
 
 UILocalNotification *n = [[iStressLessAppDelegate instance] getLocalNotificationWithID:self.alarmID];
 if (n) [[UIApplication sharedApplication] cancelLocalNotification:n];
 
 [self setVariable:self.alarmSelectionVariable to:[NSNull null]];
 
 self.alarmID = nil;
 
 [UIAlertView alertViewWithTitle:@"Alarm Cancelled" message:@"This alarm has been cancelled."];
 }

 
- (void)setAlarm {
    NSDate *date = (NSDate*)[self getVariable:self.selectionVariable];
    if (!date) {
        [self unsetAlarm];
        return;
    }

    BOOL wasSet = self.alarmID ? TRUE : FALSE;

    NSManagedObject *binding = (NSManagedObject*)[super getVariable:@"@binding"];
    if (!binding) {
        NSLog(@"no binding");
        return;
    }

    UILocalNotification *n = [[UILocalNotification alloc] init];
    NSString *appName = [[iStressLessAppDelegate instance] getContentTextWithName:@"APP_NAME"];

    self.alarmID = [[binding.objectID URIRepresentation] absoluteString];
    [self setVariable:self.alarmSelectionVariable to:self.alarmID];
    
    n.fireDate = date;
    n.timeZone = [NSTimeZone defaultTimeZone];
    n.alertBody = [NSString stringWithFormat:self.alarmBody,appName];
    n.alertAction = self.alarmAction;
    n.userInfo = @{
                   @"id" : self.alarmID,
                   @"destination" : self.alarmDestination ? self.alarmDestination : @"",
                   @"info" : self.alarmInfo ? self.alarmInfo : @""
                   };
    
    [[iStressLessAppDelegate instance] rescheduleLocalNotification:n];
    [n release];
    
    if (!wasSet) {
        [UIAlertView alertViewWithTitle:@"Alarm Set" message:@"An alarm has been set for this due date."];
    }
}
*/

- (void)unsetAlarm {
    if (!self.alarmSelectionVariable || !self.alarmID) return;
    [self setVariable:self.alarmSelectionVariable to:[NSNull null]];
    self.alarmID = nil;
    [UIAlertView alertViewWithTitle:@"Alarm Cancelled" message:@"This alarm has been cancelled."];
}

- (void)setAlarm {
    NSDate *date = (NSDate*)[self getVariable:self.selectionVariable];
    if (!date) {
        [self unsetAlarm];
        return;
    }
    
    BOOL wasSet = self.alarmID ? TRUE : FALSE;
    self.alarmID = self.alarmDestination;
    [self setVariable:self.alarmSelectionVariable to:self.alarmID];
    if (!wasSet) {
        [UIAlertView alertViewWithTitle:@"Alarm Set" message:@"An alarm has been set for this due date."];
    }
}

- (void)clockTapped {
    if (self.alarmID) {
        [self unsetAlarm];
    } else {
        [self setAlarm];
    }
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    SelectionCell *scell = nil;
    UILabel *label = cell.textLabel;
    if ([cell isKindOfClass:[SelectionCell class]]) {
        scell = (SelectionCell*)cell;
        UIImage *clockImage = [UIImage imageNamed:@"alarm_clock"];
        if (self.alarmID) {
            clockImage = [PickDateTimeController highlightedImage:clockImage withColor:[UIColor blueColor]];
            scell.selectionButton.accessibilityValue = @"alarm set";
        } else {
            scell.selectionButton.accessibilityValue = @"alarm not set";
        }
        [scell.selectionButton setImage:clockImage forState:UIControlStateNormal];
        [scell.selectionButton setImage:clockImage forState:UIControlStateHighlighted];
        [scell.selectionButton setImage:clockImage forState:UIControlStateSelected];
        
        UIImage *buttonNormal = [[UIImage imageNamed:@"filter_bar"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        UIImage *buttonPressed = [[UIImage imageNamed:@"filter_bar_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [scell.selectionButton setBackgroundImage:buttonNormal forState:UIControlStateNormal];
        [scell.selectionButton setBackgroundImage:buttonPressed forState:UIControlStateHighlighted];
        [scell.selectionButton setBackgroundImage:buttonNormal forState:UIControlStateSelected];
        
//        [scell.selectionButton setImage:clockImage forState:UIControlStateHighlighted];
        [scell.selectionButton addTarget:self action:@selector(clockTapped) forControlEvents:UIControlEventTouchUpInside];
        scell.selectionButton.enabled = TRUE;
        scell.selectionButton.userInteractionEnabled = TRUE;
        label = scell.titleLabel;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
//        [cell.contentView.layer setNeedsDisplay];
//        [cell.contentView.layer setNeedsLayout];
        cell.accessibilityTraits = UIAccessibilityTraitButton;
    } else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"listTextFont"];
	float fontSize = [theme floatForName:@"listTextSize"];
	UIColor *textColor = [theme colorForName:@"listTextColor"];
	UIColor *bgColor = [theme colorForName:@"listBackgroundColor"];
    
	label.textColor = textColor;
	cell.backgroundColor = bgColor;
    label.minimumFontSize = fontSize*2/3;
    label.font = [UIFont fontWithName:fontName size:fontSize];
    label.adjustsFontSizeToFitWidth = TRUE;
    
    NSObject *value = [self getVariable:self.selectionVariable];
    if (!value) {
        label.text = self.itemContent.displayName;
    } else {
        if (self.useDuration) {
            NSNumber *duration = (NSNumber*)value;
            int d = [duration intValue];
            int hours = d / (60*60);
            int minutes = (d - (hours * 60*60))/60;
            if (hours >= 2) {
                label.text = [NSString stringWithFormat:@"%d hours %d minutes",hours, minutes];
            } else if (hours == 1) {
                label.text = [NSString stringWithFormat:@"1 hour %d minutes",minutes];
            } else {
                label.text = [NSString stringWithFormat:@"%d minutes",minutes];
            }
        } else {
            NSDate *date = (NSDate*)value;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if (self.dateOnly) {
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            } else if (self.self.timeOnly) {
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            } else {
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            }
            label.text = [dateFormatter stringFromDate:date];
            [dateFormatter release];
        }
    }
    cell.shouldIndentWhileEditing = NO;
}

-(UITableView *)createTableView {
    GTableView *tv = (GTableView*)[super createTableView];
    tv.marginBottom = 10;
    return tv;
}

- (void)contentBecameVisible {
    [self.tableView reloadData];
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}

- (IBAction)dateAction:(id)sender
{
    if (self.useDuration) {
        NSNumber *duration = [NSNumber numberWithInt:self.picker.countDownDuration];
        [self setVariable:self.selectionVariable to:duration];
    } else {
        NSDate *date = self.picker.date;
        [self setVariable:self.selectionVariable to:date];
        if (self.alarmID) [self setAlarm];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
}

-(void)removePicker {
	if (!self.pickerView.superview) return;
    
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = self.pickerView.frame;
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	// start the slide down animation
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
    self.pickerView.frame = endFrame;
	[UIView commitAnimations];
	
	// grow the table back again in vertical size to make room for the date picker
	CGRect newFrame = self.tableView.frame;
	newFrame.size.height += self.pickerView.frame.size.height;
	self.tableView.frame = newFrame;
}

- (IBAction)doneAction:(id)sender
{
    [self dateAction:sender];
    
    [self removePicker];
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removePicker];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
    if (self.alarmSelectionVariable) {
        NSArray *a = [[NSBundle mainBundle] loadNibNamed:@"SelectionCell" owner:self options:nil];
        return [[a objectAtIndex:0] retain];
    } else {
        return [super createCell:typeIdentifier];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.pickerView) {
        self.picker = [[[UIDatePicker alloc] init] autorelease];
        if (self.useDuration) self.picker.datePickerMode = UIDatePickerModeCountDownTimer;
        else if (self.dateOnly) self.picker.datePickerMode = UIDatePickerModeDate;
        else if (self.timeOnly) self.picker.datePickerMode = UIDatePickerModeTime;
        
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.picker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height+44);
        self.pickerView = [[[UIView alloc] initWithFrame:startRect] autorelease];
        self.pickerView.opaque = TRUE;
        self.pickerView.backgroundColor = [UIColor whiteColor];

		CGRect r = startRect;
        r.origin.y = 0;
        r.size.height = 44;
        UIImageView *bg = [[UIImageView alloc] initWithFrame:r];
        bg.image = [UIImage imageNamed:@"split_bar.png"];
        [self.pickerView addSubview:bg];
        [bg release];

        startRect.origin.y = 44;
        startRect.size.height -= 44;
        self.picker.frame = startRect;
        [self.pickerView addSubview:self.picker];
        
        [self.picker addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventValueChanged];
        
        if (self.futureOnly) {
            if (self.dateOnly) {
                NSDateComponents *additionalDay = [[NSDateComponents alloc] init];
                [additionalDay setDay:1];
                NSCalendar *cal = [NSCalendar currentCalendar];
                self.picker.minimumDate = [cal dateByAddingComponents:additionalDay toDate:[NSDate date] options:0];
                [additionalDay release];
            } else {
                self.picker.minimumDate = [NSDate date];
            }
        }

        ButtonModel *button = [ButtonModel button];
        button.label = @"Done";
        button.onClickBlock = ^{
            [self doneAction:nil];
        };
        UIView *bv = button.buttonView;
        r.origin.x = r.size.width - (bv.frame.size.width+10);
        r.size.width = bv.frame.size.width+10;
        r = CGRectInset(r, 5, 5);
        bv.frame = r;
        [self.pickerView addSubview:bv];
        self.pickerView.accessibilityViewIsModal = true;
        self.doneButton = button;
    }

    if (self.useDuration) {
        NSNumber *duration = (NSNumber*)[self getVariable:self.selectionVariable];
        self.picker.countDownDuration = [duration intValue];
    } else {
        NSDate *date = (NSDate*)[self getVariable:self.selectionVariable];
        if (!date) date = [NSDate date];
        self.picker.date = date;
    }

	// check if our date picker is already on screen
	if (self.pickerView.superview == nil)
	{
		[self.view.window addSubview: self.pickerView];
		
		// size up the picker view to our screen and compute the start/end frame origin for our slide up animation
		//
		// compute the start frame
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		
		// compute the end frame
		CGRect pickerRect = self.pickerView.frame;
        pickerRect.origin.y = screenRect.origin.y + screenRect.size.height - pickerRect.size.height;
        
		// start the slide up animation
		[UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
		
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
		
        self.pickerView.frame = pickerRect;
		
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.pickerView.frame.size.height;
        self.tableView.frame = newFrame;
		[UIView commitAnimations];
        
		// add the "Done" button to the nav bar
//		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [self.pickerView accessibilityElementAtIndex:0]);
}

@end
