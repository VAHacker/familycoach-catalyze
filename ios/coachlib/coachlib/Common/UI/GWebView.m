//
//  GWebView.m
//  iStressLess
//


//

#import "iStressLessAppDelegate.h"
#import "GWebView.h"
#import "ThemeManager.h"
#import "JavaScriptCore.h"

@interface GWebViewDelegate : NSObject<UIWebViewDelegate> {
    void (^loadedBlock)();
}
@property (nonatomic,assign) void (^loadedBlock)();
+ (id) delegateWithBlock:(void (^)())block;
@end
@implementation GWebViewDelegate

@synthesize loadedBlock;

+ (id) delegateWithBlock:(void (^)())block {
    GWebViewDelegate *delegate = [[GWebViewDelegate alloc] init];
    delegate.loadedBlock = [block copy];
    return delegate;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    loadedBlock();
}
-(void)dealloc {
    [loadedBlock release];
    [super dealloc];
}
@end

#define DEBUG_WEBVIEWS 0

@implementation GWebView

@synthesize bindings;

static GWebView *scriptEngine;
static UIWindow *scriptEngineOffscreen;
static NSLock *scriptEngineLock;

+ (void) initScriptEngineAndThen:(void (^)())block {
    GWebView *wv = [[GWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    wv.delegate = [GWebViewDelegate delegateWithBlock:^{
        scriptEngine = wv;
        block();
    }];
    [wv loadContent:@""];
    
    scriptEngineOffscreen = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    UIViewController *c = [[[UIViewController alloc] init] autorelease];
    c.view = wv;
    scriptEngineOffscreen.rootViewController = c;
    scriptEngineLock = [[NSLock alloc] init];
}

+ (NSString*) evalJS:(NSString*)expression withBindings:(NSDictionary*)prebindings {
    NSMutableString *script = [NSMutableString string];
    NSMutableDictionary *bindings = [NSMutableDictionary dictionaryWithDictionary:prebindings];
    [prebindings enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        for (Class klass in @[[NSString class], [NSNumber class], [NSArray class], [NSDictionary class],  [NSNull class]]) {
            if ([obj isKindOfClass:klass]) {
                [bindings setObject:obj forKey:key];
                continue;
            }
        }
    }];
    
    [bindings setObject:@"iphone" forKey:@"platform"];
    [script appendString:@"dae = "];
    [script appendString:[[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bindings options:0 error:NULL] encoding:NSUTF8StringEncoding] autorelease]];
    [script appendString:@";"];
    [scriptEngineLock lock];
    [scriptEngine stringByEvaluatingJavaScriptFromString:script];
    NSString *r = [scriptEngine stringByEvaluatingJavaScriptFromString:expression];
    [scriptEngineLock unlock];
    return r;
}

+ (BOOL) evalBooleanJS:(NSString*)script withBindings:(NSDictionary*)bindings {
    NSString *val = [GWebView evalJS:(NSString*)script withBindings:bindings];
    if ([val isEqualToString:@""]) return FALSE;
    if ([val isEqualToString:@"false"]) return FALSE;
    if ([val isEqualToString:@"0"]) return FALSE;
    return TRUE;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (DEBUG_WEBVIEWS) {
            [self setBackgroundColor:[UIColor blueColor]];
        } else {
            [self setBackgroundColor:[UIColor clearColor]];
            [self setOpaque:NO];
        }
        
        UIScrollView* sv = nil;
        for(UIView* v in self.subviews){
            if([v isKindOfClass:[UIScrollView class] ]){
                sv = (UIScrollView*) v;
                sv.scrollEnabled = NO;
                sv.bounces = NO;
            }
        }

        self.bindings = nil;
    }
    
    return self;
}

- (NSString*) bindingsJson {
    return [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bindings options:0 error:NULL] encoding:NSUTF8StringEncoding] autorelease];
}

-(float) internalPaddingTop {
    return 0;
}

-(float) internalPaddingBottom {
    return 0;
}

-(float)contentHeight {
    return self.frame.size.height;
}

-(float)contentWidth {
    return self.frame.size.width;
}

-(float) contentHeightWithFrame:(CGRect)r {
    return [self contentHeight];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

-(void)setContentSizeChanged {
    [self setNeedsLayout];
    if ([self.superview respondsToSelector:@selector(setContentSizeChanged)]) {
        [((id<Layoutable>)self.superview) setContentSizeChanged];
    } else {
        [self.superview setNeedsLayout];
    }
}

- (void) loadContent:(NSString*)content {
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
    resourcePath = [resourcePath stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    ThemeManager *theme = [ThemeManager sharedManager];
	NSString *fontName = [theme stringForName:@"textFont"];
	float fontSize = [theme floatForName:@"textSize"];
	NSString *textColor = [theme stringForName:@"textColor"];
	NSString *textLinkColor = [theme stringForName:@"textLinkColor"];
    
    NSMutableString *html = [NSMutableString string];
    [html appendFormat:@"<html><head><style>body{background-color:%@;color:#%@;font-family:\"%@\";font-size:%fpx;}\na:link {color:#%@;}</style>",
     DEBUG_WEBVIEWS ? @"#00F" : @"transparent",textColor,fontName,fontSize,textLinkColor];
/*
    [html appendString:@"<script>window.dae = "];
    [html appendString:[self bindingsJson]];
    [html appendString:@";</script>"];
*/    
    [html appendString:@"</head><body>"];
    [html appendString:content];
    [html appendString:@"</body></html>"];
//    NSLog(@"%@",html);
    
    [self loadHTMLString:html baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",resourcePath]]];
}

-(void)dealloc {
    [bindings release];
    
    [super dealloc];
}
@end
