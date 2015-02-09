/*
 *  QText.h
 *  iStressLess
 *


 *
 */

#ifndef QTEXT_H
#define QTEXT_H

#include "QNode.h"

class QText : public QNode {
	char *text;
	char *locale;
	
public:
	QText();
    virtual ~QText();
	
	virtual int getType();
	virtual void appendText(const char *newText, int length);
	virtual const char *getLocale();
	virtual const char *getText();
	virtual void setLocale(const char *_locale);
	virtual void setText(const char *_text, int len);
	virtual void characters(const char* ch, int length);
	
};

#endif
