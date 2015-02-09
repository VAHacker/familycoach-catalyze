/*
 *  QAnd.cpp
 *  iStressLess
 *


 *
 */

#include "QAnd.h"
#include "QUtil.h"

void *QAnd::evaluate(QAbstractPlayer *q) {
	if (!subnodes) return (void*)INT_MAX;
	for (int i=0;i<subnodeCount;i++) {
		if (!QUtil::isTrue(subnodes[i]->evaluate(q))) return NULL;
	}
	return (void*)INT_MAX;
}
