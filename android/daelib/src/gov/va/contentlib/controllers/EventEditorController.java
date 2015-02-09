package gov.va.contentlib.controllers;

import java.text.DateFormat;
import java.util.Calendar;
import java.util.Date;

import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.util.CalendarEventScheduler;
import gov.va.contentlib.util.EventScheduler;
import gov.va.daelib.R;
import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.provider.CalendarContract.Events;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.GridLayout;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.widget.TimePicker;

public class EventEditorController extends ContentViewControllerBase {

	String eventName;
	String eventType;
	String reference;
	Calendar startCal;
	Calendar endCal;

	boolean createEvent = true;
	EventScheduler scheduler;
	EditText nameField;
	TextView dateField;
	TextView startTimeField,endTimeField;
	DateFormat tf = DateFormat.getTimeInstance(DateFormat.SHORT);
	DateFormat df = DateFormat.getDateInstance(DateFormat.SHORT);
	
	public EventEditorController(Context ctx) {
		super(ctx);
		scheduler = EventScheduler.create(this);
		startCal = Calendar.getInstance();
		startCal.roll(Calendar.DATE, 1);
		endCal = (Calendar)startCal.clone();
		endCal.roll(Calendar.HOUR_OF_DAY, 1);
	}
	
	public void updateFields() {
		startTimeField.setText(tf.format(startCal.getTime()));
		endTimeField.setText(tf.format(endCal.getTime()));
		dateField.setText(df.format(startCal.getTime()));
	}
	
	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		
		LayoutInflater li = LayoutInflater.from(getContext());
		View v = li.inflate(R.layout.event_editor, clientView, false);
		setDefaultChildPadding(v);

		//RelativeLayout layout = new RelativeLayout(getContext());
		clientView.addView(v);
		
		nameField = (EditText)clientView.findViewById(R.id.eventName);
		dateField = (TextView)clientView.findViewById(R.id.datePicker);
		startTimeField = (TextView)clientView.findViewById(R.id.startTimePicker);
		endTimeField = (TextView)clientView.findViewById(R.id.endTimePicker);
		
		if (eventName != null) nameField.setText(eventName);
		updateFields();

		RelativeLayout.LayoutParams p;
		p = new RelativeLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		p.addRule(RelativeLayout.ALIGN_PARENT_TOP, 1);
		p.addRule(RelativeLayout.ALIGN_PARENT_LEFT, 1);
		
		startTimeField.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				TimePickerDialog dialog = new TimePickerDialog(getContext(), new TimePickerDialog.OnTimeSetListener() {
					public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
						startCal.set(Calendar.HOUR_OF_DAY, hourOfDay);
						startCal.set(Calendar.MINUTE, minute);
						updateFields();
					}
				}, startCal.get(Calendar.HOUR_OF_DAY), startCal.get(Calendar. MINUTE), false);
				dialog.show();
			}
		});

		endTimeField.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				TimePickerDialog dialog = new TimePickerDialog(getContext(), new TimePickerDialog.OnTimeSetListener() {
					public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
						endCal.set(Calendar.HOUR_OF_DAY, hourOfDay);
						endCal.set(Calendar.MINUTE, minute);
						updateFields();
					}
				}, endCal.get(Calendar.HOUR_OF_DAY), endCal.get(Calendar. MINUTE), false);
				dialog.show();
			}
		});

		dateField.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				DatePickerDialog dialog = new DatePickerDialog(getContext(), new DatePickerDialog.OnDateSetListener() {
					@Override
					public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
						startCal.set(year, monthOfYear, dayOfMonth);
						endCal.set(year, monthOfYear, dayOfMonth);
						updateFields();
					}
				},startCal.get(Calendar.YEAR),startCal.get(Calendar.MONTH),startCal.get(Calendar.DAY_OF_MONTH));
				dialog.show();
			}
		});

		addButton("Save").setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				saveEvent();
			}
		});
	}
	
	public void saveEvent() {
		scheduler.eventName = nameField.getText().toString();
		scheduler.eventTime = startCal.getTime();
		scheduler.eventType = eventType;
		scheduler.createEvent = createEvent;
		scheduler.reference = reference;
		scheduler.duration = endCal.getTimeInMillis() - startCal.getTimeInMillis();
		scheduler.schedule();
	}
}
