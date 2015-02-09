//
//  ConstructedViewController.m
//  iStressLess
//


//

#import "ConstructedViewController.h"
#import "ConstructedView.h"
#import "iStressLessAppDelegate.h"
#import "DynamicSubView.h"
#import "CenteringView.h"
#import "GTextView.h"
#import "GWebView.h"
#import "GButton.h"
#import "Flurry.h"
#import "FindFirstResponder.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "ButtonModel.h"
#import "ThemeManager.h"
#import "StyledTextView.h"
#import "GradientScrollContainer.h"
#import "LayoutableProxyView.h"
#import "BackgroundView.h"

@implementation ConstructedViewController

@synthesize topView, contentView, scrollView, inputAccessoryView, contentLoadedBlock, viewsToLoad;

- (id)initWithCoder:(NSCoder *)aDecoder {
	self=[super initWithCoder:aDecoder];
	[self privateInit];
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self=[super initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil];
	[self privateInit];
	return self;
}

- (id)init {
	self=[super init];
	[self privateInit];
    self.isInlineContent = false;
    _childContentControllers = nil;
	return self;
}

-(NSArray *)childContentControllers {
    if (!_childContentControllers) {
        _childContentControllers = [[NSMutableArray array] retain];
    }
    return _childContentControllers;
}

