/*
 *  QBranch.cpp
 *  iStressLess
 *


 *
 */

#include "QBranch.h"
#include "QUtil.h"
#include "QAbstractPlayer.h"
#include "QQuestionnaire.h"

QBranch::QBranch() {
	destination = NULL;
}

const char *QBranch::getDestination() {
	return destination;
}

void QBranch::setDestination(const char *_destination) {
	if (destination) free(destination);
	destination = _destination ? strdup(_destination) : NULL;
}

void *QBranch::evaluate(QAbstractPlayer *ctx) {
	if (QUtil::isTrue(QAnd::evaluate(ctx))) {
		return ctx->getQuestionnaire()->getNodeByID(destination);
	}
	
	return next(ctx);
}
