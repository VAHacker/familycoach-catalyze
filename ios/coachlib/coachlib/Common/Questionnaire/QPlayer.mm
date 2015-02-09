/*
 *  QPlayer.cpp
 *  iStressLess
 *


 *
 */

#include "QPlayer.h"
#include "QQuestionnaire.h"
#import "QuestionnaireViewController.h"
#import "QuestionInstance.h"
#include "QuestionnaireParser.h"
#include "QChoice.h"
#include "QHandler.h"
#include "QUtil.h"
#include "heartbeat.h"
#import "VaPtsdExplorerProbesCampaign.h"
#import "GTextView.h"
#import "GTableView.h"
#import "ThemeManager.h"

QPlayer::QPlayer(NavController *_masterController) {
    questionnaireList[0] = nil;
    questionnaireCount = 0;
    questionnaireIndex = -1;
	masterController = _masterController;
	delegate = nil;
	viewCon = nil;
	screensDisplayed = 0;
}

QPlayer::~QPlayer() {
    for (int i=0;i<questionnaireCount;i++) {
        delete questionnaireList[i];
    }
	[viewCon release];
}

void QPlayer::addQuestionnaire(QQuestionnaire *q) {
    questionnaireList[questionnaireCount++] = q;
    questionnaireList[questionnaireCount] = nil;
	if (questionnaireCount == 1) {
        setQuestionnaire(q);
        questionnaireIndex = 0;
    }
}

void QPlayer::addQuestionnaire(NSString *filePath) {
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	QuestionnaireParser *parser = [[QuestionnaireParser alloc] init];
	[parser parseData:(NSData *)data];
	QQuestionnaire *q = parser.handler->getQuestionaire();
    addQuestionnaire(q);
    [parser release];
}

QPlayer::QPlayer(NavController *navController, NSString *filePath) {
    questionnaireList[0] = nil;
    questionnaireCount = 0;
    questionnaireIndex = -1;
	masterController = navController;
	delegate = nil;
	viewCon = nil;
	screensDisplayed = 0;
    
    addQuestionnaire(filePath);
}

void QPlayer::setDelegate(id _delegate) {
	delegate = _delegate;
}

const char * QPlayer::replaceVariables(const char *str) {
	if (!viewCon) return str;
	return [[viewCon replaceVariables:[NSString stringWithUTF8String:str]] UTF8String];
}

void QPlayer::beginScreen(const char *title, int screenType) {
	if (viewCon) {
		[viewCon release];
		viewCon = nil;
	}

	viewCon = [[QuestionnaireViewController alloc] initWithPlayer:this];
	viewCon.masterController = masterController;
#ifdef EXPLORER_EMA
    viewCon.navigationItem.title = [NSString stringWithFormat:@"Question #%d",screensDisplayed+1];
#else
	if (title) viewCon.navigationItem.title = [NSString stringWithUTF8String:title];
#endif
	viewCon.navigationItem.hidesBackButton = TRUE;
    
#ifndef EXPLORER_EMA
	if (!screensDisplayed) {
        ThemeManager *theme = [ThemeManager sharedManager];
        NSString *helpIconName = [theme stringForName:@"helpIcon"];
        UIImage *helpIcon = [UIImage imageNamed:helpIconName];
        if (helpIcon) {
            viewCon.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:helpIcon
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:viewCon
                                                                                      action:@selector(helpPressed)] autorelease];
        } else {
            viewCon.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithTitle:@"Help" 
                                              style:UIBarButtonItemStyleBordered
                                             target:viewCon action:@selector(helpPressed)] autorelease];
        }
	}
#endif
    
	viewCon.navigationItem.leftBarButtonItem = 
		[[[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
									 style:UIBarButtonItemStyleBordered
									target:viewCon action:@selector(cancelPressed)] autorelease];
	screensDisplayed++;
}

void QPlayer::addImage(const char *url) {
}

void changeUISegmentFont(UIView* aView) {
	//NSString* typeName = [[aView class] className];
	Class lookingFor = NSClassFromString(@"UISegmentLabel"); 
//	if ([typeName compare:@"UISegmentLabel" options:NSLiteralSearch] == NSOrderedSame) {
	if (lookingFor == [aView class]) {
		UILabel* label = (UILabel*)aView;
		[label setTextAlignment:NSTextAlignmentCenter];
		[label setFont:[UIFont boldSystemFontOfSize:11]];
		label.lineBreakMode = NSLineBreakByWordWrapping;
//		label.numberOfLines = 2;
		CGRect r = label.frame;
		r.size.width -=10;
		r.size.height +=20;
//		label.frame = r;
	}
	NSArray* subs = [aView subviews];
	NSEnumerator* iter = [subs objectEnumerator];
	UIView* subView;
	while (subView = [iter nextObject]) {
		changeUISegmentFont(subView);
	}
}

