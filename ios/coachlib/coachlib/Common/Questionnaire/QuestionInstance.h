//
//  QuestionInstance.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>

struct QPlayer;
struct QChoice;

@class QuestionnaireViewController;

@interface QuestionInstance : NSObject<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate> {
	struct QPlayer *player;
	QuestionnaireViewController *viewCon;
	UIView *headerView;
	NSString *questionID;
	NSString *freeformAnswer;
    int freeformMaxLength;
    NSMutableArray *choiceTexts;
    NSMutableArray *choiceValues;
	int numChoices;
	int minAnswers;
	int maxAnswers;
	BOOL choiceSelections[256];
}

@property (nonatomic, assign) QuestionnaireViewController *viewCon;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic) int numChoices;
@property (nonatomic) int minAnswers;
@property (nonatomic) int maxAnswers;
@property (nonatomic) int freeformMaxLength;

- (id) initWithPlayer:(struct QPlayer*)player andID:(NSString *)_questionID;

- (void) setChoices:(struct QChoice**)_choices;
- (void) selectItem:(NSString*)value;
- (void) setChoicesWithStrings:(NSArray*)_choices;
- (BOOL) isValid;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)textViewDidEndEditing:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
