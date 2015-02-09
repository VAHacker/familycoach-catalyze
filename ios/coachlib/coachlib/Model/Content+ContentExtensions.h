
#import "Content.h"

@class ContentViewController;
@class SymptomRef;
@class ExerciseRef;

@interface Content (ContentExtensions)

- (NSDictionary*) getExtrasDict;
- (NSString*) getExtraString:(NSString*)key;
- (BOOL) getExtraBoolean:(NSString*)key;
- (int) getExtraInt:(NSString*)key;
- (CGPoint) getExtraPoint:(NSString*)key;

- (float) getExtraFloat:(NSString*)key;
- (float) getExtraFloat:(NSString*)key withDefault:(float)defaultValue;

- (NSArray*) getChildrenByName:(NSString*)name;
- (Content*) getChildByName:(NSString*)name;
- (ContentViewController*) getViewController;
- (UIImage*)uiImage;
- (UIImage*)uiIcon;

- (SymptomRef*)refForSymptom;
- (ExerciseRef*)refForExercise;

- (NSArray*) properChildren;

-(NSMutableDictionary*) contentDescriptor;

+(NSString*)contentPathForName:(NSString*)fn;
-(NSString*)contentPathForFile;

+(UIImage*)imageNamed:(NSString*)fn;

@end
