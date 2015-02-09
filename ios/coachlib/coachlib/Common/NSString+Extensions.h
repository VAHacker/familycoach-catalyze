//
//  NSString+Extensions.h
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

+ (NSString*)stringWithUTF8String:(const char*)str length:(int)len;

@end
