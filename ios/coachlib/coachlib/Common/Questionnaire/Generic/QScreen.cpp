/*
 *  QScreen.cpp
 *  iStressLess
 *


 *
 */

#include "QScreen.h"
#include "QUtil.h"
#include "QQuestionnaire.h"
#include "QAnd.h"
#include "QInfo.h"
#include "QChoiceQuestion.h"
#include "QFreeFormQuestion.h"
#include "QImage.h"
#include "QHandler.h"

QScreen::QScreen() {
	showOnCondition = NULL;
	title = NULL;
}

QScreen::~QScreen() {
    if (title) free(title);
}

void QScreen::setTitle(const char *_title) {
	if (title) free(title);
	title = _title ? strdup(_title) : NULL;
}

int QScreen::screenType(QAbstractPlayer *ctx) {
	return 0;
}

void *QScreen::evaluate(QAbstractPlayer *ctx) {
	if (!showOnCondition || QUtil::isTrue(showOnCondition->evaluate(ctx))) {
		ctx->beginScreen(title,screenType(ctx));
		for (int i=0;i<subnodeCount;i++) {
			subnodes[i]->evaluate(ctx);
		}
		addButtons(ctx);
		ctx->showScreen();
		return NULL;
	} else {
		QNode *n = next(ctx);
        if (n == NULL) {
            ctx->finish();
        }
        return n;
	}
}

void QScreen::addButtons(QAbstractPlayer *ctx) {
	ctx->addButton(BUTTON_NEXT, ctx->getQuestionnaire()->getSettings()->getGlobal(ctx, VAR_NEXT_BUTTON));
}

bool QScreen::shouldEvaluate(QAbstractPlayer *ctx) {
	return ((showOnCondition == NULL) || QUtil::isTrue(showOnCondition->evaluate(ctx)));
}

void QScreen::addSubnode(QNode *node) {
	if (node == showOnCondition) return;
	QNode::addSubnode(node);
}

void QScreen::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"info")) {
		QInfo *n = new QInfo();
		n->setID(attributes->get("id"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"image")) {
		QImage *n = new QImage();
		n->setID(attributes->get("id"));
		n->setURL(attributes->get("url"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"multi")) {
		const char *maxChoices = attributes->get("max");
		const char *minChoices = attributes->get("min");
		
		int max;
		if (!maxChoices) max = 1;
		else if (!strcmp("none",maxChoices)) max = INT_MAX;
		else max = atoi(maxChoices);
		
		int min;
		if (!minChoices) min = 1;
		else min = atoi(minChoices);
		
		QChoiceQuestion *n = new QChoiceQuestion();
		n->setID(attributes->get("id"));
		n->setMaxSelectable(max);
		n->setMinSelectable(min);
		handler->pushNode(n);
	} else if (!strcmp(localName,"freeform")) {
		QFreeFormQuestion *n = new QFreeFormQuestion();
		n->setID(attributes->get("id"));

		const char *linesStr = attributes->get("lines");
		int lines = 1;
		if (linesStr) lines = atoi(linesStr);
		n->setInputLines(lines);

        const char *maxLengthStr = attributes->get("maxLength");
		int maxLength = 2048;
		if (maxLengthStr) maxLength = atoi(maxLengthStr);
		n->setMaxSize(maxLength);

        const char *placeholderStr = attributes->get("placeholder");
		if (placeholderStr) n->setPlaceholder(placeholderStr);
        
		handler->pushNode(n);
	} else if (!strcmp(localName,"condition")) {
		showOnCondition = new QAnd();
		showOnCondition->setID(attributes->get("id"));
		handler->pushNode(showOnCondition);
	} else {
		QNode::startElement(localName, attributes, handler);
	}
}
