//
//  ContentViewController.m
//  iStressLess
//


//

#import "ContentViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIAccessibility.h>
#import "iStressLessAppDelegate.h"
#import "AlertDelegate.h"
#import "GFunctor.h"
#import "heartbeat.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "Content+ContentExtensions.h"
#import "NSManagedObject+MOExtensions.h"
#import "GWebView.h"
#import "ContentEvent.h"
#import "ThemeManager.h"
#import "JavaScriptCore.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "FormController.h"
#import "RadioController.h"

#define BUTTON_NEXT 5001

@implementation UIView (FindFirstResponder)
- (UIView *)findFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    }
    
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findFirstResponder];
        
        if (firstResponder != nil) {
            return firstResponder;
        }
    }
    
    return nil;
}
@end

@implementation ContentViewController

@synthesize viewTypeID;

- (void)privateInit {
    [super privateInit];
    _contentEverVisible = FALSE;
    _contentVisible = FALSE;
    _startedLoadingView = FALSE;
}

static JSGlobalContextRef _JSContext = NULL;
static NSDictionary *currentVariableBindings = nil;
static ContentViewController *currentCVC = nil;
static NSLock *scriptEngineLock = nil;

JSValueRef jsSetVariable(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    NSObject *value = nil;

    if (JSValueIsNumber(ctx,arguments[1])) {
        value = [NSNumber numberWithDouble: JSValueToNumber(ctx, arguments[1], NULL)];
    } else if (JSValueIsBoolean(ctx, arguments[1])) {
        value = [NSNumber numberWithInt: JSValueToNumber(ctx, arguments[1], NULL)!=0 ? 1 : 0];
    } else {
        JSStringRef valueRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[1], NULL);
        value = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, valueRef);
        [value autorelease];
        JSStringRelease(valueRef);
    }
    
    NSLog(@"setVariable('%@',%@)",key,value);
    if ([key isEqualToString:@"pssTotal"]) { // we finished a self assessment, record the score
        ContentViewController *cvc = currentCVC;
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:[cvc runJS:@"parseInt(dae.pss01);" withLock:NO] forKey:@"pss01"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss02);" withLock:NO] forKey:@"pss02"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss03);" withLock:NO] forKey:@"pss03"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss04);" withLock:NO] forKey:@"pss04"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss05);" withLock:NO] forKey:@"pss05"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss06);" withLock:NO] forKey:@"pss06"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss07);" withLock:NO] forKey:@"pss07"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss08);" withLock:NO] forKey:@"pss08"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss09);" withLock:NO] forKey:@"pss09"];
        [params setValue:[cvc runJS:@"parseInt(dae.pss10);" withLock:NO] forKey:@"pss10"];
        [params setValue:[cvc runJS:@"pssTotal;" withLock:NO] forKey:@"pssTotal"];
        [params setValue:[cvc runJS:@"pssLast;" withLock:NO] forKey:@"pssLast"];
        [params setValue:@"1" forKey:@"duringAssessment"];
        [params setValue:[cvc runJS:@"((dae.pss11 > 0) && (dae.pss12==1)) ? \"unsafe\" : \"safe\";" withLock:NO] forKey:@"userSafetyState"];
        [heartbeat logEvent:@"SELF_ASSESSMENT_SCORE" withParameters:params];
    }
    
    [currentCVC setVariable:key to:value];
    
    [key release];
    JSStringRelease(keyRef);
    return JSValueMakeNull(ctx);
}

JSValueRef jsGotoContent(JSContextRef ctx,
                       JSObjectRef function,
                       JSObjectRef thisObject,
                       size_t argumentCount,
                       const JSValueRef arguments[],
                       JSValueRef* exception)
{
    JSStringRef titleRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *ref = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, titleRef);
    JSStringRelease(titleRef);
    
    ContentViewController *cvc = currentCVC;
    [cvc navigateToContentName:ref];
    [ref release];
    return JSValueMakeUndefined(ctx);
}

JSValueRef jsRunDelayed(JSContextRef ctx,
                       JSObjectRef function,
                       JSObjectRef thisObject,
                       size_t argumentCount,
                       const JSValueRef arguments[],
                       JSValueRef* exception)
{
    double delay = JSValueToNumber(ctx, arguments[0], NULL);
    JSObjectRef func = JSValueToObject(ctx, arguments[1], NULL);
    JSValueProtect(ctx, func);
    
    ContentViewController *cvc = currentCVC;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        currentCVC = cvc;
        [scriptEngineLock lock];
        JSObjectCallAsFunction(_JSContext, func, NULL, 0, NULL, NULL);
        JSValueUnprotect(_JSContext, func);
        [scriptEngineLock unlock];
    });
    
    return JSValueMakeUndefined(ctx);
}

JSValueRef jsShowAlert(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSStringRef titleRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *title = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, titleRef);
    JSStringRelease(titleRef);
    
    JSStringRef msgRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[1], NULL);
    NSString *msg = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, msgRef);
    JSStringRelease(msgRef);

    NSString *cancelButtonTitle = @"Ok";
    NSMutableArray *otherButtonTitles = [NSMutableArray array];
    NSMutableArray *funcs = [NSMutableArray array];
    int buttonCount=0;
    for (int i=2;i<argumentCount;i+=2) {
        JSStringRef buttonTitleRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[i], NULL);
        NSString *buttonTitle = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, buttonTitleRef);
        JSStringRelease(buttonTitleRef);
        [buttonTitle autorelease];
        if (buttonCount == 0) {
            cancelButtonTitle = buttonTitle;
        } else {
            [otherButtonTitles addObject:buttonTitle];
        }
        
        JSObjectRef func = JSValueIsNull(ctx, arguments[i+1]) ? nil : JSValueToObject(ctx, arguments[i+1], NULL);
        if (func) JSValueProtect(ctx, arguments[i+1]);
        [funcs addObject:[NSValue valueWithPointer:func]];
        buttonCount++;
    }
    
    ContentViewController *cvc = currentCVC;

    [UIAlertView alertViewWithTitle:title message:msg cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles
                          onDismiss:^(int buttonIndex) {
                              JSObjectRef func = (JSObjectRef)[((NSValue*)[funcs objectAtIndex:1+buttonIndex]) pointerValue];
                              currentCVC = cvc;
                              [scriptEngineLock lock];
                              if (func) JSObjectCallAsFunction(_JSContext, func, NULL, 0, NULL, NULL);
                              for (NSValue *val in funcs) {
                                  JSObjectRef func = (JSObjectRef)[val pointerValue];
                                  if (func) JSValueUnprotect(_JSContext, func);
                              }
                              [scriptEngineLock unlock];
                          }
                           onCancel:^{
                               if (!funcs || !funcs.count) return;
                               
                               JSObjectRef func = (JSObjectRef)[((NSValue*)[funcs objectAtIndex:0]) pointerValue];
                               currentCVC = cvc;
                               [scriptEngineLock lock];
                               if (func) JSObjectCallAsFunction(_JSContext, func, NULL, 0, NULL, NULL);
                               for (NSValue *val in funcs) {
                                   JSObjectRef func = (JSObjectRef)[val pointerValue];
                                   if (func) JSValueUnprotect(_JSContext, func);
                               }
                               [scriptEngineLock unlock];
                          }];
    
    [msg release];
    [title release];
    return JSValueMakeNull(ctx);
}

JSValueRef jsGetVariable(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    NSObject *value = [currentCVC getVariable:key];
    
    JSValueRef r;
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber*)value;
            r = JSValueMakeNumber(ctx, [num doubleValue]);
        } else {
            JSStringRef valueRef = JSStringCreateWithUTF8CString([[NSString stringWithFormat:@"%@",value] UTF8String]);
            r = JSValueMakeString(ctx, valueRef);
            JSStringRelease(valueRef);
        }
    } else {
        r = JSValueMakeNull(ctx);
    }
    [key release];
    return r;
}

JSValueRef jsCountRefs(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    
    NSString *entityName = nil;
    
    if ([key isEqualToString:@"contact"]) {
        entityName = @"ContactReference";
    } else if ([key isEqualToString:@"audio"]) {
        entityName = @"AudioReference";
    } else if ([key isEqualToString:@"image"]) {
        entityName = @"ImageReference";
    }

    [key release];

    if (!entityName) {
        return JSValueMakeNull(ctx);
    }
    
    NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	int count = [context countForFetchRequest:fetchRequest error:NULL];

    return JSValueMakeNumber(ctx, count);
}