void QPlayer::recordAnswer(const char *id, const char *answer) {
    QAbstractPlayer::recordAnswer(id, answer);
    
    int questionNum;
    if (sscanf(id,"pcl%d",&questionNum) > 0) {
        [PclQuestionAnsweredEvent logWithPclNumberOfQuestionsAnswered:questionNum];

        [heartbeat
         logEvent:@"PCL_ANSWER" 
         withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"question",[NSString stringWithUTF8String:id],@"answer",[NSString stringWithUTF8String:answer], nil]];
    }
}

void QPlayer::addText(const char *text) {
	[viewCon addText:[NSString stringWithUTF8String:text]];
}

void QPlayer::addFreeformQuestion(const char *id, const char *question, const char *placeholder, int lines, int maxLength, bool mandatory) {
    NSString *nsplaceholder = placeholder ? [NSString stringWithUTF8String:placeholder] : nil;

	QuestionInstance *questionInstance = [[QuestionInstance alloc] initWithPlayer:this andID:[NSString stringWithUTF8String:id]];
	questionInstance.viewCon = viewCon;
    questionInstance.freeformMaxLength = maxLength;
	[viewCon addQuestion:questionInstance];

    [viewCon addText:[NSString stringWithUTF8String:question]];
/*
    UIView *label = [viewCon createLabel:[NSString stringWithUTF8String:question]];
    CGRect r = label.frame;
    r.origin.y += 10;
    label.frame = r;
    [viewCon.view addSubview:label];
*/
    GTextView *tv = [viewCon addTextInputWithLines:lines andPlaceholder:nsplaceholder];
    tv.delegate = questionInstance;
    [questionInstance release];
}

void QPlayer::addChoiceQuestion(const char *id, const char *question, int minChoices, int maxChoices, QChoice **choices) {

	QuestionInstance *questionInstance = [[QuestionInstance alloc] initWithPlayer:this andID:[NSString stringWithUTF8String:id]];
	[questionInstance setChoices:choices];
	questionInstance.viewCon = viewCon;
	questionInstance.maxAnswers = maxChoices;
	questionInstance.minAnswers = minChoices;

	[viewCon addQuestion:questionInstance];
	
	UIView *label = [viewCon createLabel:[NSString stringWithUTF8String:question]];

	if (0 && (minChoices == 1) && (maxChoices == 1) && (QUtil::ntArrayLen((void**)choices) <= 5)) {
		CGRect r = label.frame;
		r.origin.y += 10;
		label.frame = r;
		[viewCon.view addSubview:label];
		
		r.origin.y += r.size.height+10;
		r.origin.x += 5;
		r.size.width -= 10;
		r.size.height = 40;
		
		NSMutableArray *items = [NSMutableArray array];
		int choiceIndex = 0;
		while (choices[choiceIndex]) {
			[items addObject:[NSString stringWithUTF8String:choices[choiceIndex++]->getText(this)]];
		}
		UISegmentedControl *segments = [[UISegmentedControl alloc] initWithItems:items];
		segments.frame = r;
		segments.segmentedControlStyle = UISegmentedControlStyleBar;
		[segments addTarget:questionInstance action:@selector(resetSegmentedControl:) forControlEvents:UIControlEventValueChanged];
		changeUISegmentFont(segments);
		[viewCon.dynamicView addSubview:segments];
//		[viewCon setAboveButtonsView:segments];
	} else {
		viewCon.dynamicView.topMargin = 10;
		[viewCon.dynamicView addSubview:label];
//		questionInstance.headerView = label;

		CGRect bounds = [viewCon.view bounds];
		CGRect tableFrame = bounds;
//		tableFrame.origin.y += 10;
        tableFrame.size.height = 64 * questionInstance.numChoices + 10;
//		tableFrame.size.height = bounds.size.height - tableFrame.origin.y - 50;
		UITableView *table = [[GTableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
        
		[table setDelegate:questionInstance];
		[table setDataSource:questionInstance];
		table.rowHeight = 40;
		table.opaque = FALSE;
		table.backgroundColor = [UIColor clearColor];
        table.backgroundView = nil;
		[viewCon.dynamicView addSubview:table];
		[table release];
	}

	[questionInstance release];
	[label release];

}

void QPlayer::addButton(int buttonType, const char *label) {
    [viewCon addButtonWithText:[NSString stringWithUTF8String:label] callingBlock:^{
        switch (buttonType) {
            case BUTTON_NEXT: {
                [viewCon nextPressed];
                break;
            }
            case BUTTON_DONE:
                [viewCon donePressed];
                break;
            default:
                break;
        };
    }];
}

void QPlayer::showScreen() {
	[viewCon updateValidity];
    [viewCon addAllButtonViews];
    viewCon.navigationItem.hidesBackButton = TRUE;
    [masterController pushChild:viewCon andRemoveOld:TRUE animated:TRUE];
}

void QPlayer::finish() {
    questionnaireIndex++;
    if (questionnaireList[questionnaireIndex]) {
        setQuestionnaire(questionnaireList[questionnaireIndex]);
        play();
    } else {
        [delegate questionnairePlayerHasFinished:this];
    }
}

void QPlayer::donePressed() {
	finish();
}

void QPlayer::deferPressed() {
	[delegate questionnairePlayerWasCancelled:this];
}
