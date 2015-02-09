package gov.va.contentlib.controllers;

import java.util.Calendar;

import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.FrameLayout.LayoutParams;

public class ScheduleItController extends SubsequentExerciseController {

	ContactList contactList;
	
	public ScheduleItController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		contactList = new ContactList(this, false);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(contactList,lp);
		contactList.bindToVariable("socialActivitySummaryContactList", true);

		final String summary = getNavigator().getVariable("socialActivitySummary");
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText("Add it to my calendar for later");
		beginExerciseButton.setTextSize(17);
		beginExerciseButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Calendar cal = Calendar.getInstance();              
				Intent intent = new Intent(Intent.ACTION_EDIT);
				intent.setType("vnd.android.cursor.item/event");
				cal.set(Calendar.HOUR, cal.get(Calendar.HOUR+2));
				cal.set(Calendar.MINUTE, 0);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MILLISECOND, 0);
				intent.putExtra("beginTime", cal.getTimeInMillis());
				intent.putExtra("allDay", false);
				intent.putExtra("endTime", cal.getTimeInMillis()+60*60*1000);
				intent.putExtra("title", summary);
				intent.putExtra("description", summary);
				intent.putExtra("hasAlarm", 1);
				getNavigator().startActivity(intent);
			}
		});

		lp = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		lp.setMargins(20, 20, 20, 20);
		clientView.addView(beginExerciseButton,lp);
		
		addButton("Done", ManageNavigationController.BUTTON_DONE_ALL);
	}
}
