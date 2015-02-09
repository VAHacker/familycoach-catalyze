/*
 *  QChoice.cpp
 *  iStressLess
 *


 *
 */

#include "QChoice.h"

QChoice::QChoice() {
	value = NULL;
}

int QChoice::getType() {
	return NODETYPE_CHOICE;
}

void QChoice::setValue(const char *_value) {
	if (value) free(value);
	value = _value ? strdup(_value) : NULL;
}

const char *QChoice::getValue() {
	return value;
}
