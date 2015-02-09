/*
 *  QInfo.h
 *  iStressLess
 *


 *
 */

#ifndef QINFO_H
#define QINFO_H

#include "QTextContainer.h"

class QInfo : public QTextContainer {
public:
	virtual void *evaluate(QAbstractPlayer *ctx);
};

#endif
