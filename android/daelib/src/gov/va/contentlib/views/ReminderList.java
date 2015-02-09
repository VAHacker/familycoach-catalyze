package gov.va.contentlib.views;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import android.graphics.drawable.Drawable;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.controllers.ContentViewControllerBase;

public class ReminderList extends InlineList<Reminder> {

	final boolean dueOnly;
	Calendar cal = Calendar.getInstance();
	DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
	DateFormat tf = DateFormat.getTimeInstance(DateFormat.SHORT);

	public ReminderList(ContentViewControllerBase cv, boolean dueOnly) {
		super(cv);
		this.dueOnly = dueOnly;
		refreshList();
	}
	
	public void refreshList() {
		UserDBHelper userDb = UserDBHelper.instance(contentController.getContext());
		setItems(dueOnly ? userDb.getDueReminders() : userDb.getAllReminders());
	}
	
	@Override
	public String labelForItem(Reminder item) {
		if (item.type.equals("tool")) return "Use Tool";
		if (item.type.equals("appt")) return "Appointment";
		if (item.type.equals("assess")) return "Take Assessment";
		return null;
	}
	
	@Override
	public String sublabelForItem(Reminder item) {
		return item.displayName;
	}

	@Override
	public String detailLabelForItem(Reminder item) {
		long now = System.currentTimeMillis();
		cal.setTimeInMillis(now);
		int todaysDate = cal.get(Calendar.DATE);
		cal.setTimeInMillis(item.time);
		int targetDate = cal.get(Calendar.DATE);
		Date d = cal.getTime();
		
		if ((now + 5*60*1000L) > item.time) {
			return "Due";
		} else if ((targetDate == todaysDate) && (now+24*60*60*1000L > item.time)) {
			return tf.format(d);
		} else {
			return df.format(d);
		}
	}

}
