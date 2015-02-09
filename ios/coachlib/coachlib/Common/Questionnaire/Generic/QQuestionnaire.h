/*
 *  QQuestionnaire.h
 *  iStressLess
 *


 *
 */

#ifndef QQUESTIONNAIRE_H
#define QQUESTIONNAIRE_H

#include "QGroup.h"
#include "QSettings.h"
#include "QAttributes.h"
#include "QNodeMap.h"

class QScreen;
class QSettings;

class QQuestionnaire : public QGroup {

protected:
	QScreen *intro;
	QSettings settings;
	QNodeMap nodesByID;

public:
	QQuestionnaire();
	virtual ~QQuestionnaire();
		
	virtual void indexNode(QNode *node);
	virtual QNode *getNodeByID(const char *id);
	virtual void addSubnode(QNode *node);
	virtual QSettings *getSettings();
	virtual QScreen *getIntro();
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
	
};

#endif
