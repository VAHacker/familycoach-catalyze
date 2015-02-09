//
//  ThreeLabelTableViewCell.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "TreeViewCell.h"
#import "CornerButton.h"

@interface TreeLines : UIView
@property (nonatomic) int indentLevel;
@property (nonatomic) float indentWidth;
@property (nonatomic,retain) NSArray* lastInParent;
@property (nonatomic) BOOL hasChildren;
@property (nonatomic) BOOL lineAcross;
@end

@implementation TreeLines

-(BOOL)isLastInParent:(int)indent {
    if (indent >= self.lastInParent.count) return FALSE;
    return [((NSNumber*)[self.lastInParent objectAtIndex:indent]) boolValue];
}

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;

    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);

    float x=-1,baseX = 21.5;
    for (int i=0;i<self.indentLevel-1;i++) {
        if ([self isLastInParent:i+1]) continue;
        x = baseX + self.indentWidth * i;
        CGContextMoveToPoint(context, x, -2);
        CGContextAddLineToPoint(context, x, h+2);
    }

    float y = 22;
    if (self.lineAcross) y = 11;
    float newX = -1;
    if (self.indentLevel) {
        x = baseX + self.indentWidth * (self.indentLevel-1);
        CGContextMoveToPoint(context, x, -2);
        if ([self isLastInParent:self.indentLevel]) {
            CGContextAddLineToPoint(context, x, y);
            newX = baseX + self.indentWidth * self.indentLevel;
            CGContextAddLineToPoint(context, newX, y);
            x = -1;
        } else {
            CGContextAddLineToPoint(context, x, h+2);
        }
    }

    if (x != -1) {
        newX = baseX + self.indentWidth * self.indentLevel;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, newX, y);
    }
    
    if (self.hasChildren) {
        x = baseX + self.indentWidth * self.indentLevel;
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, h+2);
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
    if ((newX!=-1) && self.lineAcross) {
        CGContextSaveGState(context);
        CGPoint startPoint = CGPointMake(newX, y);
        CGPoint endPoint = CGPointMake(w-40, y);
        CGContextMoveToPoint(context, newX, y);
        CGContextAddLineToPoint(context, w-40, y);
        CGContextReplacePathWithStrokedPath(context);
        CGContextClip(context);
        
        CGFloat colors [] = {
            0.5, 0.5, 0.5, 1.0,
            0.5, 0.5, 0.5, 0.0
        };
        CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGColorSpaceRelease(baseSpace);
        CGGradientRelease(gradient);
    }
    

}
@end

@implementation TreeViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.expandoButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CircleArrowRight_sml"]];
//        self.expandoButton.contentMode = UIViewContentModeCenter;
//        [self.contentView addSubview:self.expandoButton];
        
//        self.cornerButton = [[CornerButton alloc] init];
//        [self.contentView addSubview:self.cornerButton];
//        self.contentView.clipsToBounds = TRUE;
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    self.expandoButton.transform = CGAffineTransformMakeRotation(-M_PI/2);
    self.treeLines = [[[TreeLines alloc] init] autorelease];
    self.treeLines.backgroundColor = [UIColor clearColor];
    self.treeLines.opaque = FALSE;
    self.contentView.clipsToBounds = FALSE;
    self.clipsToBounds = FALSE;
    [self.contentView insertSubview:self.treeLines belowSubview:self.expandoButton];
    
    _labelText = self.itemLabel.text;
    [_labelText retain];
    _labelFont = self.itemLabel.font;
    [_labelFont retain];
    
    self.accessibilityTraits = UIAccessibilityTraitButton;
}

