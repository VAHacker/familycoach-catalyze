/*
 *  QOr.h
 *  iStressLess
 *


 *
 */

#ifndef QOR_H
#define QOR_H

#include "QCompositeCondition.h"

class QOr : public QCompositeCondition {
public:
	virtual void *evaluate(QAbstractPlayer *q);
};

#endif
