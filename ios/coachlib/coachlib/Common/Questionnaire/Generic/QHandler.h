/*
 *  QHandler.h
 *  iStressLess
 *


 *
 */

#include "QDefs.h"

class QAttributes;
class QNode;
class QQuestionnaire;

class QHandler {
	
	QQuestionnaire *questionnaire;
	QNode* stack[32];
	int stackDepth;

public:
	QHandler();

	virtual void startDocument();
	virtual void pushNode(QNode *o);
	virtual QNode *popNode();
	virtual QNode *topNode();
	virtual void startElement(const char *localName, QAttributes *attributes);
	virtual void characters(const char *ch, int length);
	virtual void endElement(const char *localName);
	virtual void error(const char *message);
	virtual QQuestionnaire *getQuestionaire();
};
