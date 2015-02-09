/*
 *  QText.cpp
 *  iStressLess
 *


 *
 */

#include "QText.h"
#include "QUtil.h"

QText::QText() {
	text = NULL;
	locale = NULL;
}

QText::~QText() {
    if (text) free(text);
    if (locale) free(locale);
}

int QText::getType() {
	return NODETYPE_TEXT;
}

void QText::appendText(const char *newText, int length) {
	if (!text) {
		if (!newText) text = NULL;
		else {
			text = (char*)malloc(length+1);
			strncpy(text,newText,length);
			text[length] = 0;
		}
	} else {
		int oldLen = strlen(text);
		text = (char*)realloc(text,oldLen+length+1);
		strncat(text,newText,length);
	}
	
	QUtil::removeWSInline(text);
}

const char *QText::getLocale() {
	return locale;
}

const char *QText::getText() {
	return text;
}

void QText::setLocale(const char *_locale) {
	if (locale) free(locale);
	locale = _locale ? strdup(_locale) : NULL;
}

void QText::setText(const char *_text, int len) {
	if (text) free(text);
	if (_text) {
		text = (char*)malloc(len+1);
		strncpy(text,_text,len);
		text[len] = 0;
	} else {
		text = NULL;
	}
}

void QText::characters(const char* ch, int length) {
	appendText(ch,length);
}
