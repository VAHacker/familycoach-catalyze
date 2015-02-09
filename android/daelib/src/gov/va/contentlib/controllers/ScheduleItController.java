package gov.va.contentlib.controllers;

import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.LoggingButton;

import java.util.Calendar;

import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.widget.LinearLayout;

public class ScheduleItController extends SubsequentExerciseController {

	ContactList contactList;
	
	public ScheduleItController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		contactList = new ContactList(this, false, false);
		clientView.addView(contactList);
		contactList.bindToVariable("socialActivitySummaryContactList", true);

		final String summary = getVariableAsString("socialActivitySummary");
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText("Add it to my calendar for later");
		beginExerciseButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Calendar cal = Calendar.getInstance();              
				Intent intent = new Intent(Intent.ACTION_EDIT);
				intent.setType("vnd.android.cursor.item/event");
				cal.roll(Calendar.HOUR, 2);
				cal.set(Calendar.MINUTE, 0);
				cal.set(Calendar.SECOND, 0);
				cal.set(Calendar.MILLISECOND, 0);
				intent.putExtra("beginTime", cal.getTimeInMillis());
				intent.putExtra("allDay", false);
				intent.putExtra("endTime", cal.getTimeInMillis()+60*60*1000);
				intent.putExtra("title", summary);
				intent.putExtra("description", summary);
				intent.putExtra("hasAlarm", 1);
				getContext().startActivity(intent);
			}
		});

//		lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
//		lp.setMargins(20, 20, 20, 20);
		clientView.addView(beginExerciseButton);
	}
}