JSValueRef jsCountChildren(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSValueRef r;
    NSManagedObject *binding = (NSManagedObject*)[currentCVC getVariable:@"@binding"];
    NSOrderedSet *children = (NSOrderedSet*)[binding valueForKey:@"children"];
    if (children)
        r = JSValueMakeNumber(ctx, children.count);
    else
        r = JSValueMakeNumber(ctx, 0);
    return r;
}

JSValueRef jsGetSetting(JSContextRef ctx,
                         JSObjectRef function,
                         JSObjectRef thisObject,
                         size_t argumentCount,
                         const JSValueRef arguments[],
                         JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    NSObject *value = [[iStressLessAppDelegate instance] getSetting:key];
    
    JSValueRef r;
    if (value) {
        if ([value isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber*)value;
            r = JSValueMakeNumber(ctx, [num doubleValue]);
        } else {
            JSStringRef valueRef = JSStringCreateWithUTF8CString([[NSString stringWithFormat:@"%@",value] UTF8String]);
            r = JSValueMakeString(ctx, valueRef);
            JSStringRelease(valueRef);
        }
    } else {
        r = JSValueMakeNull(ctx);
    }
    [key release];
    return r;
}

JSValueRef jsSetSetting(JSContextRef ctx,
                        JSObjectRef function,
                        JSObjectRef thisObject,
                        size_t argumentCount,
                        const JSValueRef arguments[],
                        JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    JSStringRef valueRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[1], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    NSString *value = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, valueRef);
    
    NSLog(@"setSetting('%@',%@)",key,value);
    [[iStressLessAppDelegate instance] setSetting:key to:value];
    
    [key release];
    [value release];
    JSStringRelease(valueRef);
    JSStringRelease(keyRef);
    return JSValueMakeNull(ctx);
}

JSValueRef jsTimeSeriesCount(JSContextRef ctx,
                        JSObjectRef function,
                        JSObjectRef thisObject,
                        size_t argumentCount,
                        const JSValueRef arguments[],
                        JSValueRef* exception)
{
    int count = 0;
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",key]];
    
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
    count = a ? a.count : 0;
	
    [key release];
    JSStringRelease(keyRef);
    return JSValueMakeNumber(ctx,count);
}

JSValueRef jsTimeSeriesLastTime(JSContextRef ctx,
                             JSObjectRef function,
                             JSObjectRef thisObject,
                             size_t argumentCount,
                             const JSValueRef arguments[],
                             JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",key]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:FALSE]]];
    
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
    NSDate *time = (a && a.count) ? [[a objectAtIndex:0] valueForKey:@"time"] : nil;
    double t = [time timeIntervalSince1970];
	
    [key release];
    JSStringRelease(keyRef);
    return JSValueMakeNumber(ctx,t);
}

JSValueRef jsTimeSeriesLastValue(JSContextRef ctx,
                                JSObjectRef function,
                                JSObjectRef thisObject,
                                size_t argumentCount,
                                const JSValueRef arguments[],
                                JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"TimeSeries"];
    NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"series == %@",key]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:FALSE]]];
    
    NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
    double t = (a && a.count) ? [((NSNumber*)[[a objectAtIndex:0] valueForKey:@"value"]) doubleValue] : NAN;
    
    [key release];
    JSStringRelease(keyRef);

    if (isnan(t)) {
        return JSValueMakeNull(ctx);
    }
    
    return JSValueMakeNumber(ctx,t);
}
    
JSValueRef jsNow(JSContextRef ctx,
                                JSObjectRef function,
                                JSObjectRef thisObject,
                                size_t argumentCount,
                                const JSValueRef arguments[],
                                JSValueRef* exception)
{
    return JSValueMakeNumber(ctx,[[NSDate date] timeIntervalSince1970]);
}

JSValueRef jsAddToTimeSeries(JSContextRef ctx,
                             JSObjectRef function,
                             JSObjectRef thisObject,
                             size_t argumentCount,
                             const JSValueRef arguments[],
                             JSValueRef* exception)
{
    JSStringRef keyRef = (JSStringRef)JSValueToStringCopy(ctx, arguments[0], NULL);
    NSString *key = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, keyRef);
    double value = JSValueToNumber(ctx, arguments[1], NULL);

    NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
    NSManagedObject *newPoint = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSeries" inManagedObjectContext:context];
    [newPoint setValue:key forKey:@"series"];
    [newPoint setValue:[NSDate date] forKey:@"time"];
    [newPoint setValue:[NSNumber numberWithDouble:value] forKey:@"value"];
    [context save:nil];
	
    [key release];
    JSStringRelease(keyRef);
    return JSValueMakeNull(ctx);
}

JSValueRef daeGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) {
    NSString *val = nil;
    NSString *name = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, propertyName);
    val = [currentVariableBindings objectForKey:name];
    [name release];
    
    JSValueRef r = NULL;
    if (!val) {
        r = JSValueMakeUndefined(ctx);
    } else if ([val isKindOfClass:[NSNumber class]]) {
        r = JSValueMakeNumber(ctx, [((NSNumber*)val) doubleValue]);
    } else {
        JSStringRef ref = JSStringCreateWithUTF8CString([[NSString stringWithFormat:@"%@",val] UTF8String]);
        r = JSValueMakeString(ctx, ref);
        JSStringRelease(ref);
    }
    return r;
}

void addFunction(JSGlobalContextRef ctx, const char *name, JSObjectCallAsFunctionCallback cb) {
    JSStringRef str = JSStringCreateWithUTF8CString(name);
    JSObjectRef func = JSObjectMakeFunctionWithCallback(ctx, str, cb);
    JSObjectSetProperty(_JSContext, JSContextGetGlobalObject(ctx), str, func, kJSPropertyAttributeNone, NULL);
    JSStringRelease(str);
}

+ (JSGlobalContextRef)JSContext
{
    if (_JSContext == NULL) {
        _JSContext = JSGlobalContextCreate(NULL);
        scriptEngineLock = [[NSLock alloc] init];
        
        JSClassDefinition daeClass = kJSClassDefinitionEmpty;
        daeClass.getProperty = daeGetProperty;
        JSClassRef klass = JSClassCreate(&daeClass);
        JSObjectRef obj = JSObjectMake(_JSContext,klass,NULL);
        JSStringRef str = JSStringCreateWithUTF8CString("dae");
        JSObjectSetProperty(_JSContext, JSContextGetGlobalObject(_JSContext), str, obj, kJSPropertyAttributeNone, NULL);
        JSStringRelease(str);
        
        addFunction(_JSContext, "runDelayed", jsRunDelayed);
        addFunction(_JSContext, "setVariable", jsSetVariable);
        addFunction(_JSContext, "showAlert", jsShowAlert);
        addFunction(_JSContext, "getVariable", jsGetVariable);
        addFunction(_JSContext, "countChildren", jsCountChildren);
        addFunction(_JSContext, "setSetting", jsSetSetting);
        addFunction(_JSContext, "getSetting", jsGetSetting);
        addFunction(_JSContext, "timeSeriesCount", jsTimeSeriesCount);
        addFunction(_JSContext, "timeSeriesLastTime", jsTimeSeriesLastTime);
        addFunction(_JSContext, "timeSeriesLastValue", jsTimeSeriesLastValue);
        addFunction(_JSContext, "addToTimeSeries", jsAddToTimeSeries);
        addFunction(_JSContext, "gotoContent", jsGotoContent);
        addFunction(_JSContext, "countRefs", jsCountRefs);
        addFunction(_JSContext, "now", jsNow);
    }
    
    return _JSContext;
}

/**
 Runs a string of JS in this instance's JS context and returns the result as a string
 */
- (NSString *)runJS:(NSString *)aJSString {
    return [self runJS:aJSString withLock:YES];
}

