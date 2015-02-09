//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "EMASchedulerController.h"
#import "iStressLessAppDelegate.h"

static NSString* daysOfWeek[] = {
    @"Sunday",
    @"Monday",
    @"Tuesday",
    @"Wednesday",
    @"Thursday",
    @"Friday",
    @"Saturday"
};

@implementation EMASchedulerController


-(void)privateInit {
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mma"];
    
    NSString *timeOfDayStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentTimeOfDay"];
    reminderTOD = [dateFormatter dateFromString:timeOfDayStr];
    [reminderTOD retain];
    
    NSString *dayOfWeekStr = [[iStressLessAppDelegate instance] getSetting:@"assessmentDayOfWeek"];
    dayOfWeek = [dayOfWeekStr intValue];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [AssessNavigationController scheduleDailyAndWeeklyRemindersAtTimeOfDay:reminderTOD onDayOfWeek:dayOfWeek];
}

-(UITableViewCell *)createCell:(NSString*)typeIdentifier NS_RETURNS_RETAINED {
	return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:typeIdentifier];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [managedObject valueForKey:@"displayName"];
    if ([indexPath row] == 0) {
        cell.detailTextLabel.text = [dateFormatter stringFromDate:reminderTOD];
    } else {
        cell.detailTextLabel.text = daysOfWeek[dayOfWeek];
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell *targetCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([indexPath row] == 0) {
        self.pickerView = [[[UIDatePicker alloc] init] autorelease];
        self.pickerView.datePickerMode = UIDatePickerModeTime;
        NSString *timeStr = targetCell.detailTextLabel.text;
        NSDate *time = [dateFormatter dateFromString:timeStr];
        self.pickerView.date = time;
        [self.pickerView sendAction:@selector(dateAction:) to:self forEvent:nil];
        
        [self.view.window addSubview:self.pickerView];
            
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        self.pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
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
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        self.dayPickerView = [[[UIPickerView alloc] init] autorelease];
        self.dayPickerView.dataSource = self;
        self.dayPickerView.delegate = self;
        self.dayPickerView.showsSelectionIndicator = TRUE;
        [self.dayPickerView selectRow:dayOfWeek inComponent:0 animated:FALSE];

        [self.view.window addSubview:self.dayPickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.dayPickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        self.dayPickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.dayPickerView.frame = pickerRect;
        
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.dayPickerView.frame.size.height;
        self.tableView.frame = newFrame;
        [UIView commitAnimations];
        
        // add the "Done" button to the nav bar
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDayAction:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
	
}

- (void)slideDownDidStop
{
    // the date picker has finished sliding downwards, so remove it
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
}

- (void)daySlideDownDidStop
{
    // the date picker has finished sliding downwards, so remove it
    [self.dayPickerView removeFromSuperview];
    self.dayPickerView = nil;
}

- (void)dateAction:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [reminderTOD release];
    reminderTOD = self.pickerView.date;
    [reminderTOD retain];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:reminderTOD];
}

- (void)doneAction:(id)sender
{
    [self dateAction:sender];
    
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
    
    // remove the "Done" button in the nav bar
    self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table row
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.tableView reloadData];
}

- (void)dayAction:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    dayOfWeek = [self.dayPickerView selectedRowInComponent:0];
    cell.detailTextLabel.text = daysOfWeek[dayOfWeek];
}

- (void)doneDayAction:(id)sender
{
    [self dayAction:sender];

    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGRect endFrame = self.dayPickerView.frame;
    endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
    
    // start the slide down animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    // we need to perform some post operations after the animation is complete
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(daySlideDownDidStop)];
    
    self.pickerView.frame = endFrame;
    [UIView commitAnimations];
    
    // grow the table back again in vertical size to make room for the date picker
    CGRect newFrame = self.tableView.frame;
    newFrame.size.height += self.dayPickerView.frame.size.height;
    self.tableView.frame = newFrame;
    
    // remove the "Done" button in the nav bar
    self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table row
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.tableView reloadData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 7;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return daysOfWeek[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self dayAction:pickerView];
}

-(void) dealloc {
    [dateFormatter release];
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    [self.dayPickerView removeFromSuperview];
    self.dayPickerView = nil;
    [reminderTOD release];

	[super dealloc];
}

@end
