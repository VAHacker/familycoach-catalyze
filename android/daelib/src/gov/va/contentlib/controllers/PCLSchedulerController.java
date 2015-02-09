package gov.va.contentlib.controllers;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.PCLScore;

import java.util.List;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PclReminderScheduledEvent;
import com.openmhealth.ohmage.core.EventLog;

import android.app.AlarmManager;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;

public class PCLSchedulerController extends ContentViewControllerBase {

	List<Content> children;
	boolean needsReset = false;

	public PCLSchedulerController(Context ctx) {
		super(ctx);
	}
	
	public void schedulePCLReminder(double secondsFromLast, boolean before, boolean repeat) {
		String ns = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager = (NotificationManager) getContext().getSystemService(ns);
		mNotificationManager.cancel(1);
		
		long when = System.currentTimeMillis();
		PCLScore lastScoreObj = userDb.getLastTimeseriesScore("pcl");
		if (lastScoreObj != null) when = lastScoreObj.time;
		
		long interval = (long)(secondsFromLast * 1000L);
		when += interval;
		
		AlarmManager am = (AlarmManager)getContext().getSystemService(Context.ALARM_SERVICE);
		Intent reminderIntent = Util.getAlarmIntent(getContext());
		PendingIntent reminderPendingIntent = PendingIntent.getBroadcast(getContext().getApplicationContext(), 0, reminderIntent, 0);
		am.cancel(reminderPendingIntent);
		am.set(AlarmManager.RTC_WAKEUP, when, reminderPendingIntent);
		
		PclReminderScheduledEvent e = new PclReminderScheduledEvent();
		e.pclReminderScheduledTimestamp = when;
		EventLog.log(e);
	}
	
	public String getPCLReminderSchedule() {
		return userDb.getSetting("pclScheduled");
	}

	public void schedulePCLReminder(String interval) {
		userDb.setSetting("pclScheduled", interval);
		
		if (interval.equals("none")) {
			// Cancel any notifications
			String ns = Context.NOTIFICATION_SERVICE;
			NotificationManager mNotificationManager = (NotificationManager) getContext().getSystemService(ns);
			mNotificationManager.cancel(1);
			AlarmManager am = (AlarmManager)getContext().getSystemService(Context.ALARM_SERVICE);

            Intent reminderIntent = Util.getAlarmIntent(getContext());
			PendingIntent reminderPendingIntent = PendingIntent.getBroadcast(getContext().getApplicationContext(), 0, reminderIntent, 0);
			am.cancel(reminderPendingIntent);

			PclReminderScheduledEvent e = new PclReminderScheduledEvent();
			e.pclReminderScheduledTimestamp = 0;
			EventLog.log(e);
		} else {
			PCLScore lastScoreObj = userDb.getLastTimeseriesScore("pcl");
			boolean before = (lastScoreObj != null);
			if (interval.equals("minute")) {
				schedulePCLReminder(60, before, true);
			} else if (interval.equals("week")) {
				schedulePCLReminder(7*24*60*60, before, true);
			} else if (interval.equals("month")) {
				schedulePCLReminder(30*24*60*60, before, true);
			} else if (interval.equals("twoweek")) {
				schedulePCLReminder(14*24*60*60, before, true);
			} else if (interval.equals("threemonth")) {
				schedulePCLReminder(90*24*60*60, before, true);
			}
		}
	}


	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();

		children = getContent().getChildren();
		final RadioGroup choicesView = new RadioGroup(getContext());
		choicesView.setOrientation(LinearLayout.VERTICAL);

		int id = 0;
		for (Content c : children) {
			RadioButton radio = new RadioButton(getContext());
			radio.setText(c.getDisplayName());
			radio.setTag(c.getName());
			radio.setId(id+2000);
			if (c.getName().equals(getPCLReminderSchedule())) {
				radio.setChecked(true);
			}
			choicesView.addView(radio);
			id++;
		}

		choicesView.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
			@Override
			public void onCheckedChanged(RadioGroup group, int checkedId) {
				RadioButton radio = (RadioButton)group.findViewById(checkedId);
				String value = (String)radio.getTag();
				schedulePCLReminder(value);
			}
		});

		clientView.addView(choicesView);
	}
}