- (NSString *)runJS:(NSString *)aJSString withLock:(BOOL)lock
{
    if (!aJSString) {
        NSLog(@"[JSC] JS String is empty!");
        return nil;
    }
    
    JSStringRef scriptJS = JSStringCreateWithUTF8CString([aJSString UTF8String]);
    JSValueRef exception = NULL;
    
    JSContextRef ctx = [ContentViewController JSContext];
    
    if (lock) {
        [scriptEngineLock lock];
    }
    
    currentCVC = self;
    currentVariableBindings = [self variables];
    
    JSValueRef result = JSEvaluateScript(ctx, scriptJS, NULL, NULL, 0, &exception);
    NSString *res = nil;
    
    if (!result) {
        if (exception) {
            JSStringRef exceptionArg = JSValueToStringCopy([ContentViewController JSContext], exception, NULL);
            NSString* exceptionRes = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, exceptionArg);
            JSStringRelease(exceptionArg);
            NSLog(@"[JSC] JavaScript exception: %@", exceptionRes);
            [exceptionRes release];
        }
        
        NSLog(@"[JSC] No result returned");
    } else {
        if (JSValueIsUndefined(ctx, result) || JSValueIsNull(ctx, result)) {
            res = @"";
        } else {
            JSStringRef jstrArg = JSValueToStringCopy([ContentViewController JSContext], result, NULL);
            res = (NSString*)JSStringCopyCFString(kCFAllocatorDefault, jstrArg);
            [res autorelease];
            JSStringRelease(jstrArg);
        }
    }
    
    JSStringRelease(scriptJS);
    
    currentCVC = nil;
    currentVariableBindings = nil;
    
    if (lock) {
        [scriptEngineLock unlock];
    }
    
    return res;
}

-(NSString*)checkPrerequisite {
    return nil;
}

-(void)addChildContentController:(ContentViewController*)child {
    if (!_childContentControllers) {
        _childContentControllers = [[NSMutableArray array] retain];
    }
    [_childContentControllers addObject:child];
}

-(void)removeChildContentController:(ContentViewController*)child {
    [_childContentControllers removeObject:child];
}

-(void)contentBecameVisible {
    NSString *name = self.content.name;
    NSString *onShow = [self.content getExtraString:@"onshow"];
    if (onShow) {
        NSLog(@"%@",name);
        [self performAction:onShow withSource:self.content];
    }
    
    [self updateEnablements];
}

-(void)contentBecameVisibleForFirstTime {
}

-(void)contentBecameInvisible {
}

-(void)updateContentVisibilityForChild:(ContentViewController*)child {
    child.contentVisible = self.contentVisible;
}

-(void)updateContentVisibilityForChildren {
    for (ContentViewController *child in self.childContentControllers) {
        [self updateContentVisibilityForChild:child];
    }
    //[self reportVisibilityWithIndent:0];
}

-(void)reportVisibilityWithIndent:(int)indent {
    NSMutableString *indentStr = [NSMutableString string];
    for (int i=0;i<indent;i++) [indentStr appendString:@"  "];
    NSLog(@"%@%@(%@/%@):%@",indentStr,NSStringFromClass(self.class),self.content.name,self.content.displayName,self.contentVisible ? @"TRUE":@"FALSE");
    if (self.masterController) [self.masterController reportVisibilityWithIndent:indent+1];
}

-(void)contentVisibilityChanged {
    if (self.contentVisible) {
        if (!_contentEverVisible) {
            _contentEverVisible = TRUE;
            [self contentBecameVisibleForFirstTime];
        }
        [self contentBecameVisible];
    } else {
        [self contentBecameInvisible];
    }
    [self updateContentVisibilityForChildren];
}

-(void)setContentVisible:(BOOL)contentVisible {
    if (_contentVisible != contentVisible) {
        _contentVisible = contentVisible;
        [self contentVisibilityChanged];
    }
}

-(BOOL)contentVisible {
    return _contentVisible;
}

-(NSMutableDictionary*) makeContentDescriptor {
    NSManagedObject *c = self.content;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (c) {
        NSString *val;

        val = [c valueForKey:@"name"];
        if (val) [params setObject:val forKey:@"name"];
        val = [c valueForKey:@"displayName"];
        if (val) [params setObject:val forKey:@"displayName"];
        val = [c valueForKey:@"uniqueID"];
        if (val) [params setObject:val forKey:@"uniqueID"];
    }
    return params;
}

- (void) pushExecLeaf:(ContentViewController*)cvc {
    if (!self.execStack) self.execStack = [NSMutableArray array];
    [self.execStack addObject:cvc];
    [cvc execInsteadOfPush];
}

- (BOOL) popExecLeaf:(ContentViewController*)vc {
    if ([self.execStack containsObject:vc]) {
        [self.execStack removeObject:vc];
        return TRUE;
    }
    
    return FALSE;
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
//    CGSize kbSize = keyboardRect.size;
    CGRect convertedKeyboardRect = [self.view.superview convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = convertedKeyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    UIView *v = [self.view.window findFirstResponder];
    UIView *parent = v.superview;
    UIScrollView *scroller = nil;
    while (parent != nil) {
        if ([parent isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView*)parent;
            if (sv.isScrollEnabled) {
                scroller = sv;
                break;
            }
        }
        parent = parent.superview;
    }
    
    self.originalViewHeight = self.view.frame.size.height;
    CGRect rectInScroller = [scroller convertRect:v.bounds fromView:v];
    rectInScroller.size.height += 20;
    NSLog(@"originalViewHeight = %f",self.originalViewHeight);
    NSLog(@"rectInScroller = (%f,%f,%f,%f)",rectInScroller.origin.x,rectInScroller.origin.y,rectInScroller.size.width,rectInScroller.size.height);
    CGPoint contentOffset = [scroller contentOffset];
    NSLog(@"contentOffset = (%f,%f)",contentOffset.x, contentOffset.y);
    self.adjustedScroller = scroller;

    [UIView animateWithDuration:animationDuration animations:^{
        CGRect r = self.view.frame;
        r.size.height = keyboardTop - r.origin.y;
        NSLog(@"newFrame = (%f,%f,%f,%f)",r.origin.x,r.origin.y,r.size.width,r.size.height);
        //r.size.height = 100;
        //CGPoint pt = scroller.contentOffset;
        //pt.y = rectInScroller.origin.y;
        //scroller.contentOffset = pt;
//        self.view.frame = r;
    
        CGRect convertedKeyboardRect = [scroller.superview convertRect:keyboardRect fromView:nil];
        r = scroller.frame;
        self.originalScrollerHeight = r.size.height;
        r.size.height = convertedKeyboardRect.origin.y - r.origin.y;
        scroller.frame = r;
    
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    
        [scroller scrollRectToVisible:rectInScroller animated:TRUE];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.originalViewHeight != -1) {

        NSDictionary* info = [aNotification userInfo];
        NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        UIScrollView *scroller = self.adjustedScroller;

        CGRect r = self.view.frame;
        float delta = self.originalViewHeight - r.size.height;
        
//        CGPoint offs = scroller.contentOffset;
        CGSize size = scroller.contentSize;
        size.height += delta;

        CGRect frame = r;
        frame.size.height = self.originalViewHeight;
//        self.view.frame = frame;

        [UIView animateWithDuration:animationDuration animations:^{
        CGRect r = scroller.frame;
        r.size.height = self.originalScrollerHeight;
        scroller.frame = r;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
//        scroller.contentSize = size;
//        scroller.contentOffset = offs;

//            CGSize sz = size;
//            sz.height -= delta;
//            scroller.contentSize = sz;
        }];
        self.originalViewHeight = -1;
        self.originalScrollerHeight = -1;
        self.adjustedScroller = nil;
    }
}
/*
-(UIAccessibilityElement*)findAccessibilityFocusIn:(UIView*)elementOrContainer {
    if ([elementOrContainer respondsToSelector:@selector(accessibilityElementCount)]) {
        int count = [elementOrContainer accessibilityElementCount];
        if ((count > 0) && (count != 2147483647)) {
            for (int i=0;i<count;i++) {
                UIAccessibilityElement *elm = [elementOrContainer accessibilityElementAtIndex:i];
                if (!elm) return nil;
                if ([elm respondsToSelector:@selector(accessibilityElementIsFocused)]) {
                    if ([elm accessibilityElementIsFocused]) {
                        return elm;
                    }
                }
            }
        }

        int childCount = [elementOrContainer subviews].count;
        for (int i=0;i<childCount;i++) {
            UIView* v = (UIView*)[[elementOrContainer subviews] objectAtIndex:i];
            UIAccessibilityElement *elm = [self findAccessibilityFocusIn:v];
            if (elm) return elm;
        }
    }
    return nil;
}

-(void) saveAccessibilityFocus {
    UIView *v = self.view;
    self.lastAccessibilityFocus = [self findAccessibilityFocusIn:v];
}

-(void) restoreAccessibilityFocus {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.lastAccessibilityFocus);
}
*/
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.scrollView) {
        [self.scrollView flashScrollIndicators];
    }
    /*
	if (self.masterController) {
		[self.masterController slaveViewDidAppear:self];
	}
*/
    //NSDictionary *params = [self makeContentDescriptor];
    
    timeAppeared = [EventLog timestamp];
 
    if (_inTransition) {
        self.view.userInteractionEnabled = _nonTransitionUIEnablement;
        _inTransition = NO;
    }
    
    if (!self.isInlineContent) {
        Content *parentContent = (Content*)self.content.parent;
        NSString *parentUI = parentContent.ui;
        if ([parentUI isEqualToString:@"TabController"]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillShow:)
                                                         name:UIKeyboardWillShowNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(keyboardWillBeHidden:)
                                                         name:UIKeyboardWillHideNotification object:nil];
        }
    }
