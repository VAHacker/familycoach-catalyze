/*
 *  QUtil.cpp
 *  iStressLess
 *


 *
 */

#include "QUtil.h"

bool QUtil::isTrue(void* value) {
	return (int)value;
}

bool QUtil::isWhitespace(const char* value, int len) {
	for (int i=0;i<len;i++) {
		char c = value[i];
		if (c == '\n') continue;
		if (c == '\t') continue;
		if (c == ' ') continue;
		if (c == '\r') continue;
		return false;
	}
	
	return true;
}

char **QUtil::commaDelimitedToSArray(const char* value) {
	if (!value) return NULL;
	
	int count = 1;
	for (int i=0;value[i];i++) {
		if (value[i] == ',') count++;
	}
	
	char **a = (char**)malloc(sizeof(char*)*(count+1));
	const char *start = value;
	for (int i=0;i<count;i++) {
	 	while (*value && (*value != ',')) value++;
		a[i] = (char*)malloc(value-start+1);
		strncpy(a[i],start,value-start);
		a[i][value-start] = 0;
		start = value = value+1;
	}
	a[count] = NULL;
	return a;
}

void QUtil::freeSArray(char** values) {
	for (int i=0;values[i];i++) {
		free(values[i]);
	}
	free(values);
}

int QUtil::sArrayLen(char** values) {
	int count = 0;
	for (int i=0;values[i];i++) {
		count++;
	}
	return count;
}

int QUtil::ntArrayLen(void** values) {
	int count = 0;
	for (int i=0;values[i];i++) {
		count++;
	}
	return count;
}

char * QUtil::sArrayToCommaDelimited(char** values) {
	int len = 0;
	for (int i=0;values[i];i++) {
		if (i != 0) len++;
		len += strlen(values[i]);
	}
	
	char *value = (char*)malloc(len+1);
	char *v = value;
	for (int i=0;values[i];i++) {
		if (i != 0) *v++ = ',';
		strcpy(v,values[i]);
		v += strlen(values[i]);
	}
	
	return value;
}

void **QUtil::copyNtArray(void **values) {
	int count = 0;
	for (int i=0;values[i];i++) {
		count++;
	}
	
	void** a = (void**)malloc((count+1)*sizeof(void*));
	for (int i=0;i<count+1;i++) {
		a[i] = values[i];
	}
	return a;
}

static const char *WS = "\n\t\r ";

static bool is_ws(char c) {
	const char *ws = WS;
	while (*ws) {
		if (*ws++ == c) {
			return true;
		}
	}
	return false;
}

void QUtil::removeWSInline(char *s) {
	char *d = s;
	while (*s) {
		while (*s && is_ws(*s)) s++;
		while (*s && !is_ws(*s)) *d++ = *s++;
		if (!*s) break;
		*d++ = ' ';
	}
	*d++ = 0;
}
