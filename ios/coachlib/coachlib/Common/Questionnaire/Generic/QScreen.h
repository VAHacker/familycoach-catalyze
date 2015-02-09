/*
 *  QScreen.h
 *  iStressLess
 *


 *
 */

#ifndef QSCREEN_H
#define QSCREEN_H

#include "QNode.h"
#include "QAbstractPlayer.h"

class QAnd;

class QScreen : public QNode {
	
	QAnd *showOnCondition;
	char *title;

public:
	
	QScreen();
	virtual ~QScreen();
	
	virtual int  screenType(QAbstractPlayer *ctx);
	virtual void setTitle(const char *title);
	virtual void *evaluate(QAbstractPlayer *ctx);
	virtual void addButtons(QAbstractPlayer *ctx);
	virtual bool shouldEvaluate(QAbstractPlayer *ctx);
	virtual void addSubnode(QNode *node);
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
};


#endif
