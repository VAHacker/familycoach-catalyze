/*
 *  QChoiceQuestion.h
 *  iStressLess
 *


 *
 */

#ifndef QFREEFORMQUESTION_H
#define QFREEFORMQUESTION_H

#include "QTextContainer.h"

class QFreeFormQuestion : public QTextContainer {
	
	int maxSize;
    int lines;
    char *placeholder;
	
public:
	
	QFreeFormQuestion();
	virtual ~QFreeFormQuestion();
	
	virtual void setInputLines(int _lines);
	virtual void setMaxSize(int _maxSelectable);
    virtual void setPlaceholder(const char *placeholder);
	virtual void *evaluate(QAbstractPlayer *ctx);
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
};

#endif
