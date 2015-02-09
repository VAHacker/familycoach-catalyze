//
//  SoothingPictureController.m
//  iStressLess
//


//

#import "SoothingAudioController.h"
#import "iStressLessAppDelegate.h"
//#import "AssetsLibrary/AssetsLibrary.h"
#import "PhotoViewController.h"
#import "MediaPlayer/MediaPlayer.h"

@implementation SoothingAudioController

-(NSString*)checkPrerequisite {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AudioReference"];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	if ([context countForFetchRequest:fetchRequest error:NULL] == 0) {
        NSString *msg = [self.content getExtraString:@"prereq"];
        if (!msg) msg = @"You haven't chosen any soothing songs or audio clips from your audio library.  Go to Settings and choose some audio before you can use this tool.";
		return msg;
	}
	
	return nil;
}

-(void)playSoothingAudio {
	NSManagedObjectContext *context = [iStressLessAppDelegate instance].udManagedObjectContext;
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"AudioReference"];
	fetchRequest.returnsObjectsAsFaults = TRUE;
	NSArray *a = [context executeFetchRequest:fetchRequest error:NULL];
	
	int index = rand() % a.count;  
	NSManagedObject *managedObject = [a objectAtIndex:index];
	
	MPMusicPlayerController *appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[appMusicPlayer stop];
	[appMusicPlayer setShuffleMode: MPMusicShuffleModeOff];
	[appMusicPlayer setRepeatMode: MPMusicRepeatModeNone];

	NSNumber *refID = [managedObject valueForKey:@"refID"];
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	[query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:refID forProperty:MPMediaItemPropertyPersistentID]];
	[appMusicPlayer setQueueWithQuery: query];
	[appMusicPlayer play]; 
	[query release];
}

-(void) configureFromContent {
	[super configureFromContent];
    [self addButtonWithText:@"Play Audio" andStyle:BUTTON_STYLE_INLINE callingBlock:^(UIButton *button){
		[self playSoothingAudio];
	}].isDefault = TRUE;
}

-(void) viewWillDisappear:(BOOL)animated {
	MPMusicPlayerController *appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
	[appMusicPlayer stop];
	[super viewWillDisappear:animated];
}

@end
