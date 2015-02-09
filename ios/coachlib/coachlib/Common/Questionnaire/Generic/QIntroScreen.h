/*
 *  QIntroScreen.h
 *  iStressLess
 *


 *
 */

#include "QScreen.h"

class QAbstractPlayer;

class QIntroScreen : public QScreen {
	
	virtual int  screenType(QAbstractPlayer *ctx);
	virtual void addButtons(QAbstractPlayer *ctx);
	
};
