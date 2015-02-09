/*
 *  QContainsCondition.h
 *  iStressLess
 *


 *
 */

#ifndef QCONTAINSCONDITION_H
#define QCONTAINSCONDITION_H

#include "QDefs.h"
#include "QNode.h"

class QContainsCondition : public QNode {
	
	char *variableName;
	char **values;

public:
	
	QContainsCondition(const char * variable, const char *values);
	
	virtual void* evaluate(QAbstractPlayer *q);
};

#endif
