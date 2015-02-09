/*
 *  QCompositeCondition.h
 *  iStressLess
 *


 *
 */

#ifndef QCOMPOSITECONDITION_H
#define QCOMPOSITECONDITION_H

#include "QNode.h"

class QCompositeCondition : public QNode {
public:
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
};

#endif
