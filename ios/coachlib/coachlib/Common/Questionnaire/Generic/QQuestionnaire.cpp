/*
 *  QQuestionnaire.cpp
 *  iStressLess
 *


 *
 */

#include "QQuestionnaire.h"
#include "QBranch.h"
#include "QIntroScreen.h"
#include "QEnd.h"
#include "QHandler.h"
#include "QAttributes.h"

QQuestionnaire::QQuestionnaire() {
	intro = NULL;
}

QQuestionnaire::~QQuestionnaire() {
}

void QQuestionnaire::indexNode(QNode *node) {
	if (node->getID()) nodesByID.put(node->getID(), node);
}

QNode *QQuestionnaire::getNodeByID(const char *id) {
	return (QNode*)nodesByID.get(id);
}

void QQuestionnaire::addSubnode(QNode *node) {
	if (node == &settings) return;
	if (node == (QNode*)intro) return;
	QGroup::addSubnode(node);
}

QSettings *QQuestionnaire::getSettings() {
	return &settings;
}

QScreen *QQuestionnaire::getIntro() {
	return intro;
}

void QQuestionnaire::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	if (!strcmp(localName,"branch")) {
		QBranch *n = new QBranch();
		n->setID(attributes->get("id"));
		n->setDestination(attributes->get("destination"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"intro")) {
		intro = new QIntroScreen();
		intro->setID(attributes->get("id"));
		intro->setTitle(attributes->get("title"));
		handler->pushNode(intro);
	} else if (!strcmp(localName,"end")) {
		QEnd *n = new QEnd();
		n->setID(attributes->get("id"));
		n->setTitle(attributes->get("title"));
		handler->pushNode(n);
	} else if (!strcmp(localName,"globals")) {
		settings.setID(attributes->get("id"));
		handler->pushNode(&settings);
	} else {
		QGroup::startElement(localName, attributes, handler);
	}
}

