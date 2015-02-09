//
//  SimpleExerciseController.m
//  iStressLess
//


//

#import "BaseExerciseController.h"
#import "ManageSymptomsNavController.h"
#import "ConstructedView.h"
#import "iStressLessAppDelegate.h"
#import "NSManagedObject+MOExtensions.h"

@implementation BaseExerciseController

-(NSString*)checkPrerequisite {
	return nil;
}

-(void)privateInit {
	[super privateInit];
	scoreChecked = NO;
	self.exerciseScore = nil;
    self.thumbsup = nil;
    self.thumbsdown = nil;
}

-(NSManagedObject*)exerciseScore {
	if (!scoreChecked) {
		if (_exerciseScore == nil) {
			NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
			NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@",self.exerciseContent.uniqueID]];
			NSArray *exerciseScores = [udContext executeFetchRequest:fetchRequest error:NULL];
			if (exerciseScores && exerciseScores.count) {
				_exerciseScore = [exerciseScores objectAtIndex:0];
				[_exerciseScore retain];
			}
		}
		
		scoreChecked = TRUE;
	}
	
	return _exerciseScore;
}

-(int)getExerciseScoreValue {
	NSManagedObject *scoreObj = self.exerciseScore;
	if (!scoreObj) return 0;
	int positiveScore = [[scoreObj valueForKey:@"positiveScore"] intValue];
	int negativeScore = [[scoreObj valueForKey:@"negativeScore"] intValue];
	return positiveScore + negativeScore;
}

-(void)setExerciseScoreValue:(int)score {
	Content *parent = (Content*)self.exerciseContent.parent;
	ExerciseRef *scoreObj = self.exerciseScore;
	ExerciseRef *scoreParentObj = nil;
	NSManagedObjectContext *udContext = [iStressLessAppDelegate instance].udManagedObjectContext;
//	BOOL categoryLevelFavorite = [parent getExtraBoolean:@"categoryLevelFavorite"];
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ExerciseRef"];
	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"refID == %@",parent.uniqueID]];
	NSArray *parents = [udContext executeFetchRequest:fetchRequest error:NULL];

	if (parents && parents.count) {
		scoreParentObj = [parents objectAtIndex:0];
	}

	int positiveScoreParent = [scoreParentObj.positiveScore intValue];
	int negativeScoreParent = [scoreParentObj.negativeScore intValue];
	int positiveScore = [scoreObj.positiveScore intValue];
	int negativeScore = [scoreObj.negativeScore intValue];
	
	if (score > 0) {
		negativeScoreParent -= negativeScore;
		negativeScore = 0;
		positiveScore = score;
		positiveScoreParent += positiveScore;
	} else if (score < 0) {
		positiveScoreParent -= positiveScore;
		positiveScore = 0;
		negativeScore = score;
		negativeScoreParent += negativeScore;
	} else {
		positiveScoreParent -= positiveScore;
		negativeScoreParent -= negativeScore;
		positiveScore = 0;
		negativeScore = 0;
	}

    scoreObj.positiveScore = [NSNumber numberWithInt:positiveScore];
    scoreObj.negativeScore = [NSNumber numberWithInt:negativeScore];
    if (positiveScore) {
        scoreObj.sectionName = @"Favorite Tools";
        scoreObj.sectionOrder = @0;
    } else if (negativeScore) {
        scoreObj.sectionName = @"Rejected Tools";
        scoreObj.sectionOrder = @2;
    } else {
        scoreObj.sectionName = @"Available Tools";
        scoreObj.sectionOrder = @1;
    }
	scoreParentObj.positiveScore = [NSNumber numberWithInt:positiveScoreParent];
	scoreParentObj.negativeScore = [NSNumber numberWithInt:negativeScoreParent];
    if (positiveScoreParent) {
        scoreParentObj.sectionName = @"Favorite Tools";
        scoreParentObj.sectionOrder = @0;
    } else if (negativeScoreParent <= -[scoreParentObj.childCount intValue]) {
        scoreParentObj.sectionName = @"Rejected Tools";
        scoreParentObj.sectionOrder = @2;
    } else {
        scoreParentObj.sectionName = @"Available Tools";
        scoreParentObj.sectionOrder = @1;
    }

	[udContext save:nil];
}

-(NSManagedObject*)exerciseContent {
	if (_exerciseContent == nil) return self.content;
	return _exerciseContent;
}

- (void) setVariable:(NSString*)key to:(NSObject*)value {
	if ([key isEqual:@"tooltype"]) {
		NSString *oldVal = (NSString*)[self.masterController getVariable:key];
		if (oldVal) value = @"several exercises";
	}
	
	[self.masterController setVariable:key to:value];
}

-(void)setThumbStates {
	int score = [self getExerciseScoreValue];
    ButtonModel *thumbsupModel = self.thumbsup;
    ButtonModel *thumbsdownModel = self.thumbsdown;
	if (score == 1) {
        thumbsupModel.toggleState = TRUE;
        thumbsdownModel.toggleState = FALSE;
	} else if (score == -1) {
        thumbsupModel.toggleState = FALSE;
        thumbsdownModel.toggleState = TRUE;
	} else {
        thumbsupModel.toggleState = FALSE;
        thumbsdownModel.toggleState = FALSE;
	}
}

/*
- (void) advanceToNext {
	BaseExerciseController *cvc = (BaseExerciseController*)[self getNextController];
	cvc.masterController = self.masterController;
	cvc.exerciseContent = self.exerciseContent;
	if ([self.content valueForKey:@"backButton"]) {
		[self.navigationController pushViewController:cvc animated:TRUE];
	} else {
		[self.navigationController pushViewControllerAndRemoveOldOne:cvc];
	}
}
*/