- (void)privateInit {
	viewsToLoad = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (ConstructedView*) createMainViewWithFrame:(CGRect)frame {
	ConstructedView *cv = [[ConstructedView alloc] initWithFrame:frame];
    if (self.isInlineContent) {
        cv.onTop = FALSE;
    }
    if (self.buttonsAreFixed) {
        cv.clipDynamicView = TRUE;
    }
    return cv;
}

+(NSString*) stringByReplacingVariablesInString:(NSString *)src with:(NSDictionary *)vars {
    if (!src) return nil;
	const char* srcBytes = [src UTF8String];
	const char* s = srcBytes;
	const char* endP = s;
	NSMutableString *d = [[NSMutableString alloc] init];
	while (*endP) {
		if ((*endP == '$') && (*(endP+1) == '{')) {
			[d appendString:[src substringWithRange:NSMakeRange(s-srcBytes,endP-s)]];
            int nesting = 0;
            BOOL nested = FALSE;
			
			s=endP+2;
			endP = s;
			while (*endP && (nesting || (*endP != '}'))) {
                if (*endP == '{') {
                    nested = TRUE;
                    nesting++;
                } else if (*endP == '}') nesting--;
                endP++;
            }
			
			NSString *varName = [src substringWithRange:NSMakeRange(s-srcBytes,endP-s)];
            if (nested) {
                varName = [self stringByReplacingVariablesInString:varName with:vars];
            }
			NSString *replacement = (NSString*)[vars objectForKey:varName];
            if (!replacement) {
                replacement = [[iStressLessAppDelegate instance] getSetting:varName];
            }
            if (!replacement) {
                replacement = [[iStressLessAppDelegate instance] getContentTextWithName:varName];
            }
			if (replacement) {
				[d appendString:[NSString stringWithFormat:@"%@",replacement]];
			}
			
			s = endP;
			if (*s) s++;
			endP = s;
		} else endP++;
	}
	
	if (endP-s) {
//		NSRange range = NSMakeRange(s-srcBytes,endP-s);
//        [NSString stringWithUTF8String:s length:endP-s];
		[d appendString:[NSString stringWithUTF8String:s length:endP-s]];
	}
	
	[d autorelease];
	return d;
}


- (void) setVariable:(NSString*)key to:(NSObject*)value {
	if (!self.localVariables) self.localVariables = [NSMutableDictionary dictionaryWithCapacity:1];
	[self.localVariables setObject:value forKey:key];
}

- (NSObject*) getVariable:(NSString*)key {
	if (!self.localVariables) return nil;
	id val = [self.localVariables objectForKey:(NSString *)key];
    if (val == [NSNull null]) return nil;
    return val;
}

- (void) clearVariable:(NSString*)key {
	if (!self.localVariables) return;
	[self.localVariables removeObjectForKey:key];
}

- (void) clearVariables {
    self.localVariables = nil;
}

- (void)gatherVariables:(NSMutableDictionary*)vars {
    if (self.masterController) {
        [self.masterController gatherVariables:vars];
    } else {
        [vars addEntriesFromDictionary:[iStressLessAppDelegate instance].globalVariables];
    }
    
//    NSLog(@"adding to %@",vars);
//    NSLog(@"locals %@",self.localVariables);
    [vars addEntriesFromDictionary:self.localVariables];
}

- (NSDictionary*)variables {
    NSMutableDictionary *vars = [NSMutableDictionary dictionary];
    [self gatherVariables:vars];
    return vars;
}

- (NSString*)replaceVariables:(NSString*)txt {
	return [ConstructedViewController stringByReplacingVariablesInString:txt with:self.variables];
}

-(void) configureFromContent {
}

-(void) configureContentView {
}

-(void)setDynamicView:(DynamicSubView *)v {
	[dynamicView release];
	dynamicView = v;
	[dynamicView retain];
}

- (UIView*) dynamicView {
	if (dynamicView) return dynamicView;
	
	dynamicView = [[DynamicSubView alloc] initWithFrame:contentView.frame];
	dynamicView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    dynamicView.topMargin = 0;
    
    if (self.buttonsAreFixed && self.shouldScroll) {
        ConstructiveScrollView *scroller = [[ConstructiveScrollView alloc] initWithFrame:contentView.frame];
        [scroller addSubview:dynamicView];
        scroller.clipsToBounds = FALSE;
        GradientScrollContainer *container = [[GradientScrollContainer alloc] initWithFrame:contentView.frame];
        container.autoresizesSubviews = YES;

        contentView.clientView = container;
        [container addSubview:scroller];
        [contentView addSubview:container];
        scrollView = scroller;
        scrollView.autoresizesSubviews = NO;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    } else {
        contentView.clientView = dynamicView;
        [contentView addSubview:dynamicView];
	}
	return dynamicView;
}

-(UIImage*) backgroundBlendedImageToUse {
    return nil;
}

-(UIImage*) backgroundImageToUse {
    return nil;//[UIImage imageNamed:@"table_bg_darker.png"];
}

-(UIView*) backgroundViewToUse {
    UIImage *bgimage = [self backgroundImageToUse];
    UIView *v = nil;
    if (bgimage) {
        v = [[[UIImageView alloc] initWithImage:[self backgroundImageToUse]] autorelease];
    } else {
        ThemeManager *theme = [ThemeManager sharedManager];
        UIImage *image = [self backgroundBlendedImageToUse];
        if (image) {
            BackgroundView *bgv = [[[BackgroundView alloc] init] autorelease];
            bgv.color = [theme colorForName:@"backgroundColor"];
            bgv.image = image;
            v = bgv;
        } else {
            v = [[[UIView alloc] init] autorelease];
        }
        v.backgroundColor = [theme colorForName:@"backgroundColor"];
    }
    v.contentMode = UIViewContentModeScaleToFill;
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    return v;
}

-(UIColor*) backgroundColorToUse {
    ThemeManager *theme = [ThemeManager sharedManager];
    return [theme colorForName:@"backgroundColor"];
}

-(void) configureBackground {
    if (!self.isInlineContent) {
        UIView *bgv = [self backgroundViewToUse];
        if (bgv) {
            bgv.frame = topView.bounds;
            [topView addSubview:bgv];
        } else {
            topView.backgroundColor = [self backgroundColorToUse];
        }
    }
//	Theme *t = self.theme;
//	topView.backgroundColor = t.bgUIColor;
}

-(NSMutableDictionary*) makeContentDescriptor {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    return params;
}

- (void)recordButtonPush:(UIButton*)button {
    NSMutableDictionary *params = [self makeContentDescriptor];
    NSString *val;

    [ButtonPressedEvent logWithButtonPressedButtonId:[NSString stringWithFormat:@"%d",button.tag] withButtonPressedButtonTitle:button.titleLabel.text];
    
    val = button.titleLabel.text;
    if (val) [params setObject:val forKey:@"buttonName"];
    [params setObject:[NSNumber numberWithInt:button.tag] forKey:@"buttonID"];
    
    [Flurry
     logEvent:@"BUTTON_PRESS" 
     withParameters:params];
}

- (void)gatherButtonsInto:(NSMutableArray*)models {
    for (UIViewController *c in self.childContentControllers) {
        if ([c isKindOfClass:[ConstructedViewController class]]) {
            ConstructedViewController *cvc = (ConstructedViewController*)c;
            [cvc gatherButtonsInto:models];
        }
    }
    [models addObjectsFromArray:self.buttons];
}

- (void)addAllButtonViews {
    if (![contentView respondsToSelector:@selector(leftButtons)]) return;
    if (self.isInlineContent) return;
    
    NSMutableArray *leftButtons = [NSMutableArray array];
    NSMutableArray *rightButtons = [NSMutableArray array];
    NSMutableArray *models = [NSMutableArray array];
    [self gatherButtonsInto:models];

    ButtonModel *defaultButton = nil;
    ButtonModel *rightMostButton = nil;
    for (ButtonModel *model in models) {
        if (model.isDefault) {
            if (!defaultButton) {
                defaultButton = model;
            } else {
                model.isDefault = FALSE;
            }
        }
        if (!(model.style & (BUTTON_STYLE_INLINE|BUTTON_STYLE_LEFT))) {
            rightMostButton = model;
        }
    }
    
    if (!defaultButton) {
        rightMostButton.isDefault = TRUE;
    }

    for (ButtonModel *model in models) {
/*
        if (!model.onClickBlock) {
            model.onClickBlock = ^{
                [self buttonPressed:model.buttonView];
            };
        }
*/
        UIButton *v = model.buttonView;
        if (model.style & BUTTON_STYLE_INLINE) {
            CGRect r = v.frame;
            r.size.height = floorf(r.size.height*1.3);
            r.size.width = self.contentView.frame.size.width - 20;
            v.frame = r;
            v.titleLabel.font = [v.titleLabel.font fontWithSize:17];
            
            [self addCenteredView:v];
        } else if (model.style & BUTTON_STYLE_LEFT) {
            [leftButtons addObject:v];
        } else {
            [rightButtons addObject:v];
        }
    }
    
    contentView.leftButtons = leftButtons;
    contentView.rightButtons = rightButtons;
    [contentView layoutIfNeeded];
}

- (BOOL)shouldScroll {
    return !self.isInlineContent;
}

- (BOOL)buttonsAreFixed {
    return FALSE;
}

- (void)loadViewFromContent {
//	[CATransaction begin];
//	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	viewsToLoad = 0;
	
	CGRect r = [[UIScreen mainScreen] bounds];
    if (!self.shouldScroll || self.buttonsAreFixed) {
        contentView = [self createMainViewWithFrame:r];
        topView = [contentView retain];
        self.view = topView;
        [self configureBackground];
    } else {
        topView = [[LayoutableProxyView alloc] initWithFrame:r];
        scrollView = [[ConstructiveScrollView alloc] initWithFrame:r];
        scrollView.autoresizesSubviews = NO;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        contentView = [self createMainViewWithFrame:topView.frame];
        [self configureContentView];
        self.view = topView;
        [self configureBackground];
        [topView addSubview:scrollView];
        [scrollView addSubview:contentView];
    }
	
	[self configureFromContent];
    [self addAllButtonViews];
//	[CATransaction commit];
}

- (void)loadView {
	[self loadViewFromContent];
	if (viewsToLoad == 0) {
		[self contentLoaded];
	}
}

- (GWebView*) createWebView:(NSString*)text withBounds:(CGRect)r {
	GWebView *wv = [[GWebView alloc] initWithFrame:r];
    [wv loadContent:text];
	return wv;
}

- (GWebView*) createWebView:(NSString*)text {
	[self view];
	
	viewsToLoad++;

	CGRect r = [self.dynamicView bounds];
	r.size.height = 70;
	GWebView *wv = [self createWebView:text withBounds:r];
	wv.delegate = self;
	return wv;
}

-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:(BOOL)animated];
/*
	self.scrollView.contentOffset = CGPointMake(0, 0);
	
	CGRect r = scroller.bounds;
	contentView.frame = r;
	r.size.height -= descriptionView.frame.origin.y;
	r.origin = descriptionView.frame.origin;
	descriptionView.frame = r;
	
	self.scrollView.contentSize = contentView.frame.size;
*/
}