-(float)getPreferredHeight {
    [self layoutIfNeeded];
    NSString *text = self.labelText;
    float width = self.itemLabel.frame.size.width - 20 - self.indentationLevel*self.indentationWidth;
    CGSize maximumLabelSize = CGSizeMake(width, 30*4);
    CGSize size = [text sizeWithFont:self.itemLabel.font constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    float height = size.height + 20;
    return fmax(height,44);
}

-(void)setExpandoVisible:(BOOL)expandoVisible {
    _expandoVisible = expandoVisible;
//    [UIView animateWithDuration:0.25 animations:^{
        [self updateExpandoButton];
//    }];
}

-(void)setHasChildren:(BOOL)hasChildren {
    _hasChildren = hasChildren;
//    [UIView animateWithDuration:0.25 animations:^{
        [self updateExpandoButton];
//    }];
    [self setNeedsLayout];
}

-(void)setHasHiddenChildren:(BOOL)hasHiddenChildren {
    _hasHiddenChildren = hasHiddenChildren;
//    [UIView animateWithDuration:0.25 animations:^{
        [self updateExpandoButton];
//    }];
    [self setNeedsLayout];
}

-(void)setLastInParent:(NSArray*)lastInParent {
    [_lastInParent release];
    _lastInParent = lastInParent;
    [_lastInParent retain];
    [self setNeedsLayout];
}

-(void)updateExpandoButton {
    BOOL expanded = self.expanded || UIAccessibilityIsVoiceOverRunning();

    if (expanded) {
        self.expandoButton.transform = CGAffineTransformMakeRotation(M_PI/2);
    } else {
        self.expandoButton.transform = CGAffineTransformIdentity;
    }
    if (self.hasHiddenChildren) {
        UIImage *img = [UIImage imageNamed:@"tree_bullet_arrow"];
        [self.expandoButton setImage:img forState:UIControlStateNormal];
        [self.expandoButton setImage:img forState:UIControlStateSelected];
    } else {
        UIImage *img = [UIImage imageNamed:@"tree_bullet"];
        [self.expandoButton setImage:img forState:UIControlStateNormal];
        [self.expandoButton setImage:img forState:UIControlStateSelected];
    }
    
    UIImage *overlay = nil;
    if (self.isDue) {
        overlay = [UIImage imageNamed:@"tree_bullet_overlay_bang"];
    } else if (self.hasAlarm) {
        overlay = [UIImage imageNamed:@"tree_bullet_overlay_alarm"];
    } else {
        if (self.doneState == 0) {
            overlay = [UIImage imageNamed:@"tree_bullet_overlay_empty"];
        } else if (self.doneState == 1) {
            overlay = [UIImage imageNamed:@"tree_bullet_overlay_half"];
        } else if (self.doneState == 2) {
            overlay = nil;
        }
    }
    [self.expandoButtonOverlay setImage:overlay forState:UIControlStateNormal];
    [self.expandoButtonOverlay setImage:overlay forState:UIControlStateSelected];

    if (self.expandoVisible) {
        self.expandoButton.alpha = 1;
        self.expandoButtonOverlay.alpha = 1;
    } else {
        self.expandoButton.alpha = 0;
        self.expandoButtonOverlay.alpha = 0;
    }
    
    self.expandoButton.userInteractionEnabled = FALSE;
    self.expandoButtonOverlay.userInteractionEnabled = self.expandoVisible && self.hasHiddenChildren;

    self.expandoButtonOverlay.isAccessibilityElement = FALSE;
    self.expandoButtonOverlay.accessibilityValue = expanded ? @"expanded" : @"collapsed";
    self.expandoButtonOverlay.accessibilityHint = expanded ? @"collapse" : @"expand";
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (animated) {
//        [UIView animateWithDuration:0.25 animations:^{
            [self updateExpandoButton];
//        }];
    } else {
        [self updateExpandoButton];
    }
}

-(void)setExpanded:(BOOL)expanded animated:(BOOL)animated {
    if (_expanded != expanded) {
        _expanded = expanded;
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                [self updateExpandoButton];
            }];
        } else {
            [self updateExpandoButton];
        }
        if (self.delegate) {
            if (self.expanded) {
                [self.delegate itemExpanded:self.item];
            } else {
                [self.delegate itemCollapsed:self.item];
            }
        }
    }
}

-(void)setExpanded:(BOOL)expanded {
    [self setExpanded:expanded animated:FALSE];
}

- (IBAction)expandoPressed:(id)sender {
    [self setExpanded:!self.expanded animated:TRUE];
}

-(void)setLabelText:(NSString*)text {
    [_labelText release];
    _labelText = text;
    [_labelText retain];
    
    if (self.editingItemLabel.editable) {
        self.editingItemLabel.text = text;
    } else {
        self.itemLabel.text = text;
    }
}

