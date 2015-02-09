/*
 *  QAnd.h
 *  iStressLess
 *


 *
 */

#ifndef QAND_H
#define QAND_H

#include "QCompositeCondition.h"

class QAnd : public QCompositeCondition {
public:
	virtual void *evaluate(QAbstractPlayer *q);
	
};

#endif
