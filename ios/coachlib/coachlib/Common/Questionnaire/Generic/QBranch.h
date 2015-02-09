/*
 *  QBranch.h
 *  iStressLess
 *


 *
 */

#ifndef QBRANCH_H
#define QBRANCH_H

#include "QAnd.h"

class QBranch : public QAnd {
	
	char *destination;

public:

	QBranch();

	virtual const char *getDestination();
	virtual void setDestination(const char *_destination);
	virtual void *evaluate(QAbstractPlayer *ctx);
};

#endif