/*
- (void)buttonPressed:(UIButton*)button {
	if (button.tag == BUTTON_ADVANCE_EXERCISE) {
		[self advanceToNext];
    } else {
        [super buttonPressed:(UIButton *)button];
    }
 */
/*
	} else {
		int score = [self getExerciseScoreValue];
		if (button == thumbsup) {
			if (score == 1) score = 0;
			else score = 1;
			[self setExerciseScoreValue:score];
			[self setThumbStates];
		} else if (button == thumbsdown) {
			if (score == -1) score = 0;
			else score = -1;
			[self setExerciseScoreValue:score];
			[self setThumbStates];
		} else if (button == ccButton) {
            [self toggleCaptions];
			[self setThumbStates];
		} else {
			[super buttonPressed:(UIButton *)button];
		}
	}
}
 */

-(void) addNewToolButton {
    NSString *newToolPrompt = [self.content getExtraString:@"newToolPrompt"];

    if (!newToolPrompt) 
        newToolPrompt = @"New Tool";
    else if ([newToolPrompt isEqualToString:@"@none"])
        return;
    
    [self addButton:BUTTON_CHOOSE_ANOTHER withText:newToolPrompt];
}

+(UIImage*)highlightedImage:(UIImage*)image withColor:(UIColor*)color {
    CIImage *beginImage = [CIImage imageWithCGImage:[image CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorMatrix"];
    [filter setDefaults]; // 3
    [filter setValue:beginImage forKey:kCIInputImageKey];
    
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    [filter setValue:[CIVector vectorWithX:red Y:green Z:blue W:0] forKey:@"inputBiasVector"];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    CFRelease(cgimg);
    return newImg;
}

-(void) addThumbs {
    if (self.exerciseScore) {
        int score = [self getExerciseScoreValue];
        
        self.thumbsup = [ButtonModel button];
        self.thumbsup.onToggleBlock = ^(BOOL ccOn){
            int score = [self getExerciseScoreValue];
            if (score == 1) score = 0;
            else score = 1;
            [self setExerciseScoreValue:score];
            [self setThumbStates];
        };
        UIImage *thumbsupIcon = [UIImage imageNamed:@"thumbsup.png"];
        self.thumbsup.icon = thumbsupIcon;
        self.thumbsup.toggledIcon = [BaseExerciseController highlightedImage:thumbsupIcon withColor:[UIColor colorWithRed:0 green:0.7 blue:0 alpha:1]];
        self.thumbsup.toggleState = score > 0;
        self.thumbsup.style = BUTTON_STYLE_TOGGLE|BUTTON_STYLE_LEFT;
        self.thumbsup.accessibilityLabel = @"Thumbs Up";
        self.thumbsup.accessibilityTraits = UIAccessibilityTraitButton | (self.thumbsup.toggleState ? UIAccessibilityTraitSelected : 0);
        [self addButton:self.thumbsup];
     
        self.thumbsdown = [ButtonModel button];
        self.thumbsdown.onToggleBlock = ^(BOOL ccOn){
            int score = [self getExerciseScoreValue];
            if (score == -1) score = 0;
            else score = -1;
            [self setExerciseScoreValue:score];
            [self setThumbStates];
        };
        UIImage *thumbsdownIcon = [UIImage imageNamed:@"thumbsdown.png"];
        self.thumbsdown.icon = thumbsdownIcon;
        self.thumbsdown.toggledIcon = [BaseExerciseController highlightedImage:thumbsdownIcon withColor:[UIColor colorWithRed:1 green:0.1 blue:0.1 alpha:1]];
        self.thumbsdown.toggleState = score < 0;
        self.thumbsdown.style = BUTTON_STYLE_TOGGLE|BUTTON_STYLE_LEFT;
        self.thumbsdown.accessibilityLabel = @"Thumbs Down";
        self.thumbsdown.accessibilityTraits = UIAccessibilityTraitButton | (self.thumbsdown.toggleState ? UIAccessibilityTraitSelected : 0);
        [self addButton:self.thumbsdown];
    }

    if ([self getCaptions]) {
        self.ccButton = [ButtonModel button];
        UIImage *ccimage = [UIImage imageNamed:@"cc_icon.png"];
        
        self.ccButton.icon = ccimage;
        self.ccButton.toggledIcon = [BaseExerciseController highlightedImage:ccimage withColor:[UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1]];
        self.ccButton.toggleState = self.captionsEnabled;
        self.ccButton.accessibilityLabel = @"Closed Captioning";
        self.ccButton.style = BUTTON_STYLE_TOGGLE | BUTTON_STYLE_LEFT;
        self.ccButton.onToggleBlock = ^(BOOL ccOn){
            self.captionsEnabled = ccOn;
        };
        [self addButton:self.ccButton];
    }

	[self setThumbStates];
}

-(void) addCC {
}

-(NSString*) nextButtonTitle {
    return @"Done";
}

-(void) configureFromContent {
    [super configureFromContent];
	[self addThumbs];
    NSString *nextButtonTitle = [self nextButtonTitle];
    if (nextButtonTitle) {
        [self addButtonWithText:nextButtonTitle callingBlock:^{
            [self navigateToNext];
        }].isDefault = TRUE;
    }
}

- (void) navigateToNext {
    Content *next = self.nextContent;
    ContentViewController *cvc = [next getViewController];
    if (cvc && [cvc isKindOfClass:[BaseExerciseController class]]) {
        BaseExerciseController *bec = (BaseExerciseController*)cvc;
        bec.exerciseContent = self.exerciseContent;
        [self navigateToNext:bec];
    } else {
        [super navigateToNext];
    }
}

-(void) dealloc {
	[super dealloc];
}

@end
