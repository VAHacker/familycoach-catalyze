#import "CCAlertView.h"

NSString *const CCAlertViewDismissAllAlertsNotification = @"CCAlertViewDismissAllAlertsNotification";
NSString *const CCAlertViewAnimatedKey = @"CCAlertViewAnimated";

@implementation CCAlertView
@synthesize alert, blocks, dismissAction, keepInMemory;

- (id) initWithTitle: (NSString*) title message: (NSString*) message
{
    self = [super init];
    alert = [[UIAlertView alloc] initWithTitle:title message:message
        delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    blocks = [[NSMutableArray alloc] init];
    return self;
}

- (void) show
{
    [alert show];
    [self setKeepInMemory:self];
    [[NSNotificationCenter defaultCenter]
        addObserverForName:CCAlertViewDismissAllAlertsNotification
        object:nil queue:nil usingBlock:^(NSNotification *event) {
        id animated = [[event userInfo] objectForKey:CCAlertViewAnimatedKey];
        [self dismissAnimated:[animated boolValue]];
    }];
}

- (void) dismissAnimated: (BOOL) animated
{
    [alert dismissWithClickedButtonIndex:-1 animated:animated];
}

- (void) addButtonWithTitle: (NSString*) title block: (dispatch_block_t) block
{
    if (!block) block = ^{};
    [alert addButtonWithTitle:title];
    dispatch_block_t blockCopy = [block copy];
    [blocks addObject:blockCopy];
    [blockCopy release];
}

- (void) alertView: (UIAlertView*) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex >= 0 && buttonIndex < [blocks count]) {
        dispatch_block_t block = [blocks objectAtIndex:buttonIndex];
        block();
    }
    if (dismissAction != NULL) {
        dismissAction();
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setKeepInMemory:nil];
}

@end
