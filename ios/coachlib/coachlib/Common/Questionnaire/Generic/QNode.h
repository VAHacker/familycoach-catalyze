/*
 *  QNode.h
 *  iStressLess
 *


 *
 */

#ifndef QNODE_H
#define QNODE_H

#include "QDefs.h"

class QAbstractPlayer;
class QAttributes;
class QHandler;

class QNode {
protected:
	char *id;
	QNode *parent;
	QNode **subnodes;
	int subnodeCount;
	
public:

	QNode();
	virtual ~QNode();
	
	virtual int getType();
	virtual void setID(const char *_id);
	virtual const char *getID();
	virtual QNode *getParent();
	virtual void addSubnode(QNode *node);
	virtual QNode **getSubnodes();
	virtual int getSubnodeCount();
	virtual QNode *next(QAbstractPlayer *ctx);
	virtual QNode *getSubnodeAfter(QAbstractPlayer *ctx, QNode *n);
	virtual bool shouldEvaluate(QAbstractPlayer *ctx);
	virtual void* evaluate(QAbstractPlayer *ctx);
	virtual void startElement(const char *localName, QAttributes *attributes, QHandler *handler);
	virtual void characters(const char* ch, int length);
	
};

#endif

