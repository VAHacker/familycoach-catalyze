package gov.va.contentlib.controllers;

import gov.va.contentlib.TopContentActivity;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.PCLScore;
import gov.va.contentlib.questionnaire.Questionnaire;
import gov.va.contentlib.questionnaire.QuestionnaireHandler;
import gov.va.contentlib.questionnaire.SurveyUtil;
import gov.va.contentlib.questionnaire.android.QuestionnaireManager;
import gov.va.contentlib.questionnaire.android.QuestionnairePlayer;
import gov.va.contentlib.questionnaire.android.QuestionnairePlayer.QuestionnaireListener;

import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;

import com.flurry.android.FlurryAgent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PclAssessmentAbortedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PclAssessmentCompletedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PclAssessmentStartedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PclReminderScheduledEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TimeElapsedBetweenPCLAssessmentsEvent;
import com.openmhealth.ohmage.core.EventLog;

public class QuestionnaireContentController extends NavController implements QuestionnaireListener {

	QuestionnairePlayer player;
	MenuItem favoritesItem;
	boolean inQuestionnaire = false;
	
//	public static final int BUTTON_REMIND_ME = 100;
//	public static final int BUTTON_TAKE_IT_ANYWAY = 101;
//	public static final int BUTTON_PROMPT_TO_SCHEDULE = 102;
//	public static final int BUTTON_SEE_HISTORY = 103;
//	public static final int BUTTON_RETURN_TO_ROOT = 104;
//	public static final int BUTTON_SCHEDULE_IN_MONTH = 105;

	static final String[] numbersToWords = {
		null,
		"one",
		"two",
		"three",
		"four",
		"five",
		"six",
		"seven",
		"eight",
		"nine",
		"ten",
		"eleven",
		"twelve",
		"thirteen",
		"fourteen",
		"fifteen",
		"sixteen",
		"seventeen",
		"eighteen",
		"nineteen",
		"twenty",
		"twenty-one",
		"twenty-two",
		"twenty-three",
		"twenty-four"
	};

/*	
	private String timeIntervalToString(long interval) {
		double secondsInterval = interval / 1000.0;
		double minutesInternal = (secondsInterval / 60);
		double hoursInterval = (minutesInternal / 60);
		double daysInterval = (hoursInterval / 24);
		if (interval < 50) {
			int seconds = (int)secondsInterval;
			if (seconds == 0) seconds = 1;
			return String.format("%s second%s",numbersToWords[seconds],(seconds > 1) ? "s" : "");
		} else if (minutesInternal < 20) {
			int minutes = minutesInternal;
			if (minutes == 0) minutes = 1;
			return [NSString stringWithFormat:"%@ minute%",numbersToWords[minutes],(minutes > 1) ? "s" : "" ];
		} else if (hoursInterval < 20) {
			int hours = hoursInterval;
			if (hours == 0) hours = 1;
			return [NSString stringWithFormat:"%@ hour%",numbersToWords[hours],(hours > 1) ? "s" : "" ];
		} else if (daysInterval < 6) {
			int days = daysInterval;
			return [NSString stringWithFormat:"%@ day%",numbersToWords[days],(days > 1) ? "s" : "" ];
		} else if ((daysInterval < 27)) {
			int weeks = daysInterval / 7;
			if (weeks == 0) weeks = 1;
			return [NSString stringWithFormat:"%@ week%",numbersToWords[weeks],(weeks > 1) ? "s" : "" ];
		} else {
			int months = daysInterval / 30;
			if (months == 0) months = 1;
			return [NSString stringWithFormat:"%@ month%",numbersToWords[months],(months > 1) ? "s" : "" ];
		}
	}
*/	

