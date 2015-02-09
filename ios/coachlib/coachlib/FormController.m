//
//  FavoritesListViewController.m
//  iStressLess
//


//

#import "FormController.h"
#import "iStressLessAppDelegate.h"
#import "ExerciseRef.h"
#import "GTableView.h"

@implementation FormController

-(void)cancel {
    [self goBack];
}

-(id)init {
    id _self = [super init];
    if (_self) {
        self.scoping = TRUE;
    }
    return _self;
}

-(void)savePropertyValue:(NSObject*)value asName:(NSString*)key {
    if (!self.binding) return;
    if ([key isEqualToString:@"children"]) return;
    if ([key isEqualToString:@"parent"]) return;
    NSPropertyDescription *prop = [self.binding.entity.propertiesByName objectForKey:key];
    if (prop) {
        if ((value != nil) && (value != [NSNull null])) {
            [self.binding setValue:value forKey:prop.name];
        }
    }
}

-(void)save {
    NSString *onsave = [self.content getExtraString:@"onsave"];
    if (onsave) {
        BOOL stopSave = [self evalJSPredicate:onsave];
        if (stopSave) return;
    }
    
    NSManagedObject *obj = self.binding ? self.binding : [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:self.parentContext];

    NSLog(@"%@",self.localVariables);
    for (NSPropertyDescription *prop in obj.entity.properties) {
        if ([prop.name isEqualToString:@"children"]) continue;
        if ([prop.name isEqualToString:@"parent"]) continue;
        id value = [self.localVariables objectForKey:prop.name];
        NSLog(@"Testing %@ = %@",prop.name,value);
        if ((value != nil) && (value != [NSNull null])) {
            [obj setValue:value forKey:prop.name];
        }
    }
    [self.parentContext save:NULL];
    [self goBack];
}

-(void)load {
    NSManagedObject *obj = self.binding;
    if (!obj) return;
    
    for (NSPropertyDescription *prop in obj.entity.properties) {
        if ([prop.name isEqualToString:@"children"]) continue;
        id value = [obj valueForKey:prop.name];
        if ([value respondsToSelector:@selector(mutableCopyWithZone:)]) {
            value = [[value mutableCopy] autorelease];
        } else if ([value respondsToSelector:@selector(copyWithZone:)]) {
            value = [[value copy] autorelease];
        }
        NSLog(@"Testing %@ = %@",prop.name,value);
        if (value != nil) {
            [super setVariable:prop.name to:value];
        } else {
            [super setVariable:prop.name to:[NSNull null]];
        }
    }
    NSLog(@"%@",self.localVariables);
}

-(void)configureFromContent {
    self.entityName = [self.content getExtraString:@"entityName"];
    self.binding = (NSManagedObject*)[super getVariable:@"@binding"];
    if (self.binding) {
        self.parentContext = self.binding.managedObjectContext;
    } else {
        self.parentContext = [iStressLessAppDelegate instance].udManagedObjectContext;
    }
    
    [self load];

    [super configureFromContent];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)] autorelease];
//    self.itemContent = [self.content getChildByName:@"@item"];
//    self.selectionBinding = [self.content getExtraString:@"selectionBinding"];
}

-(void)navigateToNext:(ContentViewController *)next from:(ContentViewController *)src animated:(BOOL)animated andRemoveOld:(BOOL)removeOld {
    [super navigateToNext:next from:src animated:animated andRemoveOld:removeOld];
    next.masterController = self;
}

- (void) goBackFrom:(UIViewController*)src animated:(BOOL)animated {
    if (self.masterController) {
        [self.masterController goBackFrom:src animated:animated];
    }
}

-(void)setVariable:(NSString *)key to:(NSObject *)value {
    [super setVariable:key to:value];
    [self savePropertyValue:value asName:key];
}

@end
