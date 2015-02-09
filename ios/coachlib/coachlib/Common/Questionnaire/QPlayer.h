/*
 *  QPlayer.h
 *  iStressLess
 *


 *
 */

#import <UIKit/UIKit.h>
#include "QAbstractPlayer.h"
#include "QuestionnaireViewController.h"
#import "GNavigationController.h"
#import "ContentViewController.h"
#import "NavController.h"

class QPlayer;

@protocol QuestionnaireDelegate
- (void)questionnairePlayerWasCancelled:(QPlayer*)player;
- (void)questionnairePlayerHasFinished:(QPlayer*)player;
@end

class QPlayer : public QAbstractPlayer {

	NavController *masterController;
	QuestionnaireViewController *viewCon;
	id<QuestionnaireDelegate> delegate;
	int screensDisplayed;
    
    QQuestionnaire *questionnaireList[10];
    int questionnaireCount;
    int questionnaireIndex;
	
public:
	QPlayer(NavController *_masterController);
	QPlayer(NavController *_masterController, NSString *filename);
    virtual ~QPlayer();

    void addQuestionnaire(QQuestionnaire *q);
    void addQuestionnaire(NSString *filePath);

	void setDelegate(id _delegate);
	
	virtual const char * replaceVariables(const char *str);
    virtual void recordAnswer(const char *id, const char *answer);

	virtual void beginScreen(const char *title, int screenType);
	virtual void addImage(const char *url);
	virtual void addText(const char *text);
	virtual void addFreeformQuestion(const char *id, const char *question, const char *placeholder, int lines, int maxLength, bool mandatory);
	virtual void addChoiceQuestion(const char *id, const char *question, int minChoices, int maxChoices, QChoice **choices);
	virtual void addButton(int buttonType, const char *label);
	virtual void showScreen();
	virtual void finish();
	
	virtual void donePressed();
	virtual void deferPressed();
	
};