- (BOOL)webViewLinkTapped:(NSURL*)url {
	return TRUE;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL *url = [request URL];
		return [self webViewLinkTapped:url];
	}

	return TRUE;
}

-(void) setContentLoadedBlock:(void (^)())block {
	[self view];
	[contentLoadedBlock release];
	contentLoadedBlock = nil;
	if (viewsToLoad == 0) {
		block();
	} else {
		contentLoadedBlock = [block copy];
	}
}

- (void)contentLoaded {
	if (contentLoadedBlock) {
		contentLoadedBlock();
	}
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//	scroller.contentOffset = CGPointMake(0, 0);
	NSString *heightStr = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"];
	float height = [heightStr floatValue];

	CGRect r = webView.frame;
	height += 10;
	r.size.height = height;
	webView.frame = r;
/*
    UIView *v = webView;
    while (v) {
        CGRect frame = v.frame;
        NSLog(@"%@: %f,%f,%f,%f",[v.class description],frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
        v = v.superview;
    }
*/
    [((GWebView*)webView) setContentSizeChanged];
    [topView setNeedsLayout];
    [scrollView setNeedsLayout];
    [contentView setNeedsLayout];
    [dynamicView setNeedsLayout];
/*
	CGRect r = descriptionView.frame;
	r.size.height = height;
	descriptionView.frame = r;
	
	CGRect contentFrame = contentView.frame;
	contentFrame.size.height = r.origin.y + height;
	contentView.frame = contentFrame;
	
	scroller.contentSize = contentFrame.size;
 */
	
	if (--viewsToLoad == 0) {
		[self contentLoaded];
	}
}

