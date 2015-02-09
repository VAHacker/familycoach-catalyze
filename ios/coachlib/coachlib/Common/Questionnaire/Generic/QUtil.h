/*
 *  QUtil.h
 *  iStressLess
 *


 *
 */

#ifndef QUTIL_H
#define QUTIL_H

#include "QDefs.h"

class QUtil {
public:
	static bool isTrue(void* value);
	static bool isWhitespace(const char* value, int len);
	
	static char **commaDelimitedToSArray(const char* value);
	static char *sArrayToCommaDelimited(char** values);
	static void freeSArray(char** values);
	static int sArrayLen(char** values);
	static int ntArrayLen(void** values);
	static void **copyNtArray(void **a);
	static void removeWSInline(char *s);
};

#endif
