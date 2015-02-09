//
//  QuestionInstance.m
//  iStressLess
//


//

#import "QuestionInstance.h"
#import "iStressLessAppDelegate.h"
#include "QUtil.h"
#include "QChoice.h"
#include "QPlayer.h"
#import "ThemeManager.h"

@implementation QuestionInstance

@synthesize minAnswers, maxAnswers, headerView, viewCon, freeformMaxLength, numChoices;

- (id) initWithPlayer:(QPlayer*)_player andID:(NSString *)_questionID {
	self = [super init];
	player = _player;
	choiceTexts = nil;
	choiceValues = nil;
	questionID = _questionID;
    [questionID retain];
    freeformAnswer = nil;
	minAnswers = maxAnswers = 1;
    freeformMaxLength = 2048;
	return self;
}

-(void)dealloc {
    [choiceTexts release];
    [choiceValues release];
    [questionID release];
    [freeformAnswer release];
    [super dealloc];
}

-(NSString*)composeSetting {
	NSMutableString *s = [NSMutableString string];
    boolean_t oneAlready = FALSE;
    for (int i=0;i<choiceValues.count;i++) {
        if (choiceSelections[i]) {
            NSString *val = [choiceValues objectAtIndex:i];
            if (oneAlready) {
                [s appendString:@"|"];
            }
            [s appendFormat:@"%@",val];
            oneAlready = TRUE;
        }
    }
    
    return s;
}

- (void) selectItem:(NSString*)value {
    for (int i=0;i<[choiceValues count];i++) {
        NSString *val = [choiceValues objectAtIndex:i];
        if ([val isEqualToString:value]) {
            choiceSelections[i] = TRUE;
        }
    }
}

- (void) setChoices:(QChoice**)_choices {
    [choiceTexts release];
    [choiceValues release];
	numChoices = QUtil::ntArrayLen((void**)_choices);
    choiceTexts = [[NSMutableArray alloc] initWithCapacity:numChoices];
    choiceValues = [[NSMutableArray alloc] initWithCapacity:numChoices];
	for (int i=0;i<numChoices;i++) {
        const char *text = _choices[i]->getText(player);
        const char *value = _choices[i]->getValue();
        [choiceTexts addObject:[NSString stringWithUTF8String:text]];
        [choiceValues addObject:[NSString stringWithUTF8String:value]];
		choiceSelections[i] = FALSE;
	}
}

- (void) setChoicesWithStrings:(NSArray*)_choices {
    [choiceTexts release];
    [choiceValues release];
    choiceTexts = [[NSMutableArray alloc] initWithArray:_choices];
    choiceValues = [[NSMutableArray alloc] initWithArray:_choices];
    numChoices = [choiceTexts count];
	for (int i=0;i<numChoices;i++) {
		choiceSelections[i] = FALSE;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	if (row > numChoices-1) return nil;

	UITableViewCell *cell = [[UITableViewCell alloc] init];

    ThemeManager *theme = [ThemeManager sharedManager];
//	NSString *fontName = [theme stringForName:@"listTextFont"];
	float fontSize = [theme floatForName:@"listTextSize"];
	UIColor *textColor = [theme colorForName:@"listTextColor"];
	UIColor *bgColor = [theme colorForName:@"listBackgroundColor"];
    
	cell.textLabel.textColor = textColor;
	cell.backgroundColor = bgColor;
    cell.textLabel.minimumFontSize = fontSize*2/3;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
//    cell.textLabel.font = [UIFont fontWithName:fontName size:fontSize];
    cell.textLabel.adjustsFontSizeToFitWidth = TRUE;
    cell.textLabel.numberOfLines = 2;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.accessibilityTraits = UIAccessibilityTraitButton;
/*
    cell.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	cell.textLabel.numberOfLines = 2;
  */
    cell.textLabel.text = [choiceTexts objectAtIndex:row];

    if (choiceSelections[row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
    [cell autorelease];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return numChoices;
}

- (int) countAnswers {
	int count = 0;
	for (int i=0;i<numChoices;i++) {
		if (choiceSelections[i]) count++;
	}
	return count;
}

- (char *)assembleAnswerString {
	const char *answers[32];
	int answerIndex = 0;
    
    if (freeformAnswer) return strdup([freeformAnswer UTF8String]);

	for (int i=0;i<numChoices;i++) {
		if (choiceSelections[i]) {
			answers[answerIndex++] = [[choiceValues objectAtIndex:i] cString];
		}
	}
	answers[answerIndex++] = NULL;
	return QUtil::sArrayToCommaDelimited((char**)answers);
}

extern void changeUISegmentFont(UIView* aView);

- (void) resetSegmentedControl:(UISegmentedControl*)segmentedControl {
	changeUISegmentFont(segmentedControl);
	int row = segmentedControl.selectedSegmentIndex;
	for (int i=0;i<numChoices;i++) {
		choiceSelections[i] = FALSE;
	}
	choiceSelections[row] = TRUE;
	[self submitAnswer];
}

- (void)updateSelections:(UITableView *)tableView {
	for (int i=0;i<numChoices;i++) {
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		if (cell) {
			if (choiceSelections[i]) {
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
		}
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (headerView) return headerView.frame.size.height+10;
	return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return headerView;
}

- (BOOL) isValid {
    if (freeformAnswer && ([freeformAnswer length] > 0)) return TRUE;
    
	int currentAnswerCount = [self countAnswers];
	return (currentAnswerCount >= minAnswers) && (currentAnswerCount <= maxAnswers);
}

- (void) submitAnswer {
    if (!questionID) return;
    if (player) {
        char *answerStr = [self assembleAnswerString];
        player->recordAnswer([questionID UTF8String], answerStr);
        free(answerStr);
    } else {
        NSString *setting = [self composeSetting];
        [[iStressLessAppDelegate instance] setSetting:questionID to:setting];
    }
	
	[viewCon updateValidity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int row = [indexPath row];
	int currentAnswerCount = [self countAnswers];
	
	if (choiceSelections[row]) {
		if (maxAnswers > 1) {
			choiceSelections[row] = FALSE;
		}
	} else {
		if (currentAnswerCount < maxAnswers) {
			choiceSelections[row] = TRUE;
		} else if (maxAnswers == 1) {
			for (int i=0;i<numChoices;i++) {
				choiceSelections[i] = FALSE;
			}
			choiceSelections[row] = TRUE;
		} else {
			UIAlertView *alert = 
				[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Cannot select more than %d answers",maxAnswers] 
										   message:[NSString stringWithFormat:@"Please select no more than %d answers.  If you wish to select this answer, unselect another one.",maxAnswers] 
										  delegate:nil 
								 cancelButtonTitle:@"Ok" 
								 otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}

	if (maxAnswers > 1) [tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:FALSE];
	
	[self updateSelections:tableView];
	[self submitAnswer];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [freeformAnswer release];
    freeformAnswer = textView.text;
    [freeformAnswer retain];
	[self submitAnswer];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    if(newLength <= freeformMaxLength)
    {
        return YES;
    } else {
        NSUInteger emptySpace = freeformMaxLength - (textView.text.length - range.length);
        textView.text = [[[textView.text substringToIndex:range.location] 
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

@end
