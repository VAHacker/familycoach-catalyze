/*
 *  QHandler.cpp
 *  iStressLess
 *


 *
 */

#include "QHandler.h"
#include "QQuestionnaire.h"

QHandler::QHandler() {
	stackDepth = 0;
}

void QHandler::startDocument() {
}

void QHandler::pushNode(QNode *o) {
	stack[stackDepth++] = o;
}

QNode *QHandler::popNode() {
	return stack[--stackDepth];
}

QNode *QHandler::topNode() {
	if (stackDepth == 0) return NULL;
	return stack[stackDepth-1];
}

void QHandler::error(const char *message) {
	message = message;
}

void QHandler::startElement(const char *localName, QAttributes *attributes) {
	if (stackDepth == 0) {
		if (strcmp(localName,"questionnaire")) {
			// error!
		}
		questionnaire = new QQuestionnaire();
		questionnaire->setID(attributes->get("id"));
		pushNode(questionnaire);
	} else {
		topNode()->startElement(localName, attributes,this);
	}
}

void QHandler::characters(const char *ch, int length) {
	topNode()->characters(ch, length);
}

void QHandler::endElement(const char *localName) {
	QNode *n = popNode();
	if (n != questionnaire) {
		questionnaire->indexNode(n);
		topNode()->addSubnode(n);
	}
}

QQuestionnaire *QHandler::getQuestionaire() {
	return questionnaire;
}