//    [self restoreAccessibilityFocus];
}

-(BOOL)inTransition {
    return _inTransition;
}

-(void)setInTransition:(BOOL)inTransition {
    if (inTransition && !_inTransition) {
        _nonTransitionUIEnablement = self.view.userInteractionEnabled;
        self.view.userInteractionEnabled = NO;
    }
    _inTransition = inTransition;
}

-(void)viewDidDisappear:(BOOL)animated {
    if (_inTransition) {
        self.view.userInteractionEnabled = _nonTransitionUIEnablement;
        _inTransition = NO;
    }
    [super viewDidDisappear:animated];
}

-(BOOL) shouldExecInsteadOfPush {
    return false;
}

-(void) execInsteadOfPush {
}

-(BOOL)buttonsAreFixed {
    return [self.content getExtraBoolean:@"fixedButtons"];
}

- (BOOL)navigateToContent:(Content *)content {
    return [[iStressLessAppDelegate instance] navigateToContent:content];
}

- (BOOL)navigateToContent:(Content *)content withData:(NSDictionary *)data {
    return [[iStressLessAppDelegate instance] navigateToContent:content withData:data];
}

- (BOOL)navigateToContentName:(NSString *)contentName {
    return [self navigateToContentName:contentName withData:nil];
}

- (BOOL)navigateToContentName:(NSString *)contentName withData:(NSDictionary *)data {
    Content * c = [self.content getChildByName:contentName];
    if (c) {
        [self navigateToNextContent:c];
        return TRUE;
    }
    
    if (self.isInlineContent && self.masterController) {
        return [self.masterController navigateToContentName:contentName];
    }
    
    c = [[iStressLessAppDelegate instance] getContentWithName:contentName];
    return [[iStressLessAppDelegate instance] navigateToContent:c withData:data];
}

- (BOOL)navigateToChildController:(ContentViewController *)childController {
    return FALSE;
}

- (BOOL) navigateToContentWithPath:(NSArray *)path startingAt:(int)index from:(ContentViewController*)cvc withData:(NSDictionary *)data {
    return [self navigateToContentWithPath:path startingAt:index withData:data];
}

- (BOOL)navigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary *)data {
    Content *next = [path objectAtIndex:index];
    for (ContentViewController *cvc in self.childContentControllers) {
        if (cvc.content == next) {
            BOOL r = cvc.isInlineContent || [self navigateToChildController:cvc];
            if (!r) return r;
            if (index < path.count-1) {
                return [cvc navigateToContentWithPath:path startingAt:index+1 withData:data];
            }
            return TRUE;
        }
    }
/*
    if (self.masterController) {
        BOOL r = [self.masterController navigateToContentWithPath:path startingAt:index from:self];
        if (r) return r;
    }
*/
    for (Content *childContent in self.content.properChildren) {
        if (next == childContent) {
            [UIView transitionWithView:self.navigationController.view
                              duration:0.75
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                            if ([[self.navigationController viewControllers] containsObject:self]) {
                                                [self.navigationController popToViewController:self animated:TRUE];
                                            }
                                        }
                            completion:^(BOOL finished){
                                            [self managedObjectSelected:next];
                                            if (index < path.count-1) {
                                                NSLog(@"Currently can't traverse %@",next);
                                            }
                                        }
            ];
            return TRUE;
        }
    }
    
    NSLog(@"Failed content navigation for %@",next);
    return FALSE;
}

-(NSArray*) getCaptions {
    if (captions != nil) {
        return captions;
    }
    
    if (captionsChecked) {
        return nil;
    }

    captionsChecked = TRUE;
    
    NSString *ccOn = [[iStressLessAppDelegate instance] getSetting:@"ccOn"];
    _captionsEnabled = [ccOn isEqualToString:@"true"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Caption" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:50];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@",self.content]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];

	NSArray *a = [self.content.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    [fetchRequest release];
	if (a.count == 0) return nil;
    
    captions = a;
    [captions retain];
	return captions;
}

-(Content*) getSiblingContentWithName:(NSString*)name {
    NSManagedObject *parent = [self.content valueForKey:@"parent"];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND name == %@",parent, name]];
	NSArray *a = [self.content.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (a.count > 0) return [a objectAtIndex:0];
	return nil;
}

-(ContentViewController*) getSiblingControllerWithName:(NSString*)name {
	return [[iStressLessAppDelegate instance] getContentControllerForObject:[self getSiblingContentWithName:name]];
}

-(Content*) getChildContentWithName:(NSString*)name forContent:(NSManagedObject*)obj {
    if (!obj.managedObjectContext) return nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:obj.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND name == %@",obj, name]];
	NSArray *a = [obj.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	if (a.count > 0) return [a objectAtIndex:0];
	return nil;
}

-(Content*) getContentWithName:(NSString*)name {
    return [[iStressLessAppDelegate instance] getContentWithName:name];
}

-(Content*) getChildContentWithName:(NSString*)name {
    return [self getChildContentWithName:name forContent:self.content];
}

-(NSArray*) getChildContentList {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.content.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:1000];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"parent == %@ AND NOT name BEGINSWITH %@",self.content, @"@"]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray * sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
	[sortDescriptor release];
	[sortDescriptors release];
	
	NSArray *a = [self.content.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
	[fetchRequest release];
	return a;
}

-(ContentViewController*) getChildControllerWithName:(NSString*)name {
	return [[iStressLessAppDelegate instance] getContentControllerForObject:[self getChildContentWithName:name]];
}

-(Content*)nextContent {
    // this is not a good way of doing it, but its the best option given the design
    NSString *title = [[self content] title] ? [[self content] title] : @"";
    NSUInteger numMatches = [[NSRegularExpression regularExpressionWithPattern:@"Question \\d?\\d? of \\d?\\d?" options:0 error:nil] numberOfMatchesInString:title options:0 range:NSMakeRange(0, [title length])];
    if (numMatches > 0 || [title isEqualToString:@"Stress"] || [title isEqualToString:@"Safety"]) {
        RadioController *radio = (RadioController *)self;
        Content *content = (Content*)[radio managedObjectForIndexPath:[NSIndexPath indexPathForRow:[[radio selection] integerValue] inSection:0]];
        [heartbeat logEvent:@"SELF_ASSESSMENT_ANSWER" withParameters:@{@"question":[[self content] getExtraString:@"selectionVariable"], @"answer":[content displayName]}];
    }
	return [self getChildContentWithName:@"@next"];
}

-(ContentViewController*)getNextController {
	return [self getChildControllerWithName:@"@next"];
}

- (void) setVariable:(NSString*)key to:(NSObject*)value {
    if (!self.masterController || self.scoping) {
        [super setVariable:key to:value];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self relayout];
        });
        return;
    }
	[self.masterController setVariable:key to:value];
}

