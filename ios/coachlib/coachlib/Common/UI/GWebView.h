//
//  GWebView.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import "DynamicSubView.h"

@interface GWebView : UIWebView <Layoutable> {
    id bindings;
}

@property (nonatomic,retain) id bindings;

+ (void) initScriptEngineAndThen:(void (^)())block;
+ (NSString*) evalJS:(NSString*)script withBindings:(NSDictionary*)bindings;
+ (BOOL) evalBooleanJS:(NSString*)script withBindings:(NSDictionary*)bindings;

- (id)initWithFrame:(CGRect)frame;
- (void) loadContent:(NSString*)content;

@end
