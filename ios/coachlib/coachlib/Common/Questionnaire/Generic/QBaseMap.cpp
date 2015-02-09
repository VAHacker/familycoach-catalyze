/*
 *  QBaseMap.cpp
 *  iStressLess
 *


 *
 */

#include "QBaseMap.h"

QBaseMap::QBaseMap() {
	entries = NULL;
	entryCount = 0;
}

QBaseMap::~QBaseMap() {
	for (int i=0;i<entryCount;i++) {
		if (entries[i].flags & MAP_FLAG_FREE_NAME) free(entries[i].name);
		if (entries[i].flags & MAP_FLAG_FREE_VALUE) deleteValue(entries[i].value);
	}
	free(entries);
}

void QBaseMap::deleteValue(void *value) {
	//problem
}

void *QBaseMap::_get(const char *name) {
	for (int i=0;i<entryCount;i++) {
		if (!strcmp(entries[i].name,name)) return entries[i].value;
	}
	return NULL;
}

void QBaseMap::_put(const char *name, void *value, int flags) {
	for (int i=0;i<entryCount;i++) {
		if (!strcmp(entries[i].name,name)) {
			if (flags & MAP_FLAG_FREE_NAME) free((void*)name);
			if (entries[i].flags & MAP_FLAG_FREE_VALUE) deleteValue(entries[i].value);
			entries[i].flags = (entries[i].flags & MAP_FLAG_FREE_NAME) | (flags & MAP_FLAG_FREE_VALUE);
			entries[i].value = value;
			return;
		}
	}
	
	entries = (map_entry_t*)realloc(entries, sizeof(map_entry_t)*(entryCount+1));
	
	entries[entryCount].name = (char*)name;
	entries[entryCount].value = value;
	entries[entryCount].flags = flags;
	entryCount++;
}

