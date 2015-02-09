/*
 *  QImage.cpp
 *  iStressLess
 *


 *
 */

#include "QImage.h"
#include "QAbstractPlayer.h"

QImage::QImage() {
	url = NULL;
}

QImage::~QImage() {
}

const char *QImage::getURL() {
	return url;
}

void QImage::setURL(const char *_url) {
	if (url) free((void*)url);
	url = _url ? strdup(_url) : NULL;
}

void *QImage::evaluate(QAbstractPlayer *ctx) {
	ctx->addImage(url);
	return NULL;
}
