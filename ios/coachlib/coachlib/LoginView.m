//
//  LoginView.m
//  iStressLess
//
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginView.h"
#import "iStressLessAppDelegate.h"

@implementation LoginView

@synthesize username, password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)reset {
    username.enabled = TRUE;
    password.enabled = TRUE;
    [username becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    [self reset];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loginButtonTapped:textField];
    return NO;
}

- (IBAction)loginButtonTapped:(id)sender {
    [username resignFirstResponder];
    [password resignFirstResponder];
    username.enabled = FALSE;
    password.enabled = FALSE;
    [[iStressLessAppDelegate instance] attemptLoginWithUsername:[username text] andPassword:[password text]];
}

@end
