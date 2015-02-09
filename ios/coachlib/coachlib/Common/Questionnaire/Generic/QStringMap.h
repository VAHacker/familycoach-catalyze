/*
 *  QStringMap.h
 *  iStressLess
 *


 *
 */

#ifndef QSTRINGMAP_H
#define QSTRINGMAP_H

#include "QDefs.h"
#include "QBaseMap.h"

class QStringMap : public QBaseMap {
public:
	const char *get(const char *name);
	void put(const char *name, const char *value);
	virtual void deleteValue(void *value);
};

#endif
