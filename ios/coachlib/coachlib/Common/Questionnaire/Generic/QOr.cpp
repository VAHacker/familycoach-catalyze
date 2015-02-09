/*
 *  QOr.cpp
 *  iStressLess
 *


 *
 */

#include "QOr.h"
#include "QUtil.h"

void *QOr::evaluate(QAbstractPlayer *q) {
	if (!subnodes) return NULL;
	for (int i=0;i<subnodeCount;i++) {
		if (QUtil::isTrue(subnodes[i]->evaluate(q))) return (void*)INT_MAX;
	}
	return NULL;
}
