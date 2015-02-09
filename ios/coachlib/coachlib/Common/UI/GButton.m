//
//  GButton.m
//  iStressLess
//


//

#import "GButton.h"
#import "TUNinePatch.h"
#import "DynamicSubView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GButton

@synthesize icon,layoutType;

-(id)initWithFrame:(CGRect)frame {
    GButton *_self = [super initWithFrame:frame];
    _self.titleLabel.textAlignment = NSTextAlignmentCenter;
    _self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _self.titleLabel.numberOfLines = 2;
/*
    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEventValueChanged];
//    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEvent];
    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEventTouchCancel];
    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(setNeedsDisplay) forControlEvents:(UIControlEvents)UIControlEventTouchUpOutside];
*/
    _self.userInteractionEnabled = TRUE;
    _self.isDefault = FALSE;
    return _self;
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self setContentSizeChanged];
}

-(float) internalPaddingTop {
    return 0;
}

-(float) internalPaddingBottom {
    return 0;
}

-(float) contentHeightWithFrame:(CGRect)r {
    return [self contentHeight];
}

-(float) contentHeight {
//	CGSize size = self.textSize;
//    float height = size.height+20;
//    if (height < 44) height = 44;
    return 44;
}

-(float) contentWidth {
	CGSize size = self.textSize;
	size.width += 30;
	size.height += 30;
    return size.width;
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.5;
    }
}

-(void)setContentSizeChanged {
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        [self setNeedsLayout];
    }
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.titleLabel.text = [self titleForState:self.state];
    self.titleLabel.textColor = [self titleColorForState:self.state];
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

-(NSString*)label {
    return [self titleForState:UIControlStateNormal];
}

-(void)setLabel:(NSString*)label {
	[self setTitle:label forState:UIControlStateNormal];
	[self setTitle:label forState:UIControlStateHighlighted];
	self.textSize = [(label ? label : @"...") sizeWithFont:self.titleLabel.font];
}

-(void)didMoveToWindow {
    [super didMoveToWindow];
    if (!self.bgNormal) {
        self.opaque = TRUE;
        if (!self.backgroundColor) self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 7.0;
        self.layer.masksToBounds = TRUE;
        if (self.isDefault) {
            self.layer.borderColor = [[UIColor blackColor] CGColor];
            self.layer.borderWidth = 1;
        }
    }
}

-(void)drawRect:(CGRect)rect {
    TUNinePatch *np = self.bgNormal;
    if (self.state == UIControlStateHighlighted) {
        np = self.bgPressed;
    }
    
    if (np) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect r = self.bounds;
        [np inContext:context drawInRect:r];
    } else {
        if (self.state == UIControlStateHighlighted) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextAddRect(context, self.bounds);
            CGContextClip(context);
            
            CGPoint startPoint = CGPointMake(0, 0);
            CGPoint endPoint = CGPointMake(0, self.frame.size.height);
            
            CGFloat colors [] = {
                5/255.0, 139/255.0, 245/255.0, 1.0,
                1/255.0, 94/255.0, 230/255.0, 1.0
            };
            CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
            CGContextRestoreGState(context);
            CGColorSpaceRelease(baseSpace);
            CGGradientRelease(gradient);
        }
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetAlpha(context, self.enabled ? 1 : 0.5);
    }
    [super drawRect:rect];
}

-(void) layoutSubviews {
//	[super layoutSubviews];
//	if (!iconView) return;
/*
    UIImage * bg = [self backgroundImageForState:self.state];
    self.imageView.image = bg;
    self.imageView.frame = self.bounds;
    self.titleLabel.text = [self titleForState:self.state];
    self.titleLabel.textColor = [self titleColorForState:self.state];
*/
    self.titleLabel.hidden = FALSE;
    self.titleLabel.text = [self titleForState:self.state];
    self.titleLabel.textColor = [self titleColorForState:self.state];

	if (layoutType == GBUTTON_LAYOUT_CENTER_TOP) {
		CGRect r = self.bounds;
		CGRect ir = self.bounds;
		UILabel *label = self.titleLabel;
		CGSize size;

		if (label.text) {
			r = UIEdgeInsetsInsetRect(r, self.titleEdgeInsets);
            if (self.iconView) {
                size = [label.text sizeWithFont:label.font constrainedToSize:r.size lineBreakMode:NSLineBreakByWordWrapping];
                r.origin.y = r.origin.y+r.size.height-size.height;
                r.size.height = size.height;
            }
            
			label.frame = r;
		}

		if (self.iconView) {
			ir = CGRectInset(ir, 5, 5);
            if (label.text) {
                ir.size.height = label.frame.origin.y - ir.origin.y - 5;
            }
			self.iconView.frame = ir;
		}
        
		
	} else {
		CGRect r = self.bounds;
        CGRect ir = self.bounds;
		UILabel *label = self.titleLabel;
        self.titleLabel.textAlignment = UITextAlignmentRight;
        
        if (self.iconView) {
			ir = CGRectInset(ir, 8, 8);
            ir.size.width = (ir.size.height < ir.size.width/2) ? ir.size.height : (ir.size.width/2);
			self.iconView.frame = ir;
        }

        NSString *text = label.text;
        if (text && ![text isEqualToString:@""]) {
            r = UIEdgeInsetsInsetRect(r, self.titleEdgeInsets);
            if (self.iconView) r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(0, ir.size.width+10, 0, 0));
            CGSize size = [text sizeWithFont:label.font constrainedToSize:r.size lineBreakMode:NSLineBreakByWordWrapping];
//            size.width += 20;
            r.origin.x = roundf(r.origin.x + r.size.width - 5 - size.width);
            r.size.width = size.width;
            label.frame = r;
            [label layoutIfNeeded];
        }
		
		
	}
}

-(void) setIcon:(UIImage *)image {
	[icon release];
	icon = nil;
	icon = image;
	[icon retain];

	if (image) {
		if (!self.iconView) {
			self.iconView = [[[UIImageView alloc] initWithImage:icon] autorelease];
			[self addSubview:self.iconView];
			self.iconView.contentMode = UIViewContentModeScaleAspectFit;
			self.iconView.backgroundColor = [UIColor clearColor];
			self.iconView.opaque = NO;
		} else {
			self.iconView.image = image;
		}
	} else {
		if (self.iconView) {
			[self.iconView removeFromSuperview];
			[self.iconView release];
			self.iconView = nil;
		}
	}

}

-(void) dealloc {
	[super dealloc];
}

@end
