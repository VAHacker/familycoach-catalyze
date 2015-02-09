//
//  GFunctor.m
//  iStressLess
//


//

#import "GFunctor.h"


@implementation GFunctor

@synthesize toInvalidate;

- (id) initWithBlock:(void (^)())_block {
	block = [_block copy];
	[block retain];
	return self;
}

- (void) invoke {
	block();
	[toInvalidate invalidate];
}

-(void) dealloc {
	[block release];
	[super dealloc];
}

@end
