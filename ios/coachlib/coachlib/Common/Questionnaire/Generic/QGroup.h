/*
 *  QGroup.h
 *  iStressLess
 *


 *
 */

#ifndef QGROUP_H
#define QGROUP_H

#include "QNode.h"

class QAttributes;

class QGroup : public QNode {
public:
	QGroup();
	virtual ~QGroup();
	
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
	
};

#endif