- (NSObject*) getVariable:(NSString*)key {
	id val = [self.variables objectForKey:(NSString *)key];
    if (val == [NSNull null]) return nil;
    return val;
}

- (void) clearVariable:(NSString*)key {
    if (!self.masterController || self.scoping) {
        if (!self.localVariables) return;
        [self.localVariables removeObjectForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self relayout];
        });
        return;
    }
	[self.masterController clearVariable:key];
}

- (void) clearVariables {
    if (!self.masterController || self.scoping) {
        [self.localVariables removeAllObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self relayout];
        });
        return;
    }
	[self.masterController clearVariables];
}

-(void) setVars {
	if (self.masterController && self.content) {
		NSDictionary *dict = [self.content getExtrasDict];
		if (dict) {
			for (NSString *key in dict) {
				if ([key hasPrefix:@"variable_"]) {
					NSString *name = [key substringFromIndex:9];
					NSString *value = [dict valueForKey:key];
					[self setVariable:name to:value];
				}
			}
		}
	}
};

- (id)init {
	self=[super init];
	[self privateInit];
    captionTimer = nil;
    firstCaptionStart = nil;
    captionView = nil;
    captions = nil;
    captionsChecked = FALSE;
    _captionsEnabled = FALSE;
    viewTypeID = 2;
	return self;
}

-(NSTimer*) captionTimer {
    return captionTimer;
}

-(int) captionIndex {
    return captionIndex;
}

-(int) captionState {
    return captionState;
}

-(NSString*) captionText {
    return captionText;
}

-(UILabel*) captionView {
    return captionView;
}

-(NSDate*) captionEnd {
    return [NSDate dateWithTimeInterval:captionEnd/1000.0f sinceDate:firstCaptionStart];
}

-(void) setEnables {
}

-(void) setCaptionState:(int)state {
    captionState = state;
}

-(void) showCaption {    
    CGSize size = [captionText sizeWithFont:captionView.font constrainedToSize:CGSizeMake(captionView.frame.size.width, 1000) lineBreakMode:UILineBreakModeWordWrap];
    captionView.text = captionText;
    CGRect r = captionView.frame;
    float bottom = r.origin.y + r.size.height;
    r.origin.y = bottom - size.height - 20;
    r.size.height = size.height + 20;
    captionView.frame = r;
    captionState = 1;

    if (self.captionsEnabled) {
        [UIView beginAnimations:@"showCaption" context:nil];
        [UIView setAnimationDuration:0.5];
        captionView.alpha = 1;
        [UIView commitAnimations];
    }
}

-(void) hideCaption {
    if (self.captionsEnabled) {
        [UIView beginAnimations:@"hideCaption" context:nil];
        [UIView setAnimationDuration:0.5];
        captionView.alpha = 0;
        [UIView commitAnimations];
    }
    [self scheduleNextCaption];
}

-(BOOL)captionsEnabled {
    return _captionsEnabled;
}

-(BOOL)dispatchContentEvent:(ContentEvent*)event {
    if (event.eventType == CONTENT_EVENT_GATHER_NAV_STACK) {
        NSMutableArray *items = (NSMutableArray*)event.data;
        [self gatherNavigationItems:items];
        return TRUE;
    } else if (event.eventType == CONTENT_EVENT_BACK_PRESSED) {
        [self goBack];
        return TRUE;
    }
    
    return FALSE;
}

-(void)setCaptionsEnabled:(BOOL)on {
    if (_captionsEnabled == on) return;
    if (!on) {
        _captionsEnabled = FALSE;
        if (captionState) captionView.alpha = 0;
        [[iStressLessAppDelegate instance] setSetting:@"ccOn" to:@"false"];
    } else {
        _captionsEnabled = TRUE;
        if (captionState) captionView.alpha = 1;
        [[iStressLessAppDelegate instance] setSetting:@"ccOn" to:@"true"];
    }
}

-(void) scheduleNextCaption {
    if (!captions) return;
    if (captionIndex >= captions.count) {
        // No more captions
        if (captionTimer) {
            [captionTimer invalidate];
            [captionTimer release];
            captionTimer = nil;
        }
        return;
    }

    if (!captionView) {
        ThemeManager *theme = [ThemeManager sharedManager];
        NSString *fontName = [theme stringForName:@"textFont"];
        float fontSize = [theme floatForName:@"textSize"];
        UIFont *font = [UIFont fontWithName:fontName size:fontSize];
        
        CGRect r = CGRectMake(20, 180, 280, 137);
        captionView = [[UILabel alloc] initWithFrame:r];
        captionView.textAlignment = UITextAlignmentCenter;
        captionView.textColor = [UIColor whiteColor];
        captionView.font = font;
        captionView.shadowColor = [UIColor blackColor];
        captionView.shadowOffset = CGSizeMake(1, 1);
        captionView.numberOfLines = 10;
        captionView.lineBreakMode = UILineBreakModeWordWrap;
        captionView.userInteractionEnabled = FALSE;
        captionView.contentMode = UIViewContentModeBottom;
        captionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        captionView.layer.cornerRadius = 10;
        captionView.alpha = 0;
        [topView addSubview:captionView];
    } else {
        captionView.alpha = 0;
    }
    
    captionState=0;
    
    NSManagedObject *caption = [captions objectAtIndex:captionIndex];
    int startMs = [[caption valueForKey:@"start"] intValue];
    captionEnd = [[caption valueForKey:@"end"] intValue];
	NSDate *startDate = [NSDate dateWithTimeInterval:startMs/1000.0f sinceDate:firstCaptionStart];
    if (captionText) [captionText release];
    captionText = [caption valueForKey:@"mainText"];
    [captionText retain];
    
    __block ContentViewController *weakSelf = self;

    captionIndex++;

    if (captionTimer) {
        [captionTimer setFireDate:startDate];
    } else {
        GFunctor *f = [[GFunctor alloc] initWithBlock:^{
            if ([weakSelf captionState] == 0) {
                // caption start
                NSLog(@"%@\n",[weakSelf captionText]);
                [weakSelf showCaption];
                [[weakSelf captionTimer] setFireDate:[weakSelf captionEnd]];
            } else {
                // caption end
                NSLog(@"(done)\n");
                [weakSelf hideCaption];
            }
        }];
        captionTimer = [[NSTimer alloc] initWithFireDate:(NSDate *)startDate interval:10000 target:f selector:@selector(invoke) userInfo:nil repeats:YES];	
        [[NSRunLoop currentRunLoop] addTimer:captionTimer forMode:NSRunLoopCommonModes];
        [f release];
    }

}

- (void) playAudio {
	NSString *audioFN = self.content.audio;
	if (self.player) {
		[self.player stop];
		self.player = nil;
	}
    NSLog(@"%@",audioFN);
    [self getCaptions];
    NSString *contentPath = [self contentPathForName:audioFN];
    NSURL *url = [NSURL fileURLWithPath:contentPath];
    NSLog(@"%@",url);
    NSError *error;
	self.player = [[[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error] autorelease];
	[self.player play];
    if ([self getCaptions]) {
        captionIndex = 0;
        firstCaptionStart = [NSDate date];
        [firstCaptionStart retain];
        [self scheduleNextCaption];
    }
}

- (void)call911 {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:911"]];
}

-(void) updateEnablements {
    for (int i=0;i<self.buttons.count;i++) {
        [[self.buttons objectAtIndex:i] updateEnablement:self];
    }
}

-(BOOL)evalJSPredicate:(NSString*)predicate {
    NSString *val = [self runJS:predicate];
    if (!val) return FALSE;
    if ([val isEqualToString:@""]) return FALSE;
    if ([val isEqualToString:@"false"]) return FALSE;
    if ([val isEqualToString:@"0"]) return FALSE;
    return TRUE;
}

-(NSString*)evalJS:(NSString*)predicate {
    NSString *r = [self runJS:predicate];
    return r;
}

- (void) finishVisitLink {
    UIApplication *app = [UIApplication sharedApplication];
    if (![app openURL:pendingURL]) {
        if ([[pendingURL scheme] isEqualToString:@"tel"]) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot dial number" 
                                                             message:@"Cannot dial out.  This may be because you are on an iPod or iPad rather than an iPhone.  Please use a phone, computer, or other device to call this number." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
             [alert show];
             [alert release];
        }
    }
}

