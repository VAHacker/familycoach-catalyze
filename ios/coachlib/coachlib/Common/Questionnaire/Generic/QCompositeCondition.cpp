/*
 *  QCompositeCondition.cpp
 *  iStressLess
 *


 *
 */

#include "QCompositeCondition.h"
#include "QOr.h"
#include "QAnd.h"
#include "QAttributes.h"
#include "QHandler.h"
#include "QEqualsCondition.h"
#include "QContainsCondition.h"

void QCompositeCondition::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"or")) {
		QOr *n = new QOr();
		n->setID(attributes->get("id"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"and")) {
		QAnd *n = new QAnd();
		n->setID(attributes->get("id"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"contains")) {
		QContainsCondition *n = new QContainsCondition(attributes->get("var"), attributes->get("value"));
		n->setID(attributes->get("id"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"equals")) {
		const char *var = attributes->get("var");
		QEqualsCondition *n = new QEqualsCondition(var, attributes->get("value"));
		n->setID(attributes->get("id"));
		handler->pushNode(n);
	} else {
		QNode::startElement(localName, attributes, handler);
	}
}
