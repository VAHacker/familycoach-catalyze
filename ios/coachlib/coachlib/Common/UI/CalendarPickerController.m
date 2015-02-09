//
//  RelaxationIntroController.m
//  iStressLess
//


//

#import <EventKit/EventKit.h>
#import "CalendarPickerController.h"
#import "iStressLessAppDelegate.h"
#import "Content+ContentExtensions.h"

@implementation CalendarPickerController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = (NSMutableArray*)[self.calendars objectAtIndex:[indexPath section]];
    if ([indexPath row] == section.count) {
        cell.textLabel.text = @"Add PTSD Coach calendar";
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        return;
    }
    EKCalendar *cal = ((EKCalendar*)[section objectAtIndex:[indexPath row]]);
    cell.textLabel.text = cal.title;
    NSString *value = nil;
    if (self.settingKey) {
        value = [[iStressLessAppDelegate instance] getSetting:self.settingKey];
    }
    NSString *key = cal.calendarIdentifier;
	cell.editingAccessoryType = (value && key && [value isEqual:key]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}
/*
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = (NSMutableArray*)[self.calendars objectAtIndex:[indexPath section]];
    if ((([indexPath row] == section.count) && !self.hasPrivateCalendar) ||
        (([indexPath row] == section.count-1) && self.hasPrivateCalendar)) {
        return TRUE;
    }
    
    return FALSE;
}
*/
-(void) reloadCalendars {
    EKEventStore *eventStore = [iStressLessAppDelegate instance].eventStore;
    NSArray *cals;
    if ([eventStore respondsToSelector:@selector(calendarsForEntityType:)]) {
        cals = [eventStore calendarsForEntityType:EKEntityTypeEvent];
    } else {
        cals = [eventStore calendars];
    }
    
    BOOL foundLocal = FALSE;
    BOOL foundiCloud = FALSE;
    self.hasPrivateCalendar = FALSE;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (EKCalendar *cal in cals) {
        if (cal.source.sourceType == EKSourceTypeLocal) foundLocal = TRUE;
        if ((cal.source.sourceType == EKSourceTypeCalDAV) && [cal.source.title isEqualToString:@"iCloud"]) foundiCloud = TRUE;

        if ([cal.title isEqualToString:@"PTSD Coach"]) {
            self.hasPrivateCalendar = TRUE;
        };

        NSString *sourceName = cal.source.sourceIdentifier;
        NSMutableArray *a = [dict objectForKey:sourceName];
        if (!a) {
            a = [NSMutableArray array];
            [dict setObject:a forKey:sourceName];
        }
        [a addObject:cal];
    }
    
    if (foundiCloud == foundLocal) {
        NSLog(@"Found both local and iCloud calendars... not sure which to use");
    }
    if (foundiCloud) self.iCloudOn = TRUE;
    
    self.calendars = [NSMutableArray array];
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSMutableArray *obj, BOOL *stop) {
        [obj sortUsingComparator:^NSComparisonResult(EKCalendar *cal1, EKCalendar *cal2) {
            if ([cal1.title isEqualToString:@"PTSD Coach"]) return NSOrderedDescending;
            if ([cal2.title isEqualToString:@"PTSD Coach"]) return NSOrderedAscending;
            return [cal1.title compare:cal2.title];
        }];
        [self.calendars addObject:obj];
    }];

    [self.calendars sortUsingComparator:^NSComparisonResult(NSArray *a1, NSArray *a2) {
        EKCalendar *cal1 = [a1 objectAtIndex:0];
        EKCalendar *cal2 = [a2 objectAtIndex:0];
        if (cal1.source.sourceType == EKSourceTypeLocal) return NSOrderedAscending;
        if (cal2.source.sourceType == EKSourceTypeLocal) return NSOrderedDescending;
        if ((cal1.source.sourceType == EKSourceTypeCalDAV) && ([cal1.source.title isEqualToString:@"iCloud"])) return NSOrderedAscending;
        if ((cal2.source.sourceType == EKSourceTypeCalDAV) && ([cal2.source.title isEqualToString:@"iCloud"])) return NSOrderedDescending;
        return [cal1.source.title compare:cal2.source.title];
    }];
    
}

-(void) addCalendar {
    EKEventStore *eventStore = [iStressLessAppDelegate instance].eventStore;
    EKCalendar *cal = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
    cal.title = @"PTSD Coach";
    EKSource *theSource = nil;
    for (EKSource *source in eventStore.sources) {
        NSLog(@"%@ %@ %d",source.title,source.sourceIdentifier,source.sourceType);
        if (((source.sourceType == EKSourceTypeLocal) && !self.iCloudOn) ||
            ((source.sourceType == EKSourceTypeCalDAV) && ([source.title isEqualToString:@"iCloud"]) && self.iCloudOn)) {
            theSource = source;
            break;
        }
    }
    
    NSError *err = nil;
    cal.source = theSource;
    [eventStore saveCalendar:cal commit:TRUE error:&err];
    NSLog(@"%@",err);
    NSString *calID = cal.calendarIdentifier;
    [[iStressLessAppDelegate instance] setSetting:self.settingKey to:calID];
    [self reloadCalendars];
    [self.tableView reloadData];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = (NSMutableArray*)[self.calendars objectAtIndex:[indexPath section]];
    if ([indexPath row] == section.count) {
        [self addCalendar];
        return;
    }
    EKCalendar *cal = ((EKCalendar*)[section objectAtIndex:[indexPath row]]);
    NSString *value = cal.calendarIdentifier;
    if (self.settingKey) {
        [[iStressLessAppDelegate instance] setSetting:self.settingKey to:value];
    }
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:FALSE];
	[tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *section = (NSMutableArray*)[self.calendars objectAtIndex:[indexPath section]];
        EKCalendar *cal = ((EKCalendar*)[section objectAtIndex:[indexPath row]]);
        if (self.settingKey) {
            NSString *calID = [[iStressLessAppDelegate instance] getSetting:self.settingKey];
            if ([calID isEqualToString:cal.calendarIdentifier]) {
                [[iStressLessAppDelegate instance] setSetting:self.settingKey to:nil];
            }
        }
        if ([cal.title isEqualToString:@"PTSD Coach"]) {
            NSError *err = nil;
            [[iStressLessAppDelegate instance].eventStore removeCalendar:cal commit:TRUE error:&err];
        }
        [self reloadCalendars];
        [tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addCalendar];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *section = (NSMutableArray*)[self.calendars objectAtIndex:[indexPath section]];
    if ([indexPath row] == section.count) {
        return UITableViewCellEditingStyleInsert;
    }
    EKCalendar *cal = ((EKCalendar*)[section objectAtIndex:[indexPath row]]);
    if ([cal.title isEqualToString:@"PTSD Coach"]) return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

-(void) configureFromContent {
	[super configureFromContent];
    self.tableView.editing = TRUE;
    self.editing = TRUE;
    self.tableView.allowsSelectionDuringEditing = TRUE;
    [self reloadCalendars];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.calendars.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = ((NSArray*)[self.calendars objectAtIndex:section]).count;
    if ((section == 0) && !self.hasPrivateCalendar) count++;
    return count;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    EKCalendar *cal = ((EKCalendar*)[((NSArray*)[self.calendars objectAtIndex:section]) objectAtIndex:0]);
    NSString *title = cal.source.title;
    if (cal.source.sourceType == EKSourceTypeLocal) {
        title = @"On this device";
    }
    return title;
}

-(void) dealloc {
	[super dealloc];
}

@end
