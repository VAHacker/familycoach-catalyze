/*
 *  QTextContainer.h
 *  iStressLess
 *


 *
 */

#ifndef QTEXTCONTAINER_H
#define QTEXTCONTAINER_H

#include "QNode.h"

class QTextContainer : public QNode {
public:
	virtual const char *getText(QAbstractPlayer *ctx);
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
	virtual void characters(const char* ch, int length);
};

#endif
