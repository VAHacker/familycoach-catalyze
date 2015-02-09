/*
 *  QIntroScreen.cpp
 *  iStressLess
 *


 *
 */

#include "QIntroScreen.h"
#include "QAbstractPlayer.h"
#include "QQuestionnaire.h"

int QIntroScreen::screenType(QAbstractPlayer *ctx) {
	return 1;
}

void QIntroScreen::addButtons(QAbstractPlayer *ctx) {
	ctx->addButton(BUTTON_DEFER, ctx->getQuestionnaire()->getSettings()->getGlobal(ctx, VAR_DEFER_BUTTON));
	ctx->addButton(BUTTON_DONE,ctx->getQuestionnaire()->getSettings()->getGlobal(ctx, VAR_PROCEED_BUTTON));
}