#define MAX_IMAGE_HEIGHT 150

- (UIView*) createImageView:(UIImage*)image {
	CGRect r;
	CGSize imageSize = image.size;
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.layer.borderWidth = 2;
	imageView.layer.borderColor	= [[UIColor lightGrayColor] CGColor];

	CGRect bounds = [self.dynamicView bounds];
	if (imageSize.height > MAX_IMAGE_HEIGHT) {
		imageSize.width = (float)MAX_IMAGE_HEIGHT * imageSize.width / imageSize.height;
		imageSize.height = MAX_IMAGE_HEIGHT;
	}
	r.origin.x = (bounds.size.width - imageSize.width) / 2;
	r.origin.y = 0;
	r.size = imageSize;
	imageView.frame = r;

	r = bounds;
	r.size.height = imageSize.height;
	UIView *container = [[UIView alloc] initWithFrame:r];
	[container addSubview:imageView];
	
	[imageView release];
	
	return container;
}

- (UIView*) createLabel:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)textColor {
	[self view];
    
	CGRect r = [self.dynamicView bounds];
	UIView *container = [[UIView alloc] initWithFrame:r];
	UILabel *label = [[UILabel alloc] initWithFrame:r];
	label.lineBreakMode = UILineBreakModeWordWrap;
	label.opaque = FALSE;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = textColor;//[UIColor colorWithRed:0.8 green:0.8 blue:1 alpha:1 ];
    //	label.shadowColor = [UIColor blackColor];
    //	label.shadowOffset = CGSizeMake(0, 1);
	label.font = font;
	label.numberOfLines = 99;
	label.text = text;
	r = label.frame;
	r.size.width -= 20;
	CGSize size = [text sizeWithFont:label.font constrainedToSize:r.size lineBreakMode:UILineBreakModeWordWrap];
	r = label.frame;
	r.size.height = size.height;
	container.frame = r;
	r.origin.x += 10;
	r.size.width -= 20;
	label.frame = r;
	[container addSubview:label];
    [label release];
	
	return container;
}

- (UIView*) createLabel:(NSString*)text {
    ThemeManager *theme = [ThemeManager sharedManager];
    return [self createLabel:text withFont:[UIFont fontWithName:[theme stringForName:@"textFont"] size:[theme floatForName:@"textSize"]] andColor:[theme colorForName:@"textColor"]];
}

-(void) addRightSideView:(UIView*)rightSide withMargin:(CGPoint)margin {
	[self view];

	CGRect r = self.dynamicView.frame;
	CGRect rr = rightSide.frame;
	r.size.width -= rr.size.width + margin.x * 2;
	rr.origin.x = r.origin.x + r.size.width + margin.x;
	rr.origin.y = margin.y;
	rightSide.frame = rr;
	self.dynamicView.frame = r;
	contentView.rightSideView = rightSide;
	[contentView addSubview:rightSide];
}

