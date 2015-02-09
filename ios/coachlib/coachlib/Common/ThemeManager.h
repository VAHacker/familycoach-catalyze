//
//  ThemeManager.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUNinePatch.h"

@interface ThemeManager : NSObject

@property (nonatomic,retain) NSDictionary *styles;
@property (nonatomic,retain) NSMutableDictionary *ninePatchCache;

+ (ThemeManager *)sharedManager;

-(NSString*) stringForName:(NSString*)name;
-(float) floatForName:(NSString*)name;
-(int) intForName:(NSString*)name;
-(UIColor*)colorForName:(NSString*)name;
-(TUNinePatch*)ninePatchForName:(NSString*)name;

@end
