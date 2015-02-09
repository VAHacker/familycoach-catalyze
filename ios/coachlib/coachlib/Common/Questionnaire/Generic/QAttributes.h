/*
 *  QMap.h
 *  iStressLess
 *


 *
 */

#ifndef QATTRIBUTES_H
#define QATTRIBUTES_H

#include "QDefs.h"

class QAttributes {
public:
	virtual const char *get(const char *name) = 0;
};

#endif