-(void) addImage:(UIImage*)image {
	[self view];
	
	UIView *imageView = [self createImageView:image];
	CGRect outer = self.dynamicView.bounds;
	CGRect r = imageView.frame;
	r.origin.y = outer.size.height+10;
	imageView.frame = r;
	[self.dynamicView addSubview:imageView];
	[imageView release];
}
/*
- (void)keyboardWillShow:(NSNotification *)notification {
 
    return;
	
    NSDictionary *userInfo = [notification userInfo];
    if (self.masterController) {
        NSLog(@"rejected");
        return;
    } else {
        NSLog(@"accepted");
    }
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system.
	// The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    UIView *v = [self.view.window findFirstResponder];
	if (![v isKindOfClass:[GTextView class]]) {
        return;
    }

    if (v.superview == self.view) {
        [self.view bringSubviewToFront:v];
    } else {
        CGRect oldRectInMySpace = [self.view convertRect:v.bounds fromView:v];
        [self.view addSubview:v];
        v.frame = oldRectInMySpace;
    }
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect oldRect = v.frame;
        NSLog(@"%f",oldRect.origin.x + oldRect.origin.y);
        CGRect r = [v.superview convertRect:newTextViewFrame fromView:self.view];
		v.frame = r;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
   
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
}
*/

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    
    [txtView resignFirstResponder];
    return NO;
}

-(UIView*) createTextInputWithLines:(int)lines andPlaceholder:(NSString*)placeholderText {
	[self view];

    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"textFont"];
	float fontSize = [theme floatForName:@"textSize"];
//	NSString *textColor = [theme stringForName:@"textColor"];
	UIFont *font = [UIFont fontWithName:fontName size:fontSize];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect r = screenRect;
    r.origin.x = 0;
    r.origin.y = 0;
	r.size.height = [font lineHeight]*lines+20;
	UIView *container = [[UIView alloc] initWithFrame:r];
	
	r.origin.x += 10;
	r.size.width -= 20;
	GTextView *textView = [[GTextView alloc] initWithFrame:r];
    textView.font = [UIFont fontWithName:fontName size:fontSize];
	textView.layer.cornerRadius = 5;
	textView.layer.borderColor = [[UIColor blackColor] CGColor];
	textView.layer.borderWidth = 1;
    textView.delegate = self;
//	textView.inputAccessoryView = self.inputAccessoryView;
    textView.returnKeyType = UIReturnKeyDone;
	textView.placeholder = placeholderText;
	[container addSubview:textView];
	return container;
}

-(IBAction) dismissKeyboard {
	[[self.view.window findFirstResponder] resignFirstResponder];
}

-(GTextView*) addTextInputWithLines:(int)lines andPlaceholder:(NSString*)placeholderText {
	UIView *v = [self createTextInputWithLines:(int)lines andPlaceholder:(NSString *)placeholderText];
	[self.dynamicView addSubview:v];
	GTextView *tv = [[v subviews] objectAtIndex:0];
	[v release];
	return tv;
}

-(void) addText:(NSString*)text {
	[self addHTMLText:text];
	return;
/*	
	[self view];

	UIView *label = [self createLabel:text];
	CGRect r = label.frame;
	r.origin.y+=10;
	label.frame = r;
	[self.dynamicView addSubview:label];
	[label release];[self mak
*/ 
}

- (void)linkPushed:(DTLinkButton *)button {
    NSURL *URL = button.URL;
    [self webViewLinkTapped:URL];
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame {
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
//	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
    
	// we draw the contents ourselves
	button.attributedString = string;

	// make a version with different text color
	NSMutableAttributedString *highlightedString = [string mutableCopy];
    
	NSRange range = NSMakeRange(0, highlightedString.length);
    
	NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:(id)[UIColor redColor].CGColor forKey:(id)kCTForegroundColorAttributeName];
    
	[highlightedString addAttributes:highlightedAttributes range:range];
    
	button.highlightedAttributedString = highlightedString;
    
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    [highlightedString release];
    
    return button;
}

