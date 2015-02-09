//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import "MultiChoiceController.h"
#import "CenteringView.h"

@implementation MultiChoiceController

-(void)valueChanged {
    int val = self.multiChoiceSwitch.selectedSegmentIndex;
    if (self.selectionVariable) {
        [self setVariable:self.selectionVariable to:[NSNumber numberWithInt:val]];
    }
}

-(void) configureFromContent {
    self.selectionVariable = [self.content getExtraString:@"selectionVariable"];

	[super configureFromContent];

    NSString *labels = [self.content getExtraString:@"labels"];
    NSArray *items = [labels componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableArray *a = [NSMutableArray array];
    for (NSString *item in items) {
        [a addObject:[item stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
    }
    
    self.multiChoiceSwitch = [[[UISegmentedControl alloc] initWithItems:a] autorelease];
    [self.multiChoiceSwitch setSegmentedControlStyle:UISegmentedControlStyleBar];
    
    NSNumber *val = (NSNumber*)[self getVariable:self.selectionVariable];
    [self.multiChoiceSwitch setSelectedSegmentIndex:val ? [val intValue] : 0];
    [self.multiChoiceSwitch addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventValueChanged];
    [self addCenteredView:self.multiChoiceSwitch];
}

@end
