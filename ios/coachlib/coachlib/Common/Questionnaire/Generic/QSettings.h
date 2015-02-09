/*
 *  QSettings.h
 *  iStressLess
 *


 *
 */

#ifndef QSETTINGS_H
#define QSETTINGS_H

#include "QNode.h"
#include "QAttributes.h"
#include "QNodeMap.h"
#include "QStringMap.h"

class QSettings : public QNode {

protected:
	QStringMap texts;
	QNodeMap textContainers;
	
public:
	QSettings();

	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
	virtual const char *getGlobal(QAbstractPlayer *ctx, const char *varName);
	
};

#endif
