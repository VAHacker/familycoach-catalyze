/*
 *  QSettings.cpp
 *  iStressLess
 *


 *
 */

#include "QSettings.h"
#include "QTextContainer.h"
#include "QHandler.h"
#include "QAttributes.h"

QSettings::QSettings() {
	texts.put(VAR_NEXT_BUTTON, "Next");
	texts.put(VAR_DONE_BUTTON, "Done");
	texts.put(VAR_DEFER_BUTTON, "Ask me later");
	texts.put(VAR_PROCEED_BUTTON, "Ok");
	texts.put(VAR_TITLE, "IQ Agent Questionnaire");
	texts.put(VAR_NOTIFICATION, "Please complete this questionnaire.");
	texts.put(VAR_REMINDERS, "1,5,10,15,60,120,180");
}

void QSettings::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	QTextContainer *t = new QTextContainer();
	t->setID(attributes->get("id"));
	textContainers.put(localName, t);
	handler->pushNode(t);
}

const char *QSettings::getGlobal(QAbstractPlayer *ctx, const char *varName) {
	QNode *n = textContainers.get(varName);
	if (n) return ((QTextContainer*)n)->getText(ctx);
	const char *t = texts.get(varName);
	return t;
}
