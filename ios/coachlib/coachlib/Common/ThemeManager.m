//
//  ThemeManager.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "ThemeManager.h"
#import "TUNinePatch.h"

@implementation ThemeManager

+ (ThemeManager *)sharedManager
{
    static ThemeManager *sharedManager = nil;
    if (sharedManager == nil)
    {
        sharedManager = [[ThemeManager alloc] init];
    }
    return sharedManager;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *themeName = [defaults objectForKey:@"theme"] ?: @"defaultTheme";
        
        NSString *path = [[NSBundle mainBundle] pathForResource:themeName ofType:@"plist"];
        self.styles = [NSDictionary dictionaryWithContentsOfFile:path];
        self.ninePatchCache = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSString*) stringForName:(NSString*)name {
    return [self.styles objectForKey:name];
}

-(float) floatForName:(NSString*)name {
    return [((NSNumber*)[self.styles objectForKey:name]) floatValue];
}

-(int) intForName:(NSString*)name {
    return [((NSNumber*)[self.styles objectForKey:name]) intValue];
}

#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0];

-(UIColor*)colorForName:(NSString*)name {
    NSString *s = [self stringForName:name];
    int len = [s length];
    unsigned int c;
    [[NSScanner scannerWithString:s] scanHexInt:&c];
    if (len == 6) {
        c = (c << 8) | 0xFF;
    }
    return HEXCOLOR(c);
}

-(TUNinePatch*)ninePatchForName:(NSString*)name {
    TUNinePatch *np = [self.ninePatchCache objectForKey:name];
    if (!np) {
        UIImage *image = [UIImage imageNamed:[self stringForName:name]];
        if (!image) return nil;
        np = [TUNinePatch ninePatchWithNinePatchImage:image];
        [self.ninePatchCache setObject:np forKey:name];
    }
    
    return [TUNinePatch ninePatchWithNinePatch:np];
}

@end
