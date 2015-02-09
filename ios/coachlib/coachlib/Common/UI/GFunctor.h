//
//  GFunctor.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>

@interface GFunctor : NSObject {
	void (^block)();
	NSTimer *toInvalidate;
}

@property (nonatomic,assign) NSTimer *toInvalidate;

- (id) initWithBlock:(void (^)())block;
- (void) invoke;

@end