-(UIView<Layoutable>*)viewForHTML:(NSString*)text {
	text = [self replaceVariables:text];

    if (!self.hardHTML) {
        ThemeManager *theme = [ThemeManager sharedManager];
        NSString *fontName = [theme stringForName:@"textFont"];
        NSString *textLinkColor = [NSString stringWithFormat:@"#%@",[theme stringForName:@"textLinkColor"]];
        float textSize = [theme floatForName:@"textSize"];
        float textMultiplier = textSize / 12.0;
        
        void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
            /*
             if (element.displayStyle == DTHTMLElementDisplayStyleInline && element.textAttachment.displaySize.height > 2.0 * element.fontDescriptor.pointSize)
             {
             element.displayStyle = DTHTMLElementDisplayStyleBlock;
             }
             */
        };
        
        
        CGSize maxImageSize = CGSizeMake(400,400);
        NSDictionary *options =
            [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithFloat:textMultiplier], NSTextSizeMultiplierDocumentOption,
                [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                fontName, DTDefaultFontFamily,
                [theme colorForName:@"textColor"], DTDefaultTextColor,
                textLinkColor, DTDefaultLinkColor,
                callBackBlock, DTWillFlushBlockCallBack,
             nil];
        
        NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:[text dataUsingEncoding: NSUTF8StringEncoding] options:options documentAttributes:NULL];
        
        //    [DTAttributedTextContentView setLayerClass:[CATiledLayer class]];
        CGRect r = [self.dynamicView bounds];
        StyledTextView *tv = [[StyledTextView alloc] initWithFrame:CGRectMake(0, 0, r.size.width, 12)];
//        tv.userInteractionEnabled = TRUE;
        tv.accessibilityValue = [string string];
        tv.isAccessibilityElement = TRUE;
        tv.accessibilityTraits = UIAccessibilityTraitStaticText;
        tv.delegate = self;
        tv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tv.shouldDrawLinks = NO;
        tv.shouldDrawImages = YES;
        tv.attributedString = string;
        [string release];
        tv.edgeInsets = UIEdgeInsetsMake(6, 10, 6, 10);
        tv.opaque = FALSE;
        tv.backgroundColor = [UIColor clearColor];
        r = tv.frame;
        r.size.height = tv.contentHeight;
        tv.frame = r;
        [tv autorelease];
        return tv;
    } else {
        GWebView *htmlView = [self createWebView:text];
        [htmlView autorelease];
        return htmlView;
    }
}

-(void) addHTMLText:(NSString*)text {
	[self view];
	[self.dynamicView addSubview:[self viewForHTML:text]];
}

- (void) addCenteredView:(UIView*)v {
	v = [CenteringView centeredView:v];
	CGRect r = v.frame;
	r.size.width = self.dynamicView.frame.size.width;
    r.size.height += 12;
	v.frame = r;
	[self.dynamicView addSubview:v]; 
}

- (void) addView:(UIView*)v usingGravity:(int)gravity {
	v = [CenteringView gravityView:v withGravity:gravity];
	CGRect r = v.frame;
	r.size.width = self.dynamicView.frame.size.width;
    r.size.height = v.frame.size.height;
	v.frame = r;
	[self.dynamicView addSubview:v];
}

- (void) addView:(UIView*)v {
	[self.dynamicView addSubview:v]; 
}

- (void) addButton:(ButtonModel*)buttonModel {
	if (!self.buttons) self.buttons = [NSMutableArray array];
    [self.buttons addObject:buttonModel];
}

-(ButtonModel*) addButton:(int)buttonType withText:(NSString*)text {
    ButtonModel *button = [ButtonModel button];
    button.label = text;
    button.tag = buttonType;
	[self addButton:button];
    return button;
}

-(ButtonModel*) addButtonWithText:(NSString*)text andStyle:(int)style callingBlock:(void (^)())block {
    ButtonModel *button = [ButtonModel button];
    button.label = text;
    button.onClickBlock = block ? [block copy] : nil;
    button.style = style;
	[self addButton:button];
    return button;
}

-(ButtonModel*) addButtonWithText:(NSString*)text {
    return [self addButtonWithText:text andStyle:0 callingBlock:nil];
}

-(ButtonModel*) addButtonWithText:(NSString*)text callingBlock:(void (^)())block {
    return [self addButtonWithText:text andStyle:0 callingBlock:block];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
	[dynamicView release];
	[contentView release];
	[scrollView release];
	[topView release];
	[inputAccessoryView release];
    [_childContentControllers release];
	
    [super dealloc];
}


@end
