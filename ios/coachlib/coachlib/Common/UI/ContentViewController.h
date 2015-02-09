//
//  ContentViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ConstructedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Content.h"
#import "ContentEvent.h"
#import "Content+ContentExtensions.h"

@interface ContentViewController : ConstructedViewController {
	UIImage *attachedImage;
    long long timeAppeared;
    int viewTypeID;

    NSURL *pendingURL;
    
    BOOL _captionsEnabled;
    BOOL captionsChecked;
    UILabel *captionView;
    NSDate *firstCaptionStart;
    NSTimer *captionTimer;
    NSString *captionText;
    int captionState;
    NSArray *captions;
    int captionEnd;
    int captionIndex;
    
    BOOL _contentVisible;
    BOOL _contentEverVisible;
    BOOL _startedLoadingView;
    BOOL _inTransition;
    BOOL _nonTransitionUIEnablement;
}

@property (nonatomic) int viewTypeID;
@property (nonatomic) float originalViewHeight;
@property (nonatomic) float originalScrollerHeight;
@property (nonatomic,assign) UIScrollView *adjustedScroller;
@property (nonatomic) BOOL captionsEnabled;
@property (nonatomic) BOOL inTransition;
@property (nonatomic) BOOL scoping;
@property (nonatomic) BOOL beingRemoved;
@property (nonatomic, retain) Content *content;
@property (nonatomic, readonly, retain) UIImage *attachedImage;
@property (nonatomic, retain) NSMutableArray *buttonContent;
@property (nonatomic, retain) NSMutableArray *execStack;
@property (nonatomic, retain) NSString *bestInlineTitle;
@property (nonatomic, retain) AVAudioPlayer *player;
@property (nonatomic, readonly) UINavigationItem *leafNavigationItem;
@property (nonatomic, retain) ContentViewController *selectionTarget;
@property (nonatomic, retain) NSMutableDictionary *localActions;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIAccessibilityElement *lastAccessibilityFocus;

@property (nonatomic) BOOL contentVisible;

-(void)configureMetaContent;
-(void) baselineConfigureFromContent;
-(void) configureFromContent;
-(void) playAudio;
-(void) visitLink:(NSURL*)url;

-(void) relayout;
-(void) setEnables;

- (NSString *)runJS:(NSString *)aJSString;

-(void) preloadAndThen:(void (^)())block;

-(BOOL)shouldAddListenButton;
-(BOOL) shouldExecInsteadOfPush;
-(void) execInsteadOfPush;

- (void)managedObjectSelected:(NSManagedObject*)mo;
- (void)navigationDataReceived:(NSDictionary*)data;
- (BOOL)navigateToContent:(Content *)content;
- (BOOL)navigateToContent:(Content *)content withData:(NSDictionary*)data;
- (BOOL)navigateToContentName:(NSString *)contentName;
- (BOOL)navigateToContentName:(NSString *)contentName withData:(NSDictionary *)data;
- (BOOL)navigateToChildController:(ContentViewController *)childController;
- (BOOL)navigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary*)data;
- (BOOL)branchNavigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary*)data;

-(BOOL)evalJSPredicate:(NSString*)predicate;
-(NSString*)evalJS:(NSString*)predicate;
-(void) updateEnablements;

-(void)gatherNavigationItems:(NSMutableArray*)items;
-(BOOL)dispatchContentEvent:(ContentEvent*)event;

-(NSArray*) getCaptions;
-(NSArray*) getChildContentList;
-(Content*) getContentWithName:(NSString*)name;
-(Content*) getChildContentWithName:(NSString*)name;
-(Content*) getChildContentWithName:(NSString*)name forContent:(NSManagedObject*)obj;
-(ContentViewController*) getChildControllerWithName:(NSString*)name;
//-(ContentViewController*) createChildControllerWithName:(NSString*)name;
-(Content*)nextContent;
//-(ContentViewController*)getNextController;

- (void) goBack;
- (void) goBackAnimated:(BOOL)animated;
- (void) navigateToHere;
- (void) navigateToNext;
- (void) navigateToNextContent:(Content*)content;
- (void) navigateToNext:(ContentViewController *)next;
- (void) navigateToNext:(ContentViewController *)next animated:(BOOL)animated andRemoveOld:(BOOL)removeOld;
- (void) navigateToNext:(ContentViewController *)next from:(ContentViewController *)src animated:(BOOL)animated andRemoveOld:(BOOL)removeOld;

- (void) goBackFrom:(UIViewController*)src animated:(BOOL)animated;
- (BOOL) navigateToContentWithPath:(NSArray *)path startingAt:(int)index from:(ContentViewController*)cvc withData:(NSDictionary*)data;

- (void) pushExecLeaf:(ContentViewController*)cvc;
- (BOOL) popExecLeaf:(ContentViewController*)vc;

- (NSString*)checkPrerequisite;
- (BOOL)hasAnyContent;
- (int)badgeValue;

-(void)contentBecameVisible;
-(void)contentBecameVisibleForFirstTime;
-(void)contentBecameInvisible;
-(void)updateContentVisibilityForChild:(ContentViewController*)child;
-(void)updateContentVisibilityForChildren;
-(void)contentVisibilityChanged;

-(void)addChildContentController:(ContentViewController*)child;
-(void)removeChildContentController:(ContentViewController*)child;

-(void) registerAction:(NSString*)action withSelector:(SEL)selector;
- (BOOL)performAction:(NSString*)action withSource:(Content*)source fromChild:(ContentViewController*)child;
- (BOOL)performAction:(NSString*)action withSource:(Content*)source;
- (BOOL)tryPerformAction:(NSString*)action withSource:(Content*)source;

@end
