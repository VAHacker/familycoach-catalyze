//
//  GTextView.m
//  iStressLess
//


//

#import "GTextView.h"


@implementation GTextView

@synthesize placeholder,oldFrame;
/*
-(NSString *) text {
	if (placeholderActive) return nil;
	return [super text];
}

-(void) setRealText:(NSString *)_text {
    if (_text && ![_text isEqualToString:@""]) {
        placeholderActive = FALSE;
        self.text = _text;
        self.textColor = [UIColor blackColor];
    } else {
        placeholderActive = TRUE;
        self.text = placeholder;
        self.textColor = [UIColor lightGrayColor];
    }
}
 */

-(void) setPlaceholder:(NSString *)_placeholder {
	[placeholder release];
	placeholder = _placeholder;
	[placeholder retain];
	
	if (!placeholder) return;
/*
	if (![self isFirstResponder]) {
		if (!self.text || [self.text isEqual:@""]) {
			placeholderActive = TRUE;
			self.text = placeholder;
			self.textColor = [UIColor lightGrayColor];
		}
	}
*/ 
}

-(BOOL) resignFirstResponder {
    if (![self isFirstResponder]) return TRUE;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([super resignFirstResponder]) {
/*
		if (placeholder && (!self.text || [self.text isEqual:@""])) {
			placeholderActive = TRUE;
			self.text = placeholder;
			self.textColor = [UIColor lightGrayColor];
		}
*/
        /*
        CGRect oldRectInNewSpace = [self.oldParent convertRect:self.bounds fromView:self];
		self.frame = oldRectInNewSpace;
        [self.oldParent addSubview:self];
        
		[UIView beginAnimations:nil context:NULL];
		self.frame = oldFrame;
		[UIView commitAnimations];
         */
		return TRUE;
	}
	
	return FALSE;
}

-(BOOL) becomeFirstResponder {
    if ([self isFirstResponder]) return TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
//	oldFrame = self.frame;
//    self.oldParent = self.superview;
	if (placeholderActive) {
		self.text = @"";
		self.textColor = [UIColor blackColor];
		placeholderActive = FALSE;
	}
	return [super becomeFirstResponder];
}



- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( placeHolderLabel == nil )
        {
            placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            placeHolderLabel.lineBreakMode = UILineBreakModeWordWrap;
            placeHolderLabel.numberOfLines = 0;
            placeHolderLabel.font = self.font;
            placeHolderLabel.backgroundColor = [UIColor clearColor];
            placeHolderLabel.textColor = [UIColor lightGrayColor];
            placeHolderLabel.alpha = 0;
            placeHolderLabel.tag = 999;
            [self addSubview:placeHolderLabel];
        }
        
        placeHolderLabel.text = self.placeholder;
        [placeHolderLabel sizeToFit];
        [self sendSubviewToBack:placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

-(void)dealloc {
    [placeHolderLabel release];
    [super dealloc];
}

@end
