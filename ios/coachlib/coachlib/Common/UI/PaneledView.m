//
//  PaneledView.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PaneledView.h"

@implementation PaneledView

- (void)expandoTapped:(UIButton*)expando {
    self.expanded = !self.expanded;
}

-(void)refreshLabel {
    if (_splitBadgeValue) {
        if (_splitTitle) {
            self.splitLabel.text = [NSString stringWithFormat:@"%@ (%d)",_splitTitle,_splitBadgeValue];
        } else {
            self.splitLabel.text = [NSString stringWithFormat:@"(%d)",_splitBadgeValue];
        }
    } else {
        self.splitLabel.text = [NSString stringWithFormat:@"%@",_splitTitle];
    }
}

-(void)setSplitTitle:(NSString *)splitTitle {
    [_splitTitle release];
    _splitTitle = splitTitle;
    [_splitTitle retain];
    [self refreshLabel];
}

-(void)setSplitBadgeValue:(int)splitBadgeValue {
    _splitBadgeValue = splitBadgeValue;
    [self refreshLabel];
}

-(void)setPanelHidden:(BOOL)panelHidden {
    _panelHidden = panelHidden;
    [self setNeedsLayout];
}

-(void)setPanelHidden:(BOOL)panelHidden animated:(BOOL)animated {
    _panelHidden = panelHidden;
    [self transitionToPanelStateAnimated:animated];
}

-(BOOL)panelHidden {
    return _panelHidden;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _splitTitle = nil;
        _splitBadgeValue = 0;
        _panelHidden = TRUE;

        self.bottomMinHeight = 30;
        self.bottomPane = [[[UIView alloc] init] autorelease];

        CGRect barFrame = CGRectMake(0, 0, frame.size.width, 30);
        self.splitView = [[[UIButton alloc] initWithFrame:barFrame] autorelease];
        
        UIImageView *barImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"split_bar.png"]] autorelease];
        barImage.frame = barFrame;
        self.splitView.frame = barFrame;
        [self.splitView addSubview:barImage];
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectInset(barFrame, 5, 5)] autorelease];
        label.text = @"Reminders";
        label.textAlignment = UITextAlignmentLeft;
        label.opaque = FALSE;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(0, -1);
        self.splitLabel = label;
        [self.splitView addSubview:label];
        CGRect r = barFrame;
        r.origin.x = r.size.width - 25;
        r.size.width = 20;
        UIImageView *collapseButton = [[[UIImageView alloc] initWithFrame:r] autorelease];
        [self.splitView addSubview:collapseButton];
        collapseButton.contentMode = UIViewContentModeScaleAspectFit;
        collapseButton.image = [UIImage imageNamed:@"collapse_arrow.png"];
        collapseButton.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        collapseButton.layer.shadowOffset = CGSizeMake(0, 1);
        collapseButton.layer.shadowOpacity = 1;
        collapseButton.layer.shadowRadius = 0.5;
        collapseButton.transform = CGAffineTransformMakeRotation(-M_PI);
        self.collapseButton = collapseButton;
        
        [self.splitView addTarget:self action:@selector(expandoTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self.bottomPane addSubview:self.splitView];
        [self addSubview:self.bottomPane];
        self.bottomPane.autoresizesSubviews = FALSE;
        expanded = FALSE;
    }
    return self;
}

-(void)transitionToPanelStateAnimated:(BOOL)animated {
    CGRect r = self.bounds;
    float h1,h2;
    
    if (_panelHidden) {
        h1 = r.size.height;
        h2 = self.bottomMinHeight;
    } else {
        h2 = self.bottomMinHeight;
        h1 = r.size.height - h2;
        if (expanded) {
            h1 = floor(r.size.height*2.0/3.0);
            h2 = r.size.height - h1;
        }
    }
    
    void (^block)() = ^{
        CGRect frame = r;
        frame.size.height = h1;
        self.top.frame = frame;
        [self.top layoutIfNeeded];
        
        frame.origin.y = frame.origin.y + h1;
        frame.size.height = h2;
        self.bottomPane.frame = frame;
        [self.bottomPane layoutIfNeeded];
        
        frame.origin.y = self.bottomMinHeight;
        frame.size.height = h2-self.bottomMinHeight;
        self.bottom.frame = frame;
        
        if (expanded) {
            self.collapseButton.layer.shadowOffset = CGSizeMake(0, -1);
            self.collapseButton.transform = CGAffineTransformIdentity;
        } else {
            self.collapseButton.layer.shadowOffset = CGSizeMake(0, 1);
            self.collapseButton.transform = CGAffineTransformMakeRotation(-M_PI);
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:block];
    } else {
        block();
    }
}

-(void)setExpanded:(BOOL)isExpanded animated:(BOOL)animated {
    if (isExpanded == expanded) return;
    expanded = isExpanded;
    [self transitionToPanelStateAnimated:animated];
}

-(void)setExpanded:(BOOL)isExpanded {
    [self setExpanded:isExpanded animated:TRUE];
}

-(BOOL)expanded {
    return expanded;
}

-(void)setBottom:(UIView *)bottom {
    if (self.bottom) [self.bottom removeFromSuperview];
    _bottom = bottom;
    [self.bottomPane addSubview:_bottom];
    [_bottom retain];
    
    self.bottom.frame = CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-30);
//    self.bottom.autoresizingMask = UIViewAutoresizingFlexibleHeight;
}

-(void)setTop:(UIView *)top {
    if (self.top) [self.top removeFromSuperview];
    _top = top;
    _top.clipsToBounds = TRUE;
    [self insertSubview:_top belowSubview:self.bottomPane];
//    [self addSubview:_top];
    [_top retain];
}

-(void)layoutSubviews {
    CGRect r = self.bounds;
    float h1,h2;

    if (_panelHidden) {
        h1 = r.size.height;
        h2 = self.bottomMinHeight;
    } else {
        h2 = self.bottomMinHeight;
        h1 = r.size.height - h2;
        if (expanded) {
            h1 = floor(r.size.height*2.0/3.0);
            h2 = r.size.height - h1;
        }
    }

    CGRect frame = r;
    frame.size.height = h1;
    frame.origin.y = 0;
    self.top.frame = frame;

    frame.size.height = h2;
    frame.origin.y = h1;
    self.bottomPane.frame = frame;

    frame.origin.y = self.bottomMinHeight;
    frame.size.height = h2-self.bottomMinHeight;
    self.bottom.frame = frame;
}

@end
