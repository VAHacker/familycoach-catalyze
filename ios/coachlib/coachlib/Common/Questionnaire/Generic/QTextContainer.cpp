/*
 *  QTextContainer.cpp
 *  iStressLess
 *


 *
 */

#include "QTextContainer.h"
#include "QText.h"
#include "QAttributes.h"
#include "QHandler.h"
#include "QUtil.h"
#include "QAbstractPlayer.h"

const char *QTextContainer::getText(QAbstractPlayer *ctx) {
	// Need to deal with locales
	if (!subnodes) return NULL;

	for (int i=0;i<subnodeCount;i++) {
		QNode *n = subnodes[i];
		if (n->getType() == NODETYPE_TEXT) {
			QText *t = (QText*)n;
			const char *str = t->getText();
			return ctx ? ctx->replaceVariables(str) : str;
		}
	}
	
	return NULL;
}

void QTextContainer::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"text")) {
		QText *n = new QText();
		n->setID(attributes->get("id"));
		n->setLocale(attributes->get("locale"));
		handler->pushNode(n);
	} else {
		QNode::startElement(localName, attributes, handler);
	}
}

void QTextContainer::characters(const char* ch, int length) {
	if (!getText(NULL)) {
		// No text has been placed in this container yet...
		// For convenience, create a new text node to hold this text
		// There will be no locale set for this created text node
		if (!QUtil::isWhitespace(ch,length)) {
			QText *n = new QText();
			n->setText(ch,length);
			addSubnode(n);
		}
	} else if (!QUtil::isWhitespace(ch,length)) {
		// error
	}
}
