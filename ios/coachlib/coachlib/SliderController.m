//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "SliderController.h"
#import "Content+ContentExtensions.h"

@implementation SliderController

-(void)setThumbText:(NSString*)str {
    self.thumbView.text = str;
    UIGraphicsBeginImageContextWithOptions(self.thumbView.frame.size,NO,2.0);
    [self.thumbView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.sliderView setThumbImage:image forState:(UIControlStateNormal)];
    [self.sliderView setThumbImage:image forState:(UIControlStateHighlighted)];
}

-(void)sliderMoved:(id)slider {
    int value = (int)roundf(self.sliderView.value);
    if (value != self.sliderView.value) {
        self.sliderView.value = value;
        if (self.selectionVariable) [self setVariable:self.selectionVariable to:[NSNumber numberWithInt:value]];
    }

    [self setThumbText:[NSString stringWithFormat:@"%d",value]];
}

-(void) configureFromContent {
	[super configureFromContent];
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];
    CGRect r = [[UIScreen mainScreen] applicationFrame];
    r.origin.y = r.origin.x = 0;
    r.size.width -= 20;
    r.size.height = 44;
    self.sliderView = [[[UISlider alloc] initWithFrame:r] autorelease];
    self.sliderView.minimumValue = [self.content getExtraFloat:@"min"];
    self.sliderView.maximumValue = [self.content getExtraFloat:@"max"];
    
    NSNumber *val = ((NSNumber*)[self getVariable:self.selectionVariable]);
    if (val) self.sliderView.value = [val floatValue];
    else self.sliderView.value = (self.sliderView.minimumValue + self.sliderView.maximumValue) / 2.0f;

    [self.sliderView addTarget:self action:@selector(sliderMoved:) forControlEvents:(UIControlEventValueChanged)];
    self.sliderView.continuous = TRUE;
    self.thumbView = [[[GLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
    self.thumbView.drawWedge = FALSE;
    self.thumbView.textAlignment = NSTextAlignmentCenter;
    [self addCenteredView:self.sliderView];
    
    if (val) {
        [self setThumbText:[NSString stringWithFormat:@"%d",[val intValue]]];
    } else {
        [self setThumbText:@"?"];
    }
}

@end
