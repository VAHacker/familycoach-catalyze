/*
 *  QEnd.cpp
 *  iStressLess
 *


 *
 */

#include "QEnd.h"
#include "QQuestionnaire.h"

void QEnd::addButtons(QAbstractPlayer *ctx) {
	ctx->addButton(BUTTON_DONE,ctx->getQuestionnaire()->getSettings()->getGlobal(ctx, VAR_DONE_BUTTON));
}