- (void) visitLink:(NSURL*)url {
    if (pendingURL) [pendingURL release];
    pendingURL = url;
    [pendingURL retain];

    BOOL is911 = FALSE;
    if ([[pendingURL scheme] isEqualToString:@"tel"]) {
        NSString *number = [url resourceSpecifier];
        if ([number isEqualToString:@"911"]) {
            is911 = TRUE;
        }
    }
    
    if (UIAccessibilityIsVoiceOverRunning() || is911) {
        AlertDelegate *alertDelegate = [[AlertDelegate alloc] init];
        alertDelegate.target = self;
        alertDelegate.targetSelector = @selector(finishVisitLink);
        NSString *title = @"Visit link?";
        NSString *body = @"This will leave the application.  Are you sure?";
        if ([[pendingURL scheme] isEqualToString:@"tel"]) {
            title = @"Dial number?";
            NSString *number = [url resourceSpecifier];
            if ([number isEqualToString:@"911"]) {
                title = @"Dial 911?";
                body = @"This will leave the application and dial 911.  Are you sure?";
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:body delegate:alertDelegate cancelButtonTitle:@"Never mind" otherButtonTitles:@"Yes, I'm sure", nil];
        [alert show];
        [alert release];
    } else {
        [self finishVisitLink];
    }
}

- (BOOL)webViewLinkTapped:(NSURL*)url {
//	NSLog(@"tapped %@",url);

    if ([[url scheme] isEqualToString:@"content"]) {
        NSString *contentName = url.path;
        if ([contentName hasPrefix:@"/"]) contentName = [contentName substringFromIndex:1];
        return [self navigateToContentName:contentName];
    }
    
	if ([[url path] isEqual:@"/listen"]) {
		if (self.player && self.player.playing) {
			[self.player stop];
			self.player = nil;
		} else {
			[self playAudio];
		}
		return FALSE;
	}
	
    [self visitLink:url];
	return FALSE;
}

+(NSMutableDictionary*) makeContentDescriptor:(NSManagedObject*)c {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (c) {
        NSString *val;
        
        if ([c.entity.attributesByName objectForKey:@"name"] != nil) {
            val = [c valueForKey:@"name"];
            if (val) [params setObject:val forKey:@"name"];
        }
        if ([c.entity.attributesByName objectForKey:@"displayName"] != nil) {
            val = [c valueForKey:@"displayName"];
            if (val) [params setObject:val forKey:@"displayName"];
        }
        if ([c.entity.attributesByName objectForKey:@"uniqueID"] != nil) {
            val = [c valueForKey:@"uniqueID"];
            if (val) [params setObject:val forKey:@"uniqueID"];
        }
    }
    return params;
}

- (void)performRefAction:(NSString*)action withSource:(Content*)source {
    if ([action isEqualToString:@"pop"]) {
        [self goBack];
    } else if ([action hasPrefix:@"clear:"]) {
        action = [action substringFromIndex:6];
        [self clearVariable:action];
    } else {
        [self performAction:action withSource:source];
    }
}

-(void) registerAction:(NSString*)action withSelector:(SEL)selector{
    if (!self.localActions) self.localActions = [NSMutableDictionary dictionary];
    NSValue *selectorAsValue = [NSValue valueWithBytes:&selector objCType:@encode(SEL)];
    [self.localActions setObject:selectorAsValue forKey:action];
}

- (BOOL)performAction:(NSString*)action withSource:(Content*)source fromChild:(ContentViewController*)child {
    BOOL r = [self tryPerformAction:action withSource:source];
    if (r) return TRUE;
    return [self.masterController performAction:action withSource:source fromChild:self];
}

- (BOOL)performAction:(NSString*)action withSource:(Content*)source {
    BOOL r = [self tryPerformAction:action withSource:source];
    if (r) return TRUE;
    return [self.masterController performAction:action withSource:source fromChild:self];
}

- (BOOL)tryPerformAction:(NSString*)action withSource:(Content*)source {
    if (self.localActions) {
        NSValue *selectorAsValue = [self.localActions objectForKey:action];
        if (selectorAsValue) {
            SEL selector;
            [selectorAsValue getValue:&selector];
            [self performSelector:selector withObject:source];
            return TRUE;
        }
    }

    if ([action isEqualToString:@"pop"]) {
        [self goBack];
        return TRUE;
    }

    if ([action isEqualToString:@"next"]) {
        [self navigateToNext];
        return TRUE;
    }

    if ([action hasPrefix:@"js:"]) {
        NSString *s = [action substringFromIndex:3];
        [self evalJS:s];
        return TRUE;
    }
    
    for (ContentViewController *child in self.childContentControllers) {
        BOOL r = [child tryPerformAction:action withSource:source];
        if (r) return TRUE;
    }
    
    return FALSE;
}

-(void)navigationDataReceived:(NSDictionary *)data {
    
}

- (BOOL)branchNavigateToContentWithPath:(NSArray *)path startingAt:(int)index withData:(NSDictionary *)data {
    return FALSE;
}

- (void) managedObjectSelected:(NSManagedObject*)mo {
//    NSMutableDictionary *params = [ContentViewController makeContentDescriptor:mo];
    
    if (self.inTransition) return;
    
    if ([[[mo entity] name] isEqualToString:@"Content"]) {
        [ContentObjectSelectedEvent logWithContentObjectName:[mo valueForKey:@"name"] withContentObjectDisplayName:[mo valueForKey:@"displayName"] withContentObjectId:[mo valueForKey:@"uniqueID"]];
        
        /*[FlurryAPI
         logEvent:@"CONTENT_SELECTED"
         withParameters:params];*/
        NSString *displayName = [mo valueForKey:@"displayName"] ? [mo valueForKey:@"displayName"] : @"BACK";
        if ([[mo valueForKey:@"icon"] isEqualToString:@"home_icon.png"]) {
            displayName = @"Home";
        }
        [heartbeat logEvent:@"CONTENT_SELECTED" withParameters:@{@"buttonName":displayName, @"uniqueID":[mo valueForKey:@"uniqueID"]}];
    }
    
    if ([mo isKindOfClass:[Content class]]) {
        Content *c = (Content*)mo;
        if (c.ref && ![c getExtraBoolean:@"inlineRef"]) {
            NSString *refAction = [c getExtraString:@"refAction"];
            // XXX Clear must happen before, others must happen after
            if ([refAction hasPrefix:@"clear:"] || [refAction hasPrefix:@"pop:"]) {
                [self performRefAction:refAction withSource:c];
            }
            [[iStressLessAppDelegate instance] navigateToContent:c.ref];
            if (![refAction hasPrefix:@"clear:"] && ![refAction hasPrefix:@"pop:"]) {
                [self performRefAction:refAction withSource:c];
            }
        } else if ([c getExtraString:@"href"]) {
            NSURL *url = [NSURL URLWithString:[c getExtraString:@"href"]];
            [self visitLink:url];
        } else {
            NSString *action = [c getExtraString:@"action"];
            if (action) {
                [self performAction:action withSource:c];
                return;
            }
            NSString *selectionVariable = [self.content getExtraString:@"selectionVariable"];
            BOOL selectOnly = [self.content getExtraBoolean:@"selectOnly"];
            if (selectionVariable) {
                [self setVariable:selectionVariable to:c];
                if (selectOnly) {
                    [self goBack];
                } else {
                    [self navigateToNext];
                }
            } else {
                [self navigateToNextContent:c];
            }
        }
    } else {
        NSString *selectionVariable = [self.content getExtraString:@"selectionVariable"];
        BOOL selectOnly = [self.content getExtraBoolean:@"selectOnly"];
        if (selectionVariable) {
            [self setVariable:selectionVariable to:mo];
            if (selectOnly) {
                [self goBack];
            } else {
                [self navigateToNext];
            }
        }
    }
}

-(Content*)leftBarButtonContent {
	return [self getChildContentWithName:@"@left"];
}

-(void)leftBarButtonTapped {
    Content *leftContent = [self.content getChildByName:@"@left"];

    NSString *label = leftContent && leftContent.displayName ? leftContent.displayName : @"LEFT";
    
    NSMutableDictionary *params = [self makeContentDescriptor];
    [params setObject:label forKey:@"buttonName"];
    
    [ButtonPressedEvent logWithButtonPressedButtonId:label withButtonPressedButtonTitle:nil];
    
    [heartbeat
     logEvent:@"BUTTON_PRESS"
     withParameters:params];
    
	if (leftContent) {
        [self managedObjectSelected:leftContent];
	}
}

-(Content*)rightBarButtonContent {
	return [self getChildContentWithName:@"@right"];
}

-(void)rightBarButtonTapped {
    Content *rightContent = [self rightBarButtonContent];
	if (rightContent) {
        [self managedObjectSelected:rightContent];
	}
}

-(void)backBarButtonTapped {
    Content *leftContent = [self.content getChildByName:@"@back"];

    VoidBlock completion = ^{
        NSString *label = leftContent && leftContent.displayName ? leftContent.displayName : @"BACK";
        
        NSMutableDictionary *params = [self makeContentDescriptor];
        [params setObject:label forKey:@"buttonName"];
        if ([[leftContent icon] isEqualToString:@"home_icon.png"]) {
            [params setObject:@"Home" forKey:@"buttonName"];
        }
        
        [ButtonPressedEvent logWithButtonPressedButtonId:label withButtonPressedButtonTitle:nil];
        
        [heartbeat
         logEvent:@"BUTTON_PRESS"
         withParameters:params];
        
        if (leftContent) {
            [self managedObjectSelected:leftContent];
        }
    };
    
    NSString *confirmationMsg = [leftContent getExtraString:@"confirmation"];
    if (confirmationMsg) {
        [UIAlertView alertViewWithTitle:@"Confirmation" message:confirmationMsg cancelButtonTitle:@"Never mind" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex) {
            completion();
        } onCancel:^{
        }];
    } else {
        completion();
    }
}

