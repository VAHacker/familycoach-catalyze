//
//  NSString+Extensions.m
//  coachlib
//
//  Copyright (c) 2012 Department of Veteran's Affairs. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSString*)stringWithUTF8String:(const char*)str length:(int)len {
    return [[[NSString alloc] initWithBytes:str length:len encoding:NSASCIIStringEncoding] autorelease];
}

@end
