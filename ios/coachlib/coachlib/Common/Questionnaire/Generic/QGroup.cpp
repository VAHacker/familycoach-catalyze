/*
 *  QGroup.cpp
 *  iStressLess
 *


 *
 */

#include "QGroup.h"
#include "QScreen.h"
#include "QHandler.h"
#include "QAttributes.h"

QGroup::QGroup() {
}

QGroup::~QGroup() {
}

void QGroup::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"screen")) {
		QScreen *n = new QScreen();
		n->setID(attributes->get("id"));
		n->setTitle(attributes->get("title"));
		handler->pushNode(n);
/*
	} else if (!strcmp(localName,"randomOrder")) {
		QRandomOrderGroup *n = new QRandomOrderGroup();
		n->setID(attributes->getValue("id"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"selectOne")) {
		QChooseOneGroup *n = new QChooseOneGroup();
		n->setID(attributes.getValue("id"));
		handler->pushNode(n);
*/	} else {
		QNode::startElement(localName, attributes, handler);
	}
}