-(Content*)helpContent {
	NSManagedObject *o = self.content.help;
	if (o) return (Content*)o;
	return [self getChildContentWithName:@"@help"];
}

-(Content*)addContent {
	return [self getChildContentWithName:@"@add"];
}

-(void) setMasterController:(ContentViewController *)_master {
	if (self.masterController != _master) {
		[super setMasterController:_master];
		[self setVars];
	}
}
/*
-(void)addTapped {
	NSManagedObject *addContent = [self addContent];
	if (addContent) {
		ContentViewController *contentViewController = [[iStressLessAppDelegate instance] getContentControllerForObject:addContent withDefaultUI:@"ContentViewController"];
		[self.navigationController pushViewController:contentViewController animated:YES];
	}
}
*/
-(void) configureMetaContent {
	NSString * title = [self.content valueForKey:@"title"];
    if (!title) title = self.bestInlineTitle;
	if (!title) title = [self.content valueForKey:@"displayName"];
    title = [self replaceVariables:title];
    /*
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20.0];
    titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    titleView.textColor = [UIColor yellowColor]; // Change to desired color
    
    self.navigationItem.titleView = titleView;
    [titleView release];
    titleView.text = title;
    [titleView sizeToFit];
     */
    
	self.navigationItem.title = title;
    
	NSString * backButton = [self.content valueForKey:@"backButton"];
    if (!backButton) backButton = @"Back";
    if ([backButton isEqualToString:@"Home"]) {
        ThemeManager *theme = [ThemeManager sharedManager];
        NSString *homeIconName = [theme stringForName:@"homeIcon"];
        UIImage *homeIcon = [UIImage imageNamed:homeIconName];
        if (homeIcon) {
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:homeIcon style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        } else {
            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:backButton style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
        }
    } else {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:backButton style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    }
	
    Content *helpContent = [self helpContent];
	if (helpContent) {
        UIImage *icon = helpContent.uiIcon;
        if (!icon) {
            ThemeManager *theme = [ThemeManager sharedManager];
            NSString *helpIconName = [theme stringForName:@"helpIcon"];
            icon = [UIImage imageNamed:helpIconName];
        }
        if (icon) {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(helpTapped)] autorelease];
        } else {
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(helpTapped)] autorelease];
        }
	} else {
        Content *rightContent = [self rightBarButtonContent];
        if (rightContent) {
            title = rightContent.displayName;
            UIImage *icon = rightContent.uiIcon;
            if (icon) {
                self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTapped)] autorelease];
            } else {
                self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonTapped)] autorelease];
            }
        }
    }
	

	Content *left = [self leftBarButtonContent];
	if (left) {
		title = left.displayName;
        UIImage *icon = left.uiIcon;
        if (icon) {
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped)] autorelease];
        } else {
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonTapped)] autorelease];
        }
	} else {
        Content *left = [self getChildContentWithName:@"@back"];
        if (left) {
            title = left.displayName;
            UIImage *icon = left.uiIcon;
            if (icon) {
                self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonTapped)] autorelease];
            } else {
                self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(backBarButtonTapped)] autorelease];
            }
//            self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonTapped)] autorelease];
        }
    }
    
    NSArray *popovers = [self.content getChildrenByName:@"@popover"];
    if (popovers.count) {
        NSMutableArray *tbcontent = [NSMutableArray array];
        NSMutableArray *items = [NSMutableArray array];
        int i = 0;
        for (Content *c in popovers) {
            UIImage *icon = c.uiIcon;
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarItemTapped:)];
//            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"foo" style:UIBarButtonItemStylePlain target:self action:@selector(toolbarItemTapped:)];
            item.tag = i++;
            [items addObject:item];
            [tbcontent addObject:c];
            [item release];
        }
        self.toolbarItems = items;
        self.navigationController.toolbarHidden = FALSE;
    }

}

-(void) addNextButton {
	[self addButtonWithText:@"Next" callingBlock:^{
        [self navigateToNext];
    }];
}

-(NSString*)contentPathForName:(NSString*)fn {
    NSMutableString *dir = [NSMutableString stringWithUTF8String:"Content"];
    NSArray *pathComponents = [fn pathComponents];
    for (int i=0;i<pathComponents.count-1;i++) {
        NSString *subdir = (NSString *)[pathComponents objectAtIndex:i];
        [dir appendString:@"/"];
        [dir appendString:subdir];
    }
    NSString *file = [pathComponents objectAtIndex:pathComponents.count-1];
	NSArray *a = [file componentsSeparatedByString:@"."];
	NSString *basename = [a objectAtIndex:0];
	NSString *ext = [a objectAtIndex:1];
	NSString *storePath = [[NSBundle mainBundle] pathForResource:basename ofType:ext inDirectory:dir];
	return storePath;
}

-(NSData*)contentForName:(NSString*)fn {
	NSString *path = [self contentPathForName:fn];
	return [NSData dataWithContentsOfFile:path];
}

-(UIImage*)fetchAttachedImage {
	NSString *imageFN = [self.content valueForKey:@"image"];
	if (imageFN) {
		UIImage *image = [UIImage imageWithData:[self contentForName:imageFN]];
		return image;
	}
	return nil;
}

-(void)preloadAndThen:(void (^)())block {
	UIWindow *offscreenWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    offscreenWindow.rootViewController = self;
    self.contentLoadedBlock = ^{
        offscreenWindow.rootViewController = nil;
        [offscreenWindow release];
        block();
    };
    [self view];
}

-(UIImage*)attachedImage {
	if (!attachedImage) {
		attachedImage = [self fetchAttachedImage];
		[attachedImage retain];
	}
	return attachedImage;
}

-(NSString*)mainText {
    return [self.content valueForKey:@"mainText"];
}

-(BOOL)shouldAddListenButton {
    return [self.content valueForKey:@"audio"] != nil;
}

-(UIImage*) backgroundBlendedImageToUse {
    return self.attachedImage;
}

