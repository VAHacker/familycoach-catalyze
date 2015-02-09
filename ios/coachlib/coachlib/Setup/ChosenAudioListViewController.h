//
//  ChoosenAudioListViewController.h
//  iStressLess
//


//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ContentListViewController.h"

@interface ChosenAudioListViewController : ContentListViewController<MPMediaPickerControllerDelegate> {
	MPMusicPlayerController* appMusicPlayer;
	BOOL firstTimeDisplayed;
}

@end
