//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "CategoryIntroController.h"
#import "ManageSymptomsNavController.h"
#import "iStressLessAppDelegate.h"

@implementation CategoryIntroController

-(NSString *)nextButtonTitle {
    return nil;
}

-(void) configureFromContent {
	[super configureFromContent];
    [self addButtonWithText:@"Take a Time Out" andStyle:BUTTON_STYLE_INLINE callingBlock:^{
        [self navigateToNext];
    }].isDefault = TRUE;
}

-(Content *) nextContent {
    return self.selectedContent;
}

@end
