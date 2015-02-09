/*
 *  QEqualsCondition.cpp
 *  iStressLess
 *


 *
 */

#include "QEqualsCondition.h"
#include "QUtil.h"
#include "QAbstractPlayer.h"

QEqualsCondition::QEqualsCondition(const char * variable, const char *_values) {
	variableName = strdup(variable);
	values = QUtil::commaDelimitedToSArray(_values);
}

void* QEqualsCondition::evaluate(QAbstractPlayer *q) {
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
		
		if (!isInThere) {
			r = false;
			goto end;
		}
	}
	
	if (valuesLen == aLen) r = true;
end:
	QUtil::freeSArray(a);
	return r ? (void*)INT_MAX : NULL;
}