	public QuestionnaireContentController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		takeAssessment(false);
		super.build();
	}
	
	private PCLScore getLastPCLScore() {
		return userDb.getLastTimeseriesScore("pcl");
	}

	@Override
	public boolean dispatchContentEvent(ContentEvent event) {
		if (event.eventType == ContentEvent.Type.BACK_BUTTON) {
			if (inQuestionnaire) {
				PCLScore lastScoreObj = userDb.getLastTimeseriesScore("pcl");
				int lastScore = (lastScoreObj != null) ? lastScoreObj.score : -1;

				TreeMap<String,String> map = new TreeMap<String, String>();
				map.put("lastScore",""+lastScore);
				map.put("score","-1");
				map.put("completed","no");
				FlurryAgent.logEvent("ASSESSMENT",map);
			}
			if (stack.size() < 2) {
				return false;
			} else {
				popView();
				return true;
			}
		}
		
		return super.dispatchContentEvent(event);
	}

	public void takeAssessment(boolean force) {
		boolean tooSoon = false;
		String pclSince = "in the time since you last took this assessment";
		String pclLastTime = "just recently";
		PCLScore lastScoreObj = getLastPCLScore();
		if (lastScoreObj == null) {
			pclSince = "in the past month";
			pclLastTime = "a month ago";
		} else {
			Date now = new Date();
			Date lastScoreTime = new Date(lastScoreObj.time);
			long secondsSinceLastTime = (now.getTime() - lastScoreTime.getTime())/1000L;
			long daysSinceLastTime = ((secondsSinceLastTime / 60)/60)/24;
			if (daysSinceLastTime < 6) tooSoon = true;
			if (daysSinceLastTime < 1) {
				pclSince = "in the time since you last took this assessment";
				pclLastTime = "less than a day ago";
			} else if (daysSinceLastTime < 6) {
				int days = (int)daysSinceLastTime;
				pclSince = String.format("in the past %s day%s",numbersToWords[days],(days > 1) ? "s" : "");
				pclLastTime = String.format("%s day%s ago",numbersToWords[days],(days > 1) ? "s" : "" );
			} else if ((daysSinceLastTime < 27)) {
				int weeks = (int)(daysSinceLastTime / 7);
				if (weeks == 0) weeks = 1;
				pclSince = String.format("in the past %s week%s",numbersToWords[weeks],(weeks > 1) ? "s" : "");
				pclLastTime = String.format("%s week%s ago",numbersToWords[weeks],(weeks > 1) ? "s" : "");
			} else {
				int months = (int)(daysSinceLastTime / 30);
				if (months == 0) months = 1;
				pclSince = String.format("in the past %s month%s",numbersToWords[months],(months > 1) ? "s" : "");
				pclLastTime = String.format("%s month%s ago",numbersToWords[months],(months > 1) ? "s" : "");
			}
		}

		String pclSinceCap = pclSince.substring(0, 1).toUpperCase() +  pclSince.substring(1);

		setVariable("pclSince", pclSince);
		setVariable("pclSinceCap", pclSinceCap);
		setVariable("pclLastTime", pclLastTime);

		if (tooSoon && !force) {
			ContentViewController cvc = (ContentViewController)db.getContentForName("pclTooSoon").createContentView(this,getContext());
			cvc.addButton("Remind me after a week").setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					userDb.setSetting("pclScheduled", "week");
					(new PCLSchedulerController(getContext())).schedulePCLReminder(7*24*60*60,true,true);
					setVariable("pclScheduledWhen","one week");
					ContentViewController cvc = (ContentViewController)db.getContentForName("pclScheduled").createContentView(QuestionnaireContentController.this,getContext());
					cvc.addButton("Ok").setOnClickListener(new View.OnClickListener() {
						public void onClick(View v) {
							goBack();
							// XXX pop it
//							getNavigator().popToRoot();
						}
					});
					pushReplaceView(cvc);
				}
			});
			cvc.addButton("Take it now").setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					takeAssessment(true);
				}
			});
			if (stack.size() == 0) {
				cvc.setNavigator(this);
				stack.add(cvc);
			} else {
				pushView(cvc);
			}
			return;
		}
		
		startQuestionnaire();
	}
	
	public void startQuestionnaire() {
		PclAssessmentStartedEvent e = new PclAssessmentStartedEvent();
		e.pclAssessmentStarted = System.currentTimeMillis();
		EventLog.log(e);

		try {
			QuestionnaireHandler handler = new QuestionnaireHandler();
			QuestionnaireManager.parseQuestionaire(getContext().getAssets().open("pcl.xml"), handler);
			Questionnaire q = handler.getQuestionaire();
			player = new QuestionnairePlayer(getContext(), q) {
				public String getGlobalVariable(String key) {
					Object val = getVariable(key);
					if (val != null) return val.toString();
					return super.getGlobalVariable(key);
				};
			};
			player.setQuestionnaireListener(this);
			inQuestionnaire = true;
			player.play();
		} catch (Exception exc) {
			exc.printStackTrace();
		}
	}
	/*
	public void seeHistory() {
		List<PCLScore> history = userDb.getPCLScores();
		if (history.size() == 0) {
			ContentViewController cvc = (ContentViewController)db.getContentForName("pclNoHistory").createContentView(getContext());
			pushView(cvc);
			return;
		}

		PCLHistoryController historyView = new PCLHistoryController(getContext(), history);
		pushView(historyView);
	}
*/
	
	@Override
	public void onQuestionnaireCompleted(QuestionnairePlayer player) {
		inQuestionnaire = false;
		
		Hashtable answers = player.getAnswers();
		int totalScore = 0;
		for (Object o : answers.entrySet()) {
			Map.Entry entry = (Map.Entry)o;
			String str = SurveyUtil.answerToString(entry.getValue());
			int val = Integer.parseInt(str);
			totalScore += val;
		}

		PCLScore lastScoreObj = userDb.getLastTimeseriesScore("pcl");
		int lastScore = (lastScoreObj != null) ? lastScoreObj.score : -1;

		Date now = new Date();
		userDb.addTimeseriesScore("pcl",now.getTime(), totalScore);
		
		TreeMap<String,String> map = new TreeMap<String, String>();
		map.put("lastScore",""+lastScore);
		map.put("score",""+totalScore);
		map.put("completed","yes");
		FlurryAgent.logEvent("ASSESSMENT",map);
		
		{
			PclAssessmentCompletedEvent e = new PclAssessmentCompletedEvent();
			e.pclAssessmentCompleted = 1;
			e.pclAssessmentCompletedFinalScore = totalScore;
			EventLog.log(e);
		}
		
		if (lastScoreObj != null) {
			TimeElapsedBetweenPCLAssessmentsEvent e = new TimeElapsedBetweenPCLAssessmentsEvent();
			e.timeElapsedBetweenPCLAssessments = now.getTime() - lastScoreObj.time;
			EventLog.log(e);
		}

		player = null;
		
		String absStr = null;
		String relStr = null;

		if (totalScore >= 50) {
			absStr = "High";
		} else if (totalScore >= 30) {
			absStr = "Mid";
		} else if (totalScore == 17) {
			absStr = "Bottom";
		} else {
			absStr = "Low";
		}
		
		if (lastScore == -1) {
			relStr = "First";
		} else if (totalScore > lastScore) {
			relStr = "Higher";
		} else if (totalScore == lastScore) {
			relStr = "Same";
		} else {
			relStr = "Lower";
		}
		
		String pclResultName = String.format("pcl%s%s",absStr,relStr);
		
		ContentViewController cvc = (ContentViewController)db.getContentForName(pclResultName).createContentView(QuestionnaireContentController.this,getContext());

		String currentPCLScheduling = userDb.getSetting("pclScheduled");
		if ((currentPCLScheduling == null) || currentPCLScheduling.equals("") || currentPCLScheduling.equals("none")) {
			cvc.addButton("Next").setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					ContentViewController cvc = (ContentViewController)db.getContentForName("pclSchedulePrompt").createContentView(QuestionnaireContentController.this,getContext());
					cvc.addButton("No, thanks").setOnClickListener(new View.OnClickListener() {
						public void onClick(View v) {
							navigateToContentName("trackHistory");
						}
					});
					cvc.addButton("Schedule the reminder").setOnClickListener(new View.OnClickListener() {
						public void onClick(View v) {
							userDb.setSetting("pclScheduled", "month");
							(new PCLSchedulerController(getContext())).schedulePCLReminder(30*24*60*60,true,true);
							setVariable("pclScheduledWhen","one month");
							ContentViewController cvc = (ContentViewController)db.getContentForName("pclScheduled").createContentView(QuestionnaireContentController.this,getContext());
							cvc.addButton("See Assessment History").setOnClickListener(new View.OnClickListener() {
								public void onClick(View v) {
									navigateToContentName("trackHistory");
								}
							});
							pushReplaceView(cvc);
						}
					});
					pushReplaceView(cvc);
				}
			});
		} else {
			(new PCLSchedulerController(getContext())).schedulePCLReminder(currentPCLScheduling);
			cvc.addButton("See Symptom History").setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					navigateToContentName("trackHistory");
				}
			});
		}
		pushReplaceView(cvc);
	}
	
	@Override
	public void onQuestionnaireDeferred(QuestionnairePlayer player) {
		{
			PclAssessmentAbortedEvent e = new PclAssessmentAbortedEvent();
			e.pclAssessmentAbortedTimestamp = System.currentTimeMillis();
			EventLog.log(e);
		}
		
		{
			PclAssessmentCompletedEvent e = new PclAssessmentCompletedEvent();
			e.pclAssessmentCompleted = 0;
			e.pclAssessmentCompletedFinalScore = -1;
			EventLog.log(e);
		}
	}

	@Override
	public void onQuestionnaireSkipped(QuestionnairePlayer player) {
	}

	@Override
	public void onShowScreen(QuestionnairePlayer player, ContentViewControllerBase screen) {
		if (stack.size() == 0) {
			screen.setNavigator(this);
			stack.add(screen);
		} else if (stack.size() > 1) {
			pushReplaceView(screen);
		} else {
			pushView(screen);
		}
	}
}
