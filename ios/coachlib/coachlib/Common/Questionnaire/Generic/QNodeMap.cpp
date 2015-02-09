/*
 *  QNodeMap.cpp
 *  iStressLess
 *


 *
 */

#include "QNodeMap.h"
#include "QNode.h"

QNode *QNodeMap::get(const char *name) {
	return (QNode *)_get(name);
}

void QNodeMap::put(const char *name, QNode *n) {
#ifndef __clang_analyzer__ // avoid false memory leak triggering
	_put(strdup(name),(void*)n, MAP_FLAG_FREE_NAME );
#endif
}

void QNodeMap::deleteValue(void *value) {
//	QNode *n = (QNode*)value;
//	delete n;
}

