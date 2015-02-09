/*
 *  QChoiceQuestion.cpp
 *  iStressLess
 *


 *
 */

#include "QChoiceQuestion.h"
#include "QAbstractPlayer.h"
#include "QChoice.h"
#include "QHandler.h"
#include "QAttributes.h"

QChoiceQuestion::QChoiceQuestion() {
	maxSelectable = 1;
	minSelectable = 1;
}

void QChoiceQuestion::setMinSelectable(int _minSelectable) {
	minSelectable = _minSelectable;
}

void QChoiceQuestion::setMaxSelectable(int _maxSelectable) {
	maxSelectable = _maxSelectable;
}

QChoice **QChoiceQuestion::getChoices() {
	int count = 0;
	for (int i=0;i<subnodeCount;i++) {
		if (subnodes[i]->getType() == NODETYPE_CHOICE) count++;
	}
	QChoice** c = (QChoice**)malloc((count+1) * sizeof(QChoice*));
	int j = 0;
	for (int i=0;i<subnodeCount;i++) {
		if (subnodes[i]->getType() == NODETYPE_CHOICE) {
			c[j++] = (QChoice*)subnodes[i];	
		}
	}
	c[count] = NULL;
	return c;
}

void *QChoiceQuestion::evaluate(QAbstractPlayer *ctx) {
	QChoice **choices = getChoices();
	ctx->addChoiceQuestion(id, getText(ctx), minSelectable, maxSelectable, choices);
	free(choices);
	return NULL;
}

void QChoiceQuestion::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"choice")) {
		QChoice *n = new QChoice();
		n->setID(attributes->get("id"));
		n->setValue(attributes->get("value"));
		handler->pushNode(n);
	} else {
		QTextContainer::startElement(localName, attributes, handler);
	}
}
