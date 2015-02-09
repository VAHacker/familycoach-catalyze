//
//  NSManagedObject+MOExtensions.m
//  iStressLess
//


//

#import "NSManagedObject+MOExtensions.h"


@implementation NSManagedObject (MOExtensions)

-(NSMutableDictionary*) descriptor {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *val;
    
    if ([self.entity.attributesByName objectForKey:@"name"] != nil) {
        val = [self valueForKey:@"name"];
        if (val) [params setObject:val forKey:@"name"];
    }
    if ([self.entity.attributesByName objectForKey:@"displayName"] != nil) {
        val = [self valueForKey:@"displayName"];
        if (val) [params setObject:val forKey:@"displayName"];
    }
    if ([self.entity.attributesByName objectForKey:@"uniqueID"] != nil) {
        val = [self valueForKey:@"uniqueID"];
        if (val) [params setObject:val forKey:@"uniqueID"];
    }
    
    return params;
}

@end
