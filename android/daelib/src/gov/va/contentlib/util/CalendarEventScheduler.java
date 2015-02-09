package gov.va.contentlib.util;

import java.util.Calendar;
import java.util.List;
import java.util.TimeZone;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract.Calendars;
import android.provider.CalendarContract.Events;
import android.util.Log;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.activities.CalendarChoiceActivity;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.controllers.ContentViewControllerBase;

@TargetApi(14)
public class CalendarEventScheduler extends EventScheduler {

	public CalendarEventScheduler(ContentViewControllerBase controller) {
		super(controller);
	}
	
	public void doCalendarSchedule() {
		String calIDStr = controller.getUserDB().getSetting("eventCalendar");
		long calID = Long.parseLong(calIDStr);

		long startMillis = eventTime.getTime();
		long endMillis = eventTime.getTime() + duration;

		ContentValues values = new ContentValues();
		values.put(Events.DTSTART, startMillis);
		values.put(Events.DTEND, endMillis);
		values.put(Events.TITLE, eventName);
		values.put(Events.ACCESS_LEVEL, Events.ACCESS_PRIVATE);
		if (description != null) values.put(Events.DESCRIPTION, description);
		values.put(Events.CALENDAR_ID, calID);
		values.put(Events.EVENT_TIMEZONE, TimeZone.getDefault().getID());
		Uri uri = controller.getContext().getContentResolver().insert(Events.CONTENT_URI, values);
		reference = uri.toString();
		
		CalendarEventScheduler.super.schedule();
	}
	
	public boolean canViewReminderEvent() {
		return true;
	}
	
	public void viewReminderEvent(Reminder reminder) {
		Uri uri = Uri.parse(reminder.reference);
		long startTime = reminder.time;
		long endTime = reminder.time + 60*60*1000;
		Cursor c = controller.getContext().getContentResolver().query(uri, null, null, null, null);
		if (c.moveToFirst()) {
			startTime = c.getLong(c.getColumnIndex(Events.DTSTART));
			endTime = c.getLong(c.getColumnIndex(Events.DTEND));
		}
		c.close();
		Intent intent = new Intent(Intent.ACTION_VIEW).setData(uri);
		intent.putExtra("beginTime", startTime);
		intent.putExtra("endTime", endTime);
		controller.startActivity(intent);
	}

	public void schedule() {
		if (!createEvent) {
			super.schedule();
			return;
		}
		
		String calIDStr = controller.getUserDB().getSetting("eventCalendar");
		if (calIDStr != null) {
			Uri calUri = ContentUris.withAppendedId(Calendars.CONTENT_URI, Long.parseLong(calIDStr));
			ContentResolver cr = controller.getContext().getContentResolver();
			Cursor cur = cr.query(calUri, null, null, null, null);
			boolean exists = cur.moveToFirst();
			cur.close();
			
			if (exists) {
				doCalendarSchedule();
				return;
			}
		}

		controller.startActivityForResult(new Intent(controller.getContext(), CalendarChoiceActivity.class), new ContentActivity.ActivityResultListener() {
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
				if (resultCode == Activity.RESULT_OK) {
					List<String> segments = data.getData().getPathSegments();
					String id = segments.get(segments.size()-1);
					controller.getUserDB().setSetting("eventCalendar",id);
					doCalendarSchedule();
				}
			}
		});
	}
}
