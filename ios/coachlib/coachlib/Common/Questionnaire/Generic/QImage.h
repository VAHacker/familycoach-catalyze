/*
 *  QImage.h
 *  iStressLess
 *


 *
 */

#ifndef QIMAGE_H
#define QIMAGE_H

#include "QNode.h"

class QImage : public QNode {
	
	char *url;
	
public:
	QImage();
	virtual ~QImage();
	
	virtual const char *getURL();
	virtual void setURL(const char *_url);
	virtual void *evaluate(QAbstractPlayer *ctx);
	
};

#endif
