/*
 *  QChoiceQuestion.cpp
 *  iStressLess
 *


 *
 */

#include "QFreeFormQuestion.h"
#include "QAbstractPlayer.h"
#include "QChoice.h"
#include "QHandler.h"
#include "QAttributes.h"

QFreeFormQuestion::QFreeFormQuestion() {
	maxSize = 2048;
    lines = 3;
    placeholder = NULL;
}

QFreeFormQuestion::~QFreeFormQuestion() {
    if (placeholder) free(placeholder);
}

void QFreeFormQuestion::setMaxSize(int _maxSelectable) {
	maxSize = _maxSelectable;
}

void QFreeFormQuestion::setInputLines(int _lines) {
	lines = _lines;
}

void QFreeFormQuestion::setPlaceholder(const char *_placeholder) {
    if (placeholder) free(placeholder);
    placeholder = strdup(_placeholder);
}

void *QFreeFormQuestion::evaluate(QAbstractPlayer *ctx) {
    ctx->addFreeformQuestion(id, getText(ctx), placeholder, lines, maxSize, true);
	return NULL;
}

void QFreeFormQuestion::startElement(const char *localName, QAttributes *attributes, QHandler *handler) {
	QTextContainer::startElement(localName, attributes, handler);
}
