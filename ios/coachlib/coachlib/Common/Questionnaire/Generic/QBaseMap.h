/*
 *  QBaseMap.h
 *  iStressLess
 *


 *
 */

#ifndef QBASEMAP_H
#define QBASEMAP_H

#include "QDefs.h"

#define MAP_FLAG_FREE_NAME 1
#define MAP_FLAG_FREE_VALUE 2

typedef struct map_entry_t {
	char *name;
	void *value;
	int flags;
} map_entry_t;

class QBaseMap {
protected:
	map_entry_t *entries;
	int entryCount;
public:
	
	QBaseMap();
	virtual ~QBaseMap();
	
	void *_get(const char *name);
	void _put(const char *name, void *value, int flags);
	virtual void deleteValue(void *value);
};

#endif
