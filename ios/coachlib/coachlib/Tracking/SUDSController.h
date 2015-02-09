//
//  SUDSViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import "ContentViewController.h"
#import "SUDSView.h"

@interface SUDSController : ContentViewController {
	SUDSView* sudsView;
}

@property(readwrite) int suds;

@end
