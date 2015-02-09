//
//  ConstructedViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "GNavigationController.h"
#import "ConstructedView.h"
#import "DynamicSubView.h"
#import "ConstructiveScrollView.h"
#import "GTextView.h"
#import "GWebView.h"
#import "ButtonModel.h"
#import "DTAttributedTextContentView.h"

@interface ConstructedViewController : UIViewController<UIWebViewDelegate,DTAttributedTextContentViewDelegate,UITextViewDelegate> {

	UIView *topView;
	ConstructiveScrollView *scrollView;
	ConstructedView *contentView;
	DynamicSubView *dynamicView;
	
	UIView *inputAccessoryView;
	CGRect storedTextViewRect;
	
	NSMutableArray *blocks;
	void (^contentLoadedBlock)();
	int viewsToLoad;
    
    NSMutableArray *_childContentControllers;
}

@property (nonatomic, assign) ContentViewController *masterController;
@property (nonatomic, retain) IBOutlet UIView *inputAccessoryView;

@property (nonatomic) int viewsToLoad;
@property (nonatomic) BOOL isInlineContent;
@property (nonatomic) BOOL hardHTML;
@property (nonatomic) BOOL shouldScroll;
@property (nonatomic) BOOL buttonsAreFixed;
@property (nonatomic) BOOL inlineImage;
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) NSMutableDictionary *localVariables;

@property (nonatomic, readonly) UIView *topView;
@property (nonatomic, readonly) ConstructedView *contentView;
@property (nonatomic, retain) DynamicSubView *dynamicView;
@property (nonatomic, readonly) ConstructiveScrollView *scrollView;
@property (nonatomic, readonly) NSArray *childContentControllers;
@property (nonatomic, copy) void (^contentLoadedBlock)();

- (void)privateInit;

- (void)loadViewFromContent;
- (void)contentLoaded;

-(void) configureBackground;
-(UIView*) backgroundViewToUse;
-(UIImage*) backgroundImageToUse;
-(UIColor*) backgroundColorToUse;

-(UIView*) createLabel:(NSString*)text NS_RETURNS_RETAINED;
-(UIView*) createLabel:(NSString*)text withFont:(UIFont*)font andColor:(UIColor*)textColor NS_RETURNS_RETAINED;
-(UIView*) createTextInputWithLines:(int)lines andPlaceholder:(NSString*)placeholderText NS_RETURNS_RETAINED;
-(UIView*) createImageView:(UIImage*)image NS_RETURNS_RETAINED;
-(GWebView*) createWebView:(NSString*)text withBounds:(CGRect)r NS_RETURNS_RETAINED;
-(GWebView*) createWebView:(NSString*)text NS_RETURNS_RETAINED;
-(ConstructedView*) createMainViewWithFrame:(CGRect)frame NS_RETURNS_RETAINED ;

-(void) addView:(UIView*)v;
-(void) addView:(UIView*)v usingGravity:(int)gravity;
-(void) addCenteredView:(UIView*)v;
-(void) addText:(NSString*)text;
-(UIView*)viewForHTML:(NSString*)text;
-(void) addHTMLText:(NSString*)htmlText;
-(void) addImage:(UIImage*)image;
-(void) addRightSideView:(UIView*)rightSide withMargin:(CGPoint)margin;
-(void) addButton:(ButtonModel *)button;

-(ButtonModel*) addButton:(int)buttonType withText:(NSString*)text;
-(ButtonModel*) addButtonWithText:(NSString*)text;
-(ButtonModel*) addButtonWithText:(NSString*)text callingBlock:(void (^)())block;
-(ButtonModel*) addButtonWithText:(NSString*)text andStyle:(int)style callingBlock:(void (^)())block;
//-(ButtonModel*) createButtonWithText:(NSString*)text callingBlock:(void (^)())block;
-(GTextView*) addTextInputWithLines:(int)lines andPlaceholder:(NSString*)placeholderText;

- (void)gatherButtonsInto:(NSMutableArray*)models;
- (void)addAllButtonViews;

- (NSDictionary*)variables;
- (NSString*)replaceVariables:(NSString*)txt;
- (void) setVariable:(NSString*)key to:(NSObject*)value;
- (NSObject*) getVariable:(NSString*)key;
- (void) clearVariable:(NSString*)key;
- (void) clearVariables;

-(IBAction) dismissKeyboard;

@end
