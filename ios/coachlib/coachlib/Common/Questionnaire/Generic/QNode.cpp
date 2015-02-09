/*
 *  QNode.cpp
 *  iStressLess
 *


 *
 */

#include "QNode.h"
#include "QAttributes.h"
#include "QHandler.h"

QNode::QNode() {
	id = NULL;
	parent = NULL;
	subnodes = NULL;
	subnodeCount = 0;
}

QNode::~QNode() {
    if (id) free(id);
    if (subnodeCount && subnodes) {
        for (int i=0;i<subnodeCount;i++) {
            delete subnodes[i];
        }
        free(subnodes);
    }
}

int QNode::getType() {
	return NODETYPE_UNKNOWN;
}

void QNode::setID(const char *_id) {
	if (id) {
		free(id);
	}
	id = _id ? strdup(_id) : NULL;
}

const char *QNode::getID() {
	return id;
}

QNode *QNode::getParent() {
	return parent;
}

void QNode::addSubnode(QNode *node) {
	if (subnodes == NULL) {
		subnodes = (QNode**)malloc(sizeof(QNode*));
		subnodes[0] = node;
		subnodeCount = 1;
	} else {
		subnodes = (QNode**)realloc(subnodes,sizeof(QNode*)*(subnodeCount+1));
		subnodes[subnodeCount] = node;
		subnodeCount++;
	}
	
	node->parent = this;
}

QNode **QNode::getSubnodes() {
	return subnodes;
}

int QNode::getSubnodeCount() {
	return subnodeCount;
}

QNode *QNode::next(QAbstractPlayer *ctx) {
	if (!parent) return NULL;
	return parent->getSubnodeAfter(ctx,this);
}

QNode *QNode::getSubnodeAfter(QAbstractPlayer *ctx, QNode *n) {
	for (int i=0;i<subnodeCount-1;i++) {
		if (n == subnodes[i]) {
			return subnodes[i+1];
		}
	}
	
	return next(ctx);
}

bool QNode::shouldEvaluate(QAbstractPlayer *ctx) {
	return true;
}

void* QNode::evaluate(QAbstractPlayer *ctx) {
	return next(ctx);
}

void QNode::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	handler->error("base ::startElement called");
}

void QNode::characters(const char* ch, int length) {
//	handler->error("base ::characters called");
}
