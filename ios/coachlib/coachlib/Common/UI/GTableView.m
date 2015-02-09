//
//  GTableView.m
//  iStressLess
//


//

#import "GTableView.h"
#import "iStressLessAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation GTableView

@synthesize marginBottom;

/*
- (CGFloat)cellsMargin {
    
    // No margins for plain table views
    if (self.myTableView.style == UITableViewStylePlain) {
        return 0;
    }
    
    // iPhone always have 10 pixels margin
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return 10;
    }
    
    CGFloat tableWidth = self.myTableView.frame.size.width;
    
    // Really small table
    if (tableWidth <= 20) {
        return tableWidth - 10;
    }
    
    // Average table size
    if (tableWidth < 400) {
        return 10;
    }
    
    // Big tables have complex margin's logic
    // Around 6% of table width,
    // 31 <= tableWidth * 0.06 <= 45
    
    CGFloat marginWidth  = tableWidth * 0.06;
    marginWidth = MAX(31, MIN(45, marginWidth));
    return marginWidth;
}
*/

-(void)setContentSizeChanged {
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        [self setNeedsLayout];
    }
}

-(void)reloadData {
    [super reloadData];
    [self setContentSizeChanged];
}

-(void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [super reloadSections:sections withRowAnimation:animation];
    [self setContentSizeChanged];
}

-(void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self setContentSizeChanged];
}

-(void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    [self setContentSizeChanged];
}

-(float) internalPaddingTop {
    if (self.style == UITableViewStylePlain) return 0;
    return 8;
}

-(float) internalPaddingBottom {
    if (self.style == UITableViewStylePlain) return 0;
    return 8;
}

-(float) contentHeightWithFrame:(CGRect)r {
    return [self contentHeight];
}

-(float) contentWidth {
    return self.bounds.size.width;
}

-(float) contentHeight {
    int sections = [self numberOfSections];
    if (sections == 0) return 0;
    CGRect r = [self rectForSection:sections-1];
    
    float h = r.origin.y + r.size.height + marginBottom;
    
    if ([iStressLessAppDelegate deviceMajorVersion] >= 7) {
        h -= 20;
    }

	return h;
}

@end
