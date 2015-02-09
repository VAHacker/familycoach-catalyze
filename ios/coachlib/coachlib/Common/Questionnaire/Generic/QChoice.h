/*
 *  QChoice.h
 *  iStressLess
 *


 *
 */

#ifndef QCHOICE_H
#define QCHOICE_H

#include "QTextContainer.h"

class QChoice : public QTextContainer {
	char *value;

public:
	
	QChoice();

	virtual int getType();
	virtual void setValue(const char *_value);
	virtual const char *getValue();
};

#endif
