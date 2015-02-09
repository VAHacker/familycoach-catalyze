//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "WellnessJournalController.h"
#import "SymptomRef.h"
#import "iStressLessAppDelegate.h"


@implementation WellnessJournalController

-(void)configureFromContent {
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SymptomRef"];
    [fetchRequest setFetchBatchSize:100];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:TRUE]]];
     
    self.filterByOptions = [udContext executeFetchRequest:fetchRequest error:NULL];

    [super configureFromContent];
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}

-(void)alarmPressed {
    [self navigateToNextContent:[self.content getChildByName:@"alarm"]];
}

-(void)removePicker {
    self.filterButton.selected = FALSE;
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

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removePicker];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *name = @"All";
    if (row > 0) {
        SymptomRef *filterBy = [self.filterByOptions objectAtIndex:row-1];
        name = filterBy.displayName;
        self.fetchPredicate = [NSPredicate predicateWithFormat:@"symptom == %@",filterBy];
    } else {
        self.fetchPredicate = nil;
    }

    self.fetchedResultsController.fetchRequest.predicate = self.fetchPredicate;
    [self.fetchedResultsController performFetch:NULL];
    [self.tableView reloadData];
    
    NSString *title = [NSString stringWithFormat:@"Show symptom: %@",name];
    [self.filterButton setTitle:title forState:UIControlStateNormal];
    [self.filterButton setTitle:title forState:UIControlStateHighlighted];
    [self.filterButton setTitle:title forState:UIControlStateSelected];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.filterByOptions.count+1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) return @"All";
    return ((SymptomRef*)[self.filterByOptions objectAtIndex:row-1]).displayName;
}

- (IBAction)doneAction:(id)sender
{
    [self removePicker];
	// deselect the current table row
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)filterPressed {
    if (self.filterButton.selected) {
        [self doneAction:nil];
        return;
    }
	if (!self.pickerView) {
        self.picker = [[[UIPickerView alloc] init] autorelease];
        self.picker.showsSelectionIndicator = TRUE;
        
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.picker sizeThatFits:CGSizeZero];
		CGRect startRect = CGRectMake(0.0,
									  screenRect.origin.y + screenRect.size.height,
									  pickerSize.width, pickerSize.height+44);
        self.pickerView = [[[UIView alloc] initWithFrame:startRect] autorelease];
        
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
        
        self.picker.delegate = self;
        self.picker.dataSource = self;
        
        ButtonModel *button = [ButtonModel button];
        button.label = @"Done";
        button.onClickBlock = ^{
            [self doneAction:nil];
        };
        self.doneButton = button;
        
        UIView *bv = button.buttonView;
        r.origin.x = r.size.width - (bv.frame.size.width+10);
        r.size.width = bv.frame.size.width+10;
        r = CGRectInset(r, 5, 5);
        bv.frame = r;
        [self.pickerView addSubview:bv];
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
        self.filterButton.selected = TRUE;
		
        // shrink the table vertical size to make room for the date picker
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.pickerView.frame.size.height;
        self.tableView.frame = newFrame;
		[UIView commitAnimations];
		
		// add the "Done" button to the nav bar
        //		self.navigationItem.rightBarButtonItem = self.doneButton;
	}
    
}

-(void)loadView {
    [super loadView];
    
    CGRect r = [[UIScreen mainScreen] bounds];
    UIView *container = [[[UIView alloc] initWithFrame:r] autorelease];

    CGRect filterBarRect = r;
    filterBarRect.size.height = 44;
    UIView *filterBar = [[[UIView alloc] initWithFrame:filterBarRect] autorelease];
    filterBar.autoresizesSubviews = TRUE;
    filterBar.autoresizingMask = UIViewAutoresizingNone;
    
    UIImage *buttonNormal = [[UIImage imageNamed:@"filter_bar"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    UIImage *buttonPressed = [[UIImage imageNamed:@"filter_bar_pressed"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    CGRect filterButtonRect = filterBarRect;
    filterButtonRect.size.width -= 44;

    UIImage *arrow = [UIImage imageNamed:@"down_disclosure"];
    UIImageView *arrowView = [[[UIImageView alloc] initWithImage:arrow] autorelease];
    arrowView.contentMode = UIViewContentModeScaleToFill;
    CGRect arrowRect = CGRectMake(r.size.width-44-39, 12, 25, 17);
    arrowView.frame = arrowRect;

    UIButton *button = [[[UIButton alloc] initWithFrame:filterButtonRect] autorelease];
    [button setBackgroundImage:buttonNormal forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressed forState:UIControlStateHighlighted];
    [button setBackgroundImage:buttonPressed forState:UIControlStateSelected];
    [button addSubview:arrowView];
    self.filterButton = button;
    [button setTitle:@"Show symptom: All" forState:UIControlStateNormal];
    [button setTitle:@"Show symptom: All" forState:UIControlStateHighlighted];
    [button setTitle:@"Show symptom: All" forState:UIControlStateSelected];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [filterBar addSubview:button];
    [button addTarget:self action:@selector(filterPressed) forControlEvents:UIControlEventTouchUpInside];

    UIImage *alarm = [[UIImage imageNamed:@"alarm_clock"] imageScaledToSize:CGSizeMake(32, 32)];
    
    filterButtonRect.origin.x = r.size.width-44;
    filterButtonRect.size.width = 44;
    button = [[[UIButton alloc] initWithFrame:filterButtonRect] autorelease];
    button.accessibilityLabel = @"set alarm";
    [button setBackgroundImage:buttonNormal forState:UIControlStateNormal];
    [button setBackgroundImage:buttonPressed forState:UIControlStateHighlighted];
    [button setImage:alarm forState:UIControlStateNormal];
    [button setImage:alarm forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(alarmPressed) forControlEvents:UIControlEventTouchUpInside];
    [filterBar addSubview:button];

    CGRect contentRect = r;
    contentRect.size.height -= 44;
    contentRect.origin.y += 44;
    UIView *content = self.view;
    content.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    content.frame = contentRect;
    
    container.autoresizesSubviews = TRUE;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [container addSubview:filterBar];
    [container addSubview:content];
    self.view = container;
}

@end
