/*
 *  QChoiceQuestion.h
 *  iStressLess
 *


 *
 */

#ifndef QCHOICEQUESTION_H
#define QCHOICEQUESTION_H

#include "QTextContainer.h"

class QChoice;

class QChoiceQuestion : public QTextContainer {
	
	int minSelectable;
	int maxSelectable;
	
public:
	
	QChoiceQuestion();
	
	virtual void setMinSelectable(int _minSelectable);
	virtual void setMaxSelectable(int _maxSelectable);
	virtual QChoice **getChoices();
	virtual void *evaluate(QAbstractPlayer *ctx);
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
};

#endif
