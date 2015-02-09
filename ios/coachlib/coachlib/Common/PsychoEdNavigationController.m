//
//  PsychoEdNavigationController.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PsychoEdNavigationController.h"
#import "ContentViewController.h"

@implementation PsychoEdNavigationController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)slaveViewDidAppear:(UIViewController *)slave {
    if ([slave isKindOfClass:[ContentViewController class]]) {
        ContentViewController* cvc = (ContentViewController*)slave;
        cvc.viewTypeID = 1; // psycho-ed
    }
}

@end
