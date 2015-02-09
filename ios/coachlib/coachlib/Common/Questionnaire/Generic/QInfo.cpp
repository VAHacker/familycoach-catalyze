/*
 *  QInfo.cpp
 *  iStressLess
 *


 *
 */

#include "QInfo.h"
#include "QAbstractPlayer.h"

void *QInfo::evaluate(QAbstractPlayer *ctx) {
	ctx->addText(getText(ctx));
	return NULL;
}
