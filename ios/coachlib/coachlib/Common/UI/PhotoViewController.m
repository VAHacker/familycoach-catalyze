//
//  PhotoViewController.m
//  buy.com
//


//

#import "PhotoViewController.h"
#import "ThemeManager.h"

@implementation PhotoViewController

@synthesize photoView, scroller;

-(void)loadView {
	scroller = [[UIScrollView alloc] initWithFrame:CGRectZero];
	scroller.multipleTouchEnabled = TRUE;
	scroller.delegate = self;
	photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
	photoView.contentMode = UIViewContentModeScaleAspectFit;
	[scroller addSubview:photoView];
	self.view = scroller;
    self.view.opaque = TRUE;
    self.view.backgroundColor = [[ThemeManager sharedManager] colorForName:@"backgroundColor"];
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	scroller.alwaysBounceHorizontal = YES;
	scroller.alwaysBounceVertical = YES;
	scroller.minimumZoomScale = 1.0;
	scroller.maximumZoomScale = 10.0;
	scroller.scrollsToTop = NO;
	scroller.decelerationRate = UIScrollViewDecelerationRateFast;
	scroller.zoomScale = 1.0;
	scroller.contentOffset = CGPointMake(0, 0);
	CGRect r = scroller.frame;
	photoView.frame = r;
	scroller.contentSize = photoView.frame.size;
}

-(void) setImage:(UIImage*)image {
	[self view];
	[photoView setImage:image];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return photoView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

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

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[scroller release];
	[photoView release];
	
    [super dealloc];
}


@end
