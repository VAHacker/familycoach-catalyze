/*
 *  QNodeMap.h
 *  iStressLess
 *


 *
 */

#ifndef QNODEMAP_H
#define QNODEMAP_H

#include "QDefs.h"
#include "QBaseMap.h"

class QNode;

class QNodeMap : public QBaseMap {
public:
	QNode *get(const char *name);
	void put(const char *name, QNode *n);
	virtual void deleteValue(void *value);
};

#endif
