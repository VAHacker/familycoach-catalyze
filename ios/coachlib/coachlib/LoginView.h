//
//  LoginView.h
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIViewController {
    UITextField *username;
    UITextField *password;
}

@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;

- (void)reset;
- (IBAction)loginButtonTapped:(id)sender;

@end
