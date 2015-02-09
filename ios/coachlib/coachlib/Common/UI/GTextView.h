//
//  GTextView.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>


@interface GTextView : UITextView {
	NSString *placeholder;
	BOOL placeholderActive;
	CGRect oldFrame;
    UILabel *placeHolderLabel;
}

@property (nonatomic,retain) NSString *placeholder;
@property (nonatomic,retain) UIView *oldParent;
@property (nonatomic) CGRect oldFrame;

//-(void) setRealText:(NSString *)text;

@end
