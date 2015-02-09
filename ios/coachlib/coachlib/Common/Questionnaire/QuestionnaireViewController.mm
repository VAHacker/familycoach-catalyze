    //
//  QuestionnaireView.m
//  iStressLess
//


//

#import "QuestionnaireViewController.h"
#include "QPlayer.h"
#include "QuestionnaireScreenView.h"
#import "iStressLessAppDelegate.h"

@implementation QuestionnaireViewController

- (id) initWithPlayer:(QPlayer*)_player {
	self=[super init];
	[self view];
	player = _player;
	questions = nil;

	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

+(NSString*) stringByReplacingVariablesInString:(NSString *)src with:(NSDictionary *)vars {
	const char* srcBytes = [src UTF8String];
	const char* s = srcBytes;
	const char* endP = s;
	NSMutableString *d = [[NSMutableString alloc] init];
	while (*endP) {
		if ((*endP == '$') && (*(endP+1) == '{')) {
			[d appendString:[src substringWithRange:NSMakeRange(s-srcBytes,endP-s)]];
			
			s=endP+2;
			endP = s;
			while (*endP && (*endP != '}')) endP++;
			
			NSString *varName = [src substringWithRange:NSMakeRange(s-srcBytes,endP-s)];
			NSString *replacement = (NSString*)[vars objectForKey:varName];
			if (replacement) {
				[d appendString:replacement];
			}
			
			s = endP;
			if (*s) s++;
			endP = s;
		} else endP++;
	}
	
	if (endP-s) {
		NSRange range = NSMakeRange(s-srcBytes,endP-s);
		[d appendString:[src substringWithRange:range]];
	}
	
	[d autorelease];
	return d;
}

- (void)buttonPressed:(UIButton*)button {
	switch (button.tag) {
		case BUTTON_NEXT: {
			[self nextPressed];
			break;
		}
		case BUTTON_DONE:
			[self donePressed];
			break;
		default:
			break;
	};
}

- (void) addQuestion:(QuestionInstance*)question {
	if (!questions) questions = [[NSMutableArray alloc] init];
	[questions addObject:question];
}

- (void) setValidity:(BOOL)valid {
	for (ButtonModel *model in self.buttons) {
		model.enabled = valid;
	}	
}

- (void) updateValidity {
	for (int i=0;i<[questions count];i++) {
		QuestionInstance *q = [questions objectAtIndex:i];
		if (![q isValid]) {
			[self setValidity:FALSE];
			return;
		}
	}

	[self setValidity:TRUE];
}

- (ConstructedView*) createMainViewWithFrame:(CGRect)frame {
	return [[QuestionnaireScreenView alloc] initWithFrame:frame];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) removeLastViewController {
	[(GNavigationController*)self.navigationController removeLastViewController];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) nextPressed {
	player->nextPressed();
}

- (void) helpPressed {
	ContentViewController *cvc = [[iStressLessAppDelegate instance] getContentControllerWithName:@"pclHelp"];
	[self.masterController navigateToNext:cvc];
}

- (void) cancelPressed {
	player->deferPressed();
}

- (void) donePressed {
	player->donePressed();
}

- (void)dealloc {
	[questions release];
	
    [super dealloc];
}


@end