-(void)setLabelFont:(UIFont*)font {
    [_labelFont release];
    _labelFont = font;
    [_labelFont retain];
    
    if (self.editingItemLabel.editable) {
        self.editingItemLabel.font = font;
    } else {
        self.itemLabel.font = font;
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    float oldHeight = [self getPreferredHeight];
    [_labelText release];
    _labelText = textView.text;
    [_labelText retain];
    float newHeight = [self getPreferredHeight];
    if (newHeight != oldHeight) {
        [self.delegate cellSizeChanged:self];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        self.editingTitle = FALSE;
        [self.delegate cellEditingEnded:self];
        return FALSE;
    }
    return TRUE;
}

-(void)setEditingTitle:(BOOL)editingTitle {
    if (_editingTitle == editingTitle) return;
    _editingTitle = editingTitle;
    if (_editingTitle) {
        self.editingItemLabel.textColor = self.itemLabel.textColor;
        self.editingItemLabel.text = self.labelText;
        self.editingItemLabel.font = self.labelFont;
        self.editingItemLabel.hidden = FALSE;
        self.editingItemLabel.userInteractionEnabled = TRUE;
        self.editingItemLabel.editable = TRUE;
        self.itemLabel.text = nil;
        [self.editingItemLabel becomeFirstResponder];
    } else {
        [self.editingItemLabel resignFirstResponder];
        self.editingItemLabel.hidden = TRUE;
        self.editingItemLabel.editable = FALSE;
        self.editingItemLabel.userInteractionEnabled = FALSE;
        self.itemLabel.text = self.labelText;
        self.itemLabel.font = self.labelFont;
    }
    [self setNeedsLayout];
/*
    if (_editingTitle && !self.editingItemLabel) {
        self.editingItemLabel = [[UITextField alloc] initWithFrame:self.itemLabel.frame];
        self.editingItemLabel.text = self.labelText;
        self.editingItemLabel.font = self.labelFont;
        self.editingItemLabel.hidden = FALSE;
        self.editingItemLabel.enabled = TRUE;
        self.editingItemLabel.backgroundColor = [UIColor blueColor];
        self.editingItemLabel.textColor = [UIColor blackColor];
        self.editingItemLabel.textAlignment = self.itemLabel.textAlignment;
        [self addSubview:self.editingItemLabel];
        self.itemLabel.text = nil;
        [self.editingItemLabel becomeFirstResponder];
    } else if (!_editingTitle && self.editingItemLabel) {
        [self.editingItemLabel resignFirstResponder];
        [self.editingItemLabel removeFromSuperview];
        self.editingItemLabel = nil;
        self.itemLabel.text = self.labelText;
        self.itemLabel.font = self.labelFont;
    }
*/ 
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    
    CGRect r = self.contentView.frame;
    r.origin.x += indentPoints;
    r.size.width -= indentPoints;
    if (!self.expandoVisible) r.origin.x -= self.indentationWidth/2;
    self.contentView.frame = r;
    
    r = self.contentView.frame;
    r.size.width += indentPoints;
    r.origin.x = -indentPoints;
    if (!self.expandoVisible) r.origin.x += self.indentationWidth/2;
    r.origin.y = -1;
    r.size.height += 2;
    self.treeLines.frame = r;
    self.treeLines.indentLevel = self.indentationLevel;
    self.treeLines.indentWidth = self.indentationWidth;
    self.treeLines.lastInParent = self.lastInParent;
    self.treeLines.hasChildren = self.hasChildren;
    self.treeLines.lineAcross = self.itemLabel.text == nil;
    [self.treeLines setNeedsDisplay];
    
    if ((self.indentationLevel == 0) && !self.expandoVisible) {
        r = self.itemLabel.frame;
        r.origin.x = 18;
        self.itemLabel.frame = r;
    }
    
    float width = self.itemLabel.frame.size.width;
    CGSize maximumLabelSize = CGSizeMake(width, 30*4);
    CGSize size = [self.labelText sizeWithFont:self.labelFont constrainedToSize:maximumLabelSize lineBreakMode:UILineBreakModeWordWrap];
    r = self.itemLabel.frame;
    r.size.height = size.height;
    self.itemLabel.frame = r;
    
    if (self.editingItemLabel.editable) {
        r.origin.x += 9;
        r.origin.y -= 8;
        r.size.height+=30;
        self.editingItemLabel.frame = r;
    }

    for (UIView *view in self.subviews) {
        if ([NSStringFromClass ([view class]) rangeOfString:@"ReorderControl"].location != NSNotFound) {    // UITableViewCellReorderControl
            view.userInteractionEnabled = FALSE;
        }
    }
}

@end
