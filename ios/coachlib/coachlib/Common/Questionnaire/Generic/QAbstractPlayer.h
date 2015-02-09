/*
 *  QAbstractPlayer.h
 *  iStressLess
 *


 *
 */

#ifndef QABSTRACTPLAYER_H
#define QABSTRACTPLAYER_H

#define BUTTON_NEXT 1
#define BUTTON_DEFER 2
#define BUTTON_DONE 3

#include "QStringMap.h"

class QNode;
class QChoice;
class QQuestionnaire;

class QAbstractPlayer {
	
	QQuestionnaire *questionnaire;
	QStringMap answersByID;
	QStringMap userData;
	QNode *currentNode;
	long long triggerTime;
	
public:
	
	QAbstractPlayer();
	virtual ~QAbstractPlayer();
	
	virtual void setQuestionnaire(QQuestionnaire *q);
	virtual void setTriggerTime(long long _triggerTime);
	virtual void recordAnswer(const char *id, const char *answer);
	virtual const char *fetchAnswer(const char *id);
	virtual void setUserData(const char *key, const char *data);
	virtual const char * getUserData(const char *key);
	virtual QStringMap& getAnswers();
	virtual const char * getGlobalVariable(const char *key);
	virtual const char * replaceVariables(const char *str) = 0;
	virtual const char * getLocale();
	virtual QQuestionnaire *getQuestionnaire();
	virtual void play();
	virtual void playIntro();
	virtual bool playNode(QNode *n);
	virtual void nextPressed();
	
	virtual void beginScreen(const char *title, int screenType) = 0;
	virtual void addImage(const char *url) = 0;
	virtual void addText(const char *text) = 0;
	virtual void addFreeformQuestion(const char *id, const char *question, const char *placeholder, int lines, int maxLength, bool mandatory) = 0;
	virtual void addChoiceQuestion(const char *id, const char *question, int minChoices, int maxChoices, QChoice **choices) = 0;
	virtual void addButton(int buttonType, const char *label) = 0;
	virtual void showScreen() = 0;
	virtual void finish() = 0;
	
	virtual void donePressed() = 0;
	virtual void deferPressed() = 0;
	
};


#endif
