/*
 *  QContainsCondition.cpp
 *  iStressLess
 *


 *
 */

#include "QContainsCondition.h"
#include "QUtil.h"
#include "QAbstractPlayer.h"

QContainsCondition::QContainsCondition(const char * variable, const char *_values) {
	variableName = strdup(variable);
	values = QUtil::commaDelimitedToSArray(_values);
}

void* QContainsCondition::evaluate(QAbstractPlayer *q) {
	const char *answer = q->fetchAnswer(variableName);
	
	if (!answer) return NULL;
	
	char **a = QUtil::commaDelimitedToSArray(answer);
	
	bool r = false;
	int valuesLen = QUtil::sArrayLen(values);
	int aLen = QUtil::sArrayLen(a);
	for (int i=0;i<valuesLen;i++) {
		bool isInThere = false;
		for (int j=0;j<aLen;j++) {
			if (!strcmp(values[i],a[j])) {
				isInThere = true;
				break;
			}
		}
		
		if (isInThere) {
			r = true;
			break;
		}
	}
	
	QUtil::freeSArray(a);
	return r ? (void*)INT_MAX : NULL;
}
