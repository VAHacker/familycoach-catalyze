/*
 *  QStringMap.cpp
 *  iStressLess
 *


 *
 */

#include "QStringMap.h"

const char *QStringMap::get(const char *name) {
	return (const char *)_get(name);
}

void QStringMap::put(const char *name, const char *value) {
#ifndef __clang_analyzer__ // avoid false memory leak triggering
	_put(strdup(name),(void*)strdup(value), MAP_FLAG_FREE_NAME | MAP_FLAG_FREE_VALUE);
#endif
}

void QStringMap::deleteValue(void *value) {
	free(value);
}

