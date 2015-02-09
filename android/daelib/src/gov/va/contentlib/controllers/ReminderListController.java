package gov.va.contentlib.controllers;

import java.util.List;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.util.EventScheduler;
import gov.va.contentlib.views.ContentList;
import gov.va.contentlib.views.InlineList;
import gov.va.contentlib.views.ReminderList;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.View;
import android.widget.AdapterView;

public class ReminderListController extends ContentListViewController {

	public ReminderListController(Context ctx) {
		super(ctx);
	}

	@Override
	public InlineList createList() {
		final EventScheduler scheduler = EventScheduler.create(ReminderListController.this);
		final ReminderList list = new ReminderList(this, content.getBoolean("dueOnly"));
		list.setOnItemClickListener(new ReminderList.OnItemClickListener<Reminder>() {
			public void onItemClick(int i, View v, final Reminder reminder) {
			    if (reminder.type.equals("tool")) {
			    	long now = System.currentTimeMillis();
			        if ((reminder.time - now) > 5*60*1000L) {
			    		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
			    		builder.setTitle("Not Time Yet");
			    		builder.setMessage("It isn't time yet to use this tool.  Do you want to do it now anyway, and clear this reminder?");
			    		builder.setNegativeButton("Never mind", null);
			    		builder.setNeutralButton("Clear reminder", new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
								list.removeItem(reminder);
								userDb.deleteReminder(reminder);
							}
						});
			    		builder.setPositiveButton("Use the tool", new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
					        	navigateToContent(db.getContentForUniqueID(reminder.reference));
								list.removeItem(reminder);
					        	userDb.deleteReminder(reminder);
							}
						});
			    		builder.show();
			        } else {
						list.removeItem(reminder);
			        	userDb.deleteReminder(reminder);
			        	navigateToContent(db.getContentForUniqueID(reminder.reference));
			        }
			    } else if (reminder.type.equals("appt")) {
		    		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
		    		builder.setTitle("Scheduled Activity");
		    		builder.setNegativeButton("Never mind", null);
		    		builder.setNeutralButton("Clear reminder", new DialogInterface.OnClickListener() {
						public void onClick(DialogInterface dialog, int which) {
							list.removeItem(reminder);
							userDb.deleteReminder(reminder);
						}
					});
		    		if (scheduler.canViewReminderEvent()) {
			    		builder.setMessage("Would you like to view the calendar event, or clear this reminder?");
		    			builder.setPositiveButton("View event", new DialogInterface.OnClickListener() {
		    				public void onClick(DialogInterface dialog, int which) {
		    					EventScheduler scheduler = EventScheduler.create(ReminderListController.this);
		    					scheduler.viewReminderEvent(reminder);
		    				}
		    			});
		    		} else {
			    		builder.setMessage("Would you like to clear this reminder?");
		    		}
		    		builder.show();

			    }
			}
		});
		return list;
	}
	
	public void refreshContent() {
		((ReminderList)list).refreshList();
	}



}
