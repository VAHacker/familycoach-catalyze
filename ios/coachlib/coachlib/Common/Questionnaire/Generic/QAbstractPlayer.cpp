/*
 *  QAbstractPlayer.cpp
 *  iStressLess
 *


 *
 */

#include "QAbstractPlayer.h"
#include "QQuestionnaire.h"
#include "QScreen.h"

QAbstractPlayer::QAbstractPlayer() {
	currentNode = NULL;
	triggerTime = -1;
}

QAbstractPlayer::~QAbstractPlayer() {
}

void QAbstractPlayer::setQuestionnaire(QQuestionnaire *q) {
	questionnaire = q;
}

void QAbstractPlayer::setTriggerTime(long long _triggerTime) {
	triggerTime = _triggerTime;
}

void QAbstractPlayer::recordAnswer(const char *id, const char *answer) {
	answersByID.put(id, answer);
}

const char *QAbstractPlayer::fetchAnswer(const char *id) {
	return answersByID.get(id);
}

void QAbstractPlayer::setUserData(const char *key, const char *data) {
	userData.put(key, data);
}

const char * QAbstractPlayer::getUserData(const char *key) {
	return userData.get(key);
}

QStringMap& QAbstractPlayer::getAnswers() {
	return answersByID;
}

const char * QAbstractPlayer::getGlobalVariable(const char *key) {
	if (!strcmp(key,"triggerTime")) {
		/*
		 Calendar now = Calendar.getInstance();
		 Calendar then = Calendar.getInstance();
		 then.setTimeInMillis(triggerTime);
		 DateFormat format = null;
		 if (now.get(Calendar.DAY_OF_YEAR) == then.get(Calendar.DAY_OF_YEAR)) {
		 format = DateFormat.getTimeInstance(DateFormat.LONG);
		 } else {
		 format = DateFormat.getDateTimeInstance(DateFormat.LONG,DateFormat.LONG);
		 }
		 return format.format(then.getTime());
		 */
		return "UNIMPLEMENTED";
	} else {
		return getQuestionnaire()->getSettings()->getGlobal(this, key);
	}
}

const char * QAbstractPlayer::getLocale() {
	return "en";
}

QQuestionnaire *QAbstractPlayer::getQuestionnaire() {
	return questionnaire;
}

void QAbstractPlayer::play() {
	playNode(questionnaire->getSubnodes()[0]);
}

void QAbstractPlayer::playIntro() {
	playNode(questionnaire->getIntro());
}

bool QAbstractPlayer::playNode(QNode *n) {
	while (n != NULL) {
		currentNode = n;
		n = (QNode*)n->evaluate(this);
	}
    
    return true;
}

void QAbstractPlayer::nextPressed() {
	QNode *n = currentNode->next(this);
	if (!n) finish();
	else playNode(n);
}
