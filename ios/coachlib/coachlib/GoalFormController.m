//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "GoalFormController.h"
#import "MBProgressHUD.h"

@implementation GoalFormController


-(void)setVariable:(NSString *)key to:(NSObject *)value {
    [super setVariable:key to:value];
    if ([key isEqualToString:@"doneState"] && [value isKindOfClass:[NSNumber class]] && ([((NSNumber*)value) intValue] == 2)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Congratulations!";
        hud.detailsLabelText = @"Find an appropriate way to reward yourself for a job well-done!";
        hud.margin = 10.f;
        CGRect r = self.view.frame;
        hud.yOffset = r.size.height/3;
        hud.removeFromSuperViewOnHide = YES;
        hud.userInteractionEnabled = FALSE;
        [hud hide:TRUE afterDelay:3];
    }
}

@end
