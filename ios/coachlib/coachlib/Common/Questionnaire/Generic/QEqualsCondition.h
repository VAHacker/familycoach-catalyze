/*
 *  QEqualsCondition.h
 *  iStressLess
 *


 *
 */

#ifndef QEQUALSCONDITION_H
#define QEQUALSCONDITION_H

#include "QDefs.h"
#include "QNode.h"

class QEqualsCondition : public QNode {
	
	char *variableName;
	char **values;

public:

	QEqualsCondition(const char * variable, const char *values);

	virtual void* evaluate(QAbstractPlayer *q);
};

#endif
