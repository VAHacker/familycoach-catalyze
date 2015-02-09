//
//  AlertDelegate.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertDelegate : NSObject <UIAlertViewDelegate> {
	id target;
	SEL targetSelector;
}

@property (nonatomic,assign) id target;
@property (nonatomic,assign) SEL targetSelector;

@end
