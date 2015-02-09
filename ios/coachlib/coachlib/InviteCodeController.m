//
//  InviteCodeController.m
//  coachlib
//
//  Created by Josh Ault on 11/20/14.
//  Copyright (c) 2014 Department of Veteran's Affairs. All rights reserved.
//

#import "InviteCodeController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "heartbeat.h"
#import "JSONKit.h"

@interface InviteCodeController ()

@property BOOL validInviteCode;
@property UIActivityIndicatorView *spinner;
@property GButton *btnConfirm;

@end

@implementation InviteCodeController

-(void)confirmInviteCode {
    [heartbeat signIn:^{
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:@"token"];
        NSString *code = txtInviteCode.text;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.catalyze.io/v2/classes/inviteCodes/query?searchBy=%@&field=code", code]];
        ASIFormDataRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setRequestMethod:@"GET"];
        [request addRequestHeader:@"Accept" value:@"application/json"];
        [request addRequestHeader:@"Content-Type" value:@"application/json"];
        [request addRequestHeader:@"X-Api-Key" value:@"969ad33b-fcc9-494a-acc6-66bfe2f2d1b6"];
        NSString *bearerString = [NSString stringWithFormat:@"Bearer %@", token];
        [request addRequestHeader:@"Authorization" value:bearerString];
        [request setCompletionBlock:^ {
            NSArray *response = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
            [_spinner stopAnimating];
            [self enableComponents:YES];
            if ([request responseStatusCode] == 200 && response.count == 1) {
                NSString *subjectId = [[[response objectAtIndex:0] objectForKey:@"content"] valueForKey:@"subjectId"];
                [[NSUserDefaults standardUserDefaults] setValue:code forKey:@"userInviteCode"];
                [[NSUserDefaults standardUserDefaults] setValue:subjectId forKey:@"subjectId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [super navigateToContentName:@"intro"];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"That invite code is invalid. Please enter a new invite code." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }];
        [request setDelegate:self];
        [request startAsynchronous];
    }];
}

- (BOOL)tryPerformAction:(NSString *)action withSource:(Content *)source {
    if ([action isEqualToString:@"confirm"]) {
        [self validate];
        return TRUE;
    }
    return [super tryPerformAction:action withSource:source];
}

-(void)configureFromContent {
    [super configureFromContent];
    
    _btnConfirm = [[[self buttons] objectAtIndex:0] buttonView];
    
    Content *txtInviteCodeContent = [self getChildContentWithName:@"inviteCodeInput"];
    NSString *prompt = [txtInviteCodeContent valueForKey:@"mainText"];
    NSString *exampleText = [txtInviteCodeContent getExtraString:@"exampleText"];
    [self addText:prompt];
    txtInviteCode = [self addTextInputWithLines:1 andPlaceholder:exampleText];
    txtInviteCode.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userInviteCode"];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
}

- (void)validate {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_spinner setCenter:self.view.center];
        [self.view addSubview:_spinner];
    }
    [self enableComponents:NO];
    [_spinner startAnimating];
    
    NSString *msg = nil;
    if (!txtInviteCode.text || [txtInviteCode.text isEqual:@""]) {
        msg = @"Please put in a valid invite code to begin using this application.";
    }
    if (msg) {
        [_spinner stopAnimating];
        [self enableComponents:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    [self confirmInviteCode];
}

- (void)enableComponents:(BOOL)enable {
    txtInviteCode.userInteractionEnabled = enable;
    _btnConfirm.userInteractionEnabled = enable;
}

-(void) dealloc {
    [txtInviteCode release];
    [_spinner release];
    [_btnConfirm release];
    
    [super dealloc];
}

@end
