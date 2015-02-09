package gov.va.contentlib.util;

import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.controllers.ContentViewControllerBase;

import java.util.Calendar;
import java.util.Date;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;

public class EventScheduler {

	public ContentViewControllerBase controller;
	public String eventName;
	public Date eventTime;
	public String eventType;
	public long duration;
	public String description;
	public String reference;
	public Reminder reminder;
	public boolean createEvent = true;
	
	public EventScheduler(ContentViewControllerBase controller) {
		this.controller = controller;
		Calendar eventCal = Calendar.getInstance();
		eventCal.roll(Calendar.DATE, 1);
		eventTime = eventCal.getTime();
		duration = 60*60*1000;
	}
	
	public void schedule() {
		reminder = new Reminder(eventTime.getTime(), eventType, eventName, reference);
		controller.getUserDB().addReminder(reminder);
		controller.goBack(true);
	}
	
	public boolean canViewReminderEvent() {
		return false;
	}
	
	public void viewReminderEvent(Reminder reminder) {
	}
	
	static public EventScheduler create(ContentViewControllerBase controller) {
		final int sdkVersion = Build.VERSION.SDK_INT;
		EventScheduler scheduler = null;
	    if (sdkVersion < Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
	    	scheduler = new EventScheduler(controller);
	    } else {
	    	scheduler = new CalendarEventScheduler(controller);
	    }
	    return scheduler;
	}
}