-(void) baselineConfigureFromContent {
    NSString *onload = [self.content getExtraString:@"onload"];
    if (onload) {
        [self runJS:onload];
    }

    self.scoping = self.scoping || [self.content getExtraBoolean:@"scoping"];
    self.inlineImage = self.inlineImage || [self.content getExtraBoolean:@"inlineImage"];

    if (self.inlineImage) {
        UIImage *image = self.attachedImage;
        if (image) {
            [self addHTMLText:@""];
            [self addImage:image];
        }
    }
    
	NSString *mainText = [self mainText];
    if (mainText) {
/*
        if ([self.content valueForKey:@"audio"]) {
            NSString *listenLink = @"<a href=\"/listen\" style=\"float:right;padding:20px;\"><img src=\"listen.png\" alt=\"Tap to listen\"/></a>";
            mainText = [listenLink stringByAppendingString:mainText];
        }
*/
        self.hardHTML = [self.content getExtraBoolean:@"html"];
        [self addHTMLText:mainText];
    }

    for (Content *c in self.content.children) {
        if ([c.name isEqualToString:@"@inline"] || (![c.name isEqualToString:@"@button"] && [c.disposition isEqualToString:@"inline"])) {
            NSString *predicate = [c getExtraString:@"predicate"];
            if (predicate) {
                if (![self evalJSPredicate:predicate]) continue;
            }
            
            viewsToLoad++;
            
            ContentViewController *subc = [c getViewController];
            subc.isInlineContent = TRUE;
            subc.masterController = self;
            [self addChildViewController:subc];
            [self addChildContentController:subc];
            [self.dynamicView addSubview:subc.view];
            if (!self.bestInlineTitle) {
                self.bestInlineTitle = subc.navigationItem.title;
            }
            subc.contentLoadedBlock = ^{
                if (--viewsToLoad == 0) {
                    [self contentLoaded];
                }
            };
        }
    }

    NSString *dynamicPredicate = [self.content getExtraString:@"dynamicPredicate"];
    for (Content *c in [self.content getChildrenByName:@"@button"]) {
        ButtonModel *bm = [self addButtonWithText:c.displayName callingBlock:^(UIButton *button) {
            [self managedObjectSelected:c];
        }];
        NSString *enablement = [c getExtraString:@"enablement"];
        if (enablement) bm.enablement = enablement;
        if ([c.disposition isEqualToString:@"inline"]) {
            bm.style = BUTTON_STYLE_INLINE;
        }
        if (dynamicPredicate) {
            bm.dynamicPredicate = dynamicPredicate;
            bm.controller = self;
        }
        if ([c getExtraBoolean:@"isDefault"]) {
            bm.isDefault = TRUE;
        }
    }
 
    if ([self shouldAddListenButton]) {
        ButtonModel *model = [self addButtonWithText:@"Listen"];
        model.onClickBlock = ^{
            if (self.player && self.player.playing) {
                [self.player stop];
                self.player = nil;
                model.label = @"Listen";
            } else {
                [self playAudio];
                model.label = @"Stop Listening";
            }
        };
    }

	[self configureMetaContent];
}

-(void) relayout {
//    [self saveAccessibilityFocus];
    [self.scrollView setNeedsLayout];
    [self.dynamicView setContentSizeChanged];
//    [self restoreAccessibilityFocus];
}

-(void)loadView {
    self.originalViewHeight = -1;
    [super loadView];
    NSString *dynamicPredicate = [self.content getExtraString:@"dynamicPredicate"];
    if (dynamicPredicate) {
        self.contentView.controller = self;
        self.contentView.dynamicPredicate = dynamicPredicate;
    }
}

-(void) configureFromContent {
	[self baselineConfigureFromContent];
}
/*
-(void)backTapped {
	if (self.masterController) {
		[self.masterController backTapped];
	} else {
		[self.navigationController popViewControllerAnimated:TRUE];
	}
}
*/
-(void)helpTapped {
    NSMutableDictionary *params = [self makeContentDescriptor];
    [params setObject:@"HELP" forKey:@"buttonName"];
    
    [ButtonPressedEvent logWithButtonPressedButtonId:@"HELP" withButtonPressedButtonTitle:nil];
    
    [heartbeat
     logEvent:@"BUTTON_PRESS" 
     withParameters:params];

	Content *helpContent = [self helpContent];
	if (helpContent) {
        [self navigateToNextContent:helpContent];
	}
}

-(UINavigationItem*) leafNavigationItem {
    return self.navigationItem;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) goBack {
    [[self retain] autorelease];
    [self goBackAnimated:TRUE];
}

- (void) goBackAnimated:(BOOL)animated {
    Content *content = (Content *)[self.content parent];
    NSString *title = [content backButton];
    while (!title && content) {
        content = (Content *)[content parent];
        title = [content backButton];
        if ([title isEqualToString:@"Back"]) {
            title = nil;
        }
    }
    if (!title) {
        title = @"Back";
    }
    if ([[content icon] isEqualToString:@"home_icon.png"]) {
        title = @"Home";
    }
    NSString *from = [self.content displayName];
    // some content doesn't have a display name
    if (!from) {
        from = [self.content title];
    }
    // or a title
    if (!from) {
        from = [self.content ui];
    }
    NSDictionary *params = @{@"buttonName":title, @"uniqueID":[self.content uniqueID], @"location":from};
    [heartbeat logEvent:@"BACK_BUTTON_PRESS" withParameters:params];
    if (self.masterController) {
        [self.masterController goBackFrom:self animated:animated];
    }
}

- (void) navigateToHere {
    [self navigateToContent:self.content];
}

- (void) navigateToNext {
    Content *next = self.nextContent;
    [self navigateToNextContent:next];
}

- (void) navigateToNextContent:(Content*)content {
    ContentViewController *cvc = content.getViewController;
    [self navigateToNext:cvc];
}

- (void) navigateToNext:(ContentViewController *)viewController {
    [self navigateToNext:viewController animated:TRUE andRemoveOld:FALSE];
}

- (void) navigateToNext:(ContentViewController *)viewController animated:(BOOL)animated andRemoveOld:(BOOL)removeOld {
    if (self.masterController) {
        [self.masterController navigateToNext:viewController from:self animated:animated andRemoveOld:removeOld];
    }
}

- (void) navigateToNext:(ContentViewController *)viewController from:(ContentViewController *)fromController animated:(BOOL)animated andRemoveOld:(BOOL)removeOld {
    if (self.masterController) {
        [self.masterController navigateToNext:viewController from:self animated:animated andRemoveOld:removeOld];
    }
}

- (void) goBackFrom:(UIViewController*)src animated:(BOOL)animated {
//    NSLog(@"go back from %@",self.content);
    if (self.masterController) {
        [self.masterController goBackFrom:self animated:animated];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:(BOOL)animated];

//    [self saveAccessibilityFocus];
    long long timeGone = [EventLog timestamp];
    NSManagedObject *c = self.content;
    [ContentScreenViewedEvent logWithContentScreenTimestampStart:timeAppeared 
                             withContentScreenTimestampDismissal:timeGone
                                           withContentScreenName:[c valueForKey:@"name"] 
                                    withContentScreenDisplayName:[c valueForKey:@"displayName"] 
                                           withContentScreenType:viewTypeID
                                             withContentScreenId:[c valueForKey:@"uniqueID"]];

    [TimePerScreenEvent logWithScreenId:[c valueForKey:@"uniqueID"]
                    withScreenStartTime:timeAppeared
                  withTimeSpentOnScreen:(timeGone-timeAppeared)];
    
    [heartbeat logEvent:@"CONTENT_TIMED" withParameters:nil];

	if (self.player) {
		[self.player stop];
		self.player = nil;
	}
    if (captionTimer) {
        [captionTimer invalidate];
        [captionTimer release];
        captionTimer = nil;
    }
    if (firstCaptionStart) {
        [firstCaptionStart release];
        firstCaptionStart = nil;
    }
    if (captionView) {
        [captionView removeFromSuperview];
        [captionView release];
        captionView = nil;
    }

    self.inTransition = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void) gatherNavigationItems:(NSMutableArray *)items {
    if (self.beingRemoved) return;
    UINavigationItem *item = self.navigationItem;
    [items addObject:item];
}

- (BOOL)hasAnyContent {
    return TRUE;
}

- (int)badgeValue {
    return 0;
}

- (void)dealloc {
	if (self.player) {
		[self.player stop];
        self.player = nil;
	}
	[attachedImage release];
    [captions release];
    if (captionTimer) {
        [captionTimer invalidate];
        [captionTimer release];
    }
    [firstCaptionStart release];
    [captionView release];
    [pendingURL release];
	
    [super dealloc];
}


@end
