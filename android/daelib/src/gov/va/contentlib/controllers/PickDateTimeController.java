package gov.va.contentlib.controllers;

import android.app.AlarmManager;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.Dialog;
import android.app.Fragment;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.TimePickerDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.text.Editable;
import android.text.TextWatcher;
import android.text.format.DateFormat;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.NumberPicker;
import android.widget.TimePicker;

import com.actionbarsherlock.app.SherlockDialogFragment;
import com.actionbarsherlock.internal.widget.IcsLinearLayout;

import java.util.Calendar;
import java.util.Date;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.InlineList;
import gov.va.daelib.R;

/**
 * Created by geh on 2/6/14.
 */
public class PickDateTimeController extends ContentViewController {

    AlarmManager am;
    Button dateTimeDisplay;
    ImageButton alarmButton;
    String selectionVariable;
    String alarmDestination;
    String alarmAction;
    String alarmBody;
    String alarmInfo;
    String defaultValue;
    String alarmSelectionVariable;
    boolean useDuration;
    boolean dateOnly;
    boolean timeOnly;
    boolean futureOnly;
    Content itemContent;

    public PickDateTimeController(Context c) {
        super(c);
    }

    public class DurationPickerFragment extends SherlockDialogFragment {

        public class DurationPickerDialog extends AlertDialog {
            int hours;
            int minutes;

            public void set() {
                setDurationValue(hours * (1000L * 60 * 60) + minutes * (1000L * 60));
            }

            public DurationPickerDialog(Context ctx) {
                super(ctx);

                LinearLayout.LayoutParams lp;
                LinearLayout ll = new LinearLayout(getContext());
                ll.setOrientation(LinearLayout.HORIZONTAL);
                ll.setGravity(Gravity.CENTER_VERTICAL | Gravity.FILL_HORIZONTAL);

                DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
                int margin =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, dm);

                NumberPicker hourPicker = new NumberPicker(ctx);
                hourPicker.setMinValue(0);
                hourPicker.setMaxValue(23);
                String[] hourLabels = new String[24];
                for (int i=0;i<24;i++) {
                    String label = "" + i + " hours";
                    if (i == 1) label = "" + i + " hour";
                    hourLabels[i] = label;
                }
                hourPicker.setDisplayedValues(hourLabels);
                /*
                hourPicker.setFormatter(new NumberPicker.Formatter() {
                    @Override
                    public String format(int value) {
                        if (value == 1) return "" + value + " hour";
                        return "" + value + " hours";
                    }
                });
                */
                hourPicker.setOnValueChangedListener(new NumberPicker.OnValueChangeListener() {
                    @Override
                    public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
                        hours = newVal;
                        set();
                    }
                });
                lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
                lp.setMargins(margin,0,margin,0);
                lp.weight = 1;
                ll.addView(hourPicker, lp);

                NumberPicker minutePicker = new NumberPicker(ctx);
                minutePicker.setMinValue(0);
                minutePicker.setMaxValue(59);
                String[] minuteLabels = new String[60];
                for (int i=0;i<60;i++) {
                    String label = "" + i + " minutes";
                    if (i == 1) label = "" + i + " minute";
                    minuteLabels[i] = label;
                }
                minutePicker.setDisplayedValues(minuteLabels);
                /*
                minutePicker.setFormatter(new NumberPicker.Formatter() {
                    @Override
                    public String format(int value) {
                        if (value == 1) return "" + value + " minute";
                        return "" + value + " minutes";
                    }
                });
                */
                minutePicker.setOnValueChangedListener(new NumberPicker.OnValueChangeListener() {
                    @Override
                    public void onValueChange(NumberPicker picker, int oldVal, int newVal) {
                        minutes = newVal;
                        set();
                    }
                });
                lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.MATCH_PARENT);
                lp.setMargins(0,0,margin,0);
                lp.weight = 1;
                ll.addView(minutePicker, lp);

                Long v = (Long)getVariable(selectionVariable);
                if (v == null) v = (1000L*60);
                hours = (int)(v / (1000*60*60));
                minutes = ((int)(v % (1000*60*60))) / (1000*60);
                set();

                hourPicker.setValue(hours);
                minutePicker.setValue(minutes);

                setTitle("Set duration");
                setView(ll);
            }
        }

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current time as the default values for the picker

            final DurationPickerDialog d = new DurationPickerDialog(getContext());
            d.setButton(DialogInterface.BUTTON_POSITIVE, "Done", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    d.dismiss();
                }
            });

            return d;
        }
    }

    public class DateTimePickerFragment extends SherlockDialogFragment
            implements TimePicker.OnTimeChangedListener, DatePicker.OnDateChangedListener {

        Calendar dateTime;

        public class DateTimePickerDialog extends AlertDialog {
            public DateTimePickerDialog(Context ctx) {
                super(ctx);

                dateTime = getCalendarValue();

                int year = dateTime.get(Calendar.YEAR);
                int monthOfYear = dateTime.get(Calendar.MONTH);
                int dayOfMonth = dateTime.get(Calendar.DAY_OF_MONTH);
                int hour = dateTime.get(Calendar.HOUR_OF_DAY);
                int minute = dateTime.get(Calendar.MINUTE);

                LinearLayout ll = new LinearLayout(getContext());
                ll.setOrientation(LinearLayout.VERTICAL);

                TimePicker timePicker = new TimePicker(getContext());
                timePicker.setCurrentHour(hour);
                timePicker.setCurrentMinute(minute);
                timePicker.setOnTimeChangedListener(DateTimePickerFragment.this);
                ll.addView(timePicker, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

                DatePicker datePicker = new DatePicker(getContext());
                datePicker.setCalendarViewShown(false);
                datePicker.init(year, monthOfYear, dayOfMonth, DateTimePickerFragment.this);
                ll.addView(datePicker, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

                setTitle("Set date and time");
                setView(ll);
            }
        }

        @Override
        public void onDismiss(DialogInterface dialog) {
            super.onDismiss(dialog);
            setCalendarValue(dateTime);
        }

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current time as the default values for the picker

            final DateTimePickerDialog d = new DateTimePickerDialog(getContext());
            d.setButton(DialogInterface.BUTTON_POSITIVE, "Done", new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    d.dismiss();
                }
            });

            return d;
        }

        @Override
        public void onDateChanged(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
            dateTime.set(Calendar.YEAR, year);
            dateTime.set(Calendar.MONTH, monthOfYear);
            dateTime.set(Calendar.DAY_OF_MONTH, dayOfMonth);
        }

        @Override
        public void onTimeChanged(TimePicker view, int hourOfDay, int minute) {
            dateTime.set(Calendar.HOUR_OF_DAY, hourOfDay);
            dateTime.set(Calendar.MINUTE, minute);
        }
    }

    public class TimePickerFragment extends SherlockDialogFragment
            implements TimePickerDialog.OnTimeSetListener {

        Calendar dateTime;

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current time as the default values for the picker
            dateTime = getCalendarValue();
            int hour = dateTime.get(Calendar.HOUR_OF_DAY);
            int minute = dateTime.get(Calendar.MINUTE);

            // Create a new instance of TimePickerDialog and return it
            return new TimePickerDialog(getActivity(), this, hour, minute,
                    DateFormat.is24HourFormat(getActivity()));
        }

        @Override
        public void onDismiss(DialogInterface dialog) {
            super.onDismiss(dialog);
            setCalendarValue(dateTime);
        }

        public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
            dateTime.set(Calendar.HOUR_OF_DAY, hourOfDay);
            dateTime.set(Calendar.MINUTE, minute);
        }
    }

    public class DatePickerFragment extends SherlockDialogFragment
            implements DatePickerDialog.OnDateSetListener {

        Calendar dateTime;

        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {
            // Use the current date as the default date in the picker
            dateTime = getCalendarValue();
            int year = dateTime.get(Calendar.YEAR);
            int month = dateTime.get(Calendar.MONTH);
            int day = dateTime.get(Calendar.DAY_OF_MONTH);

            // Create a new instance of DatePickerDialog and return it
            return new DatePickerDialog(getActivity(), this, year, month, day);
        }

        @Override
        public void onDismiss(DialogInterface dialog) {
            super.onDismiss(dialog);
            setCalendarValue(dateTime);
        }

        public void onDateSet(DatePicker view, int year, int month, int day) {
            dateTime.set(Calendar.YEAR, year);
            dateTime.set(Calendar.MONTH, month);
            dateTime.set(Calendar.DAY_OF_MONTH, day);
        }
    }

    public Calendar getCalendarValue() {
        final Calendar c = Calendar.getInstance();
        Object value = getVariable(selectionVariable);
        if ((value != null) && (value instanceof Number) && (((Number)value).longValue() != 0)) {
            long millis = ((Number)value).longValue();
            c.setTimeInMillis(millis);
        }
        return c;
    }

    public void setDurationValue(long dur) {
        setVariable(selectionVariable,dur);
        updateButtonText();
    }

    public void setCalendarValue(Calendar c) {
        long val = c.getTimeInMillis();
        setVariable(selectionVariable,val);
        updateButtonText();
        if (alarmSelectionVariable != null) {
            String alarmID = (String)getVariable(alarmSelectionVariable);
            if (alarmID != null) {
                setAlarm();
            }
        }
    }

    public void updateButtonText() {
        Object value = getVariable(selectionVariable);
        if ((value == null) || !(value instanceof Number) || (((Number)value).longValue() == 0)) {
            dateTimeDisplay.setText(itemContent.getDisplayName());
        } else {
            if (useDuration) {
                Number duration = (Number)value;
                long d = duration.longValue();
                int hours = (int)(d / (1000*60*60));
                int minutes = ((int)(d % (1000*60*60))) / (1000*60);
                if (hours >= 2) {
                    dateTimeDisplay.setText(String.format("%d hours %d minutes", hours, minutes));
                } else if (hours == 1) {
                    dateTimeDisplay.setText(String.format("1 hour %d minutes",minutes));
                } else {
                    dateTimeDisplay.setText(String.format("%d minutes",minutes));
                }
            } else {
                Number duration = (Number)value;
                long l = duration.longValue();
                Calendar cal = Calendar.getInstance();
                cal.setTimeInMillis(l);
                Date d = cal.getTime();

                String str;
                java.text.DateFormat format;
                if (dateOnly) {
                    format = DateFormat.getMediumDateFormat(getContext());
                    str = format.format(d);
                } else if (timeOnly) {
                    format = DateFormat.getTimeFormat(getContext());
                    str = format.format(d);
                } else {
                    format = DateFormat.getMediumDateFormat(getContext());
                    str = format.format(d);
                    format = DateFormat.getTimeFormat(getContext());
                    str = str+", "+format.format(d);
                }
                dateTimeDisplay.setText(str);
            }
        }

    }

    public void unsetAlarm() {
        setVariable(alarmSelectionVariable,null);
        alarmButton.setImageResource(R.drawable.alarmclock);
    }

    public void setAlarm() {
        Long recordID = (Long)getVariable("recordID");
        String alarmID = "entity"+recordID;
        setVariable(alarmSelectionVariable,alarmID);

        Intent alarmIntent = Util.getAlarmIntent(getContext());
        alarmIntent.setData(Uri.parse("alarm:" + alarmID));
        alarmIntent.putExtra("alarmName", alarmID);
        alarmIntent.putExtra("alarmDestination", alarmDestination);
        alarmIntent.putExtra("alarmAction", alarmAction);
        alarmIntent.putExtra("alarmBody",alarmBody);

        PendingIntent alarmPendingIntent = PendingIntent.getBroadcast(getContext().getApplicationContext(), 0, alarmIntent, 0);
        am.cancel(alarmPendingIntent);

        NotificationManager nm = (NotificationManager)getContext().getSystemService(Context.NOTIFICATION_SERVICE);
        nm.cancel(alarmID,0);

        Calendar cal = getCalendarValue();
        long when = cal.getTimeInMillis();
        am.set(AlarmManager.RTC_WAKEUP, when, alarmPendingIntent);

        alarmButton.setImageResource(R.drawable.alarmclock_highlighted);
    }

    @Override
    public void buildClientViewFromContent() {
        am = (AlarmManager)getContext().getSystemService(Context.ALARM_SERVICE);

        super.buildClientViewFromContent();

        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();

        Content c = getContent();
        alarmDestination = c.getStringAttribute("alarmDestination");
        alarmAction = c.getStringAttribute("alarmAction");
        alarmBody = c.getStringAttribute("alarmBody");
        alarmInfo = c.getStringAttribute("alarmInfo");
        selectionVariable = c.getStringAttribute("selectionVariable");
        alarmSelectionVariable = c.getStringAttribute("alarmSelectionVariable");
        defaultValue = c.getStringAttribute("defaultValue");
        itemContent = c.getChildByName("@item");
        useDuration = c.getBoolean("duration");
        dateOnly = c.getBoolean("dateOnly");
        timeOnly = c.getBoolean("timeOnly");
        futureOnly = c.getBoolean("futureOnly");

        int dip5 =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 7, dm);

        IcsLinearLayout h = new IcsLinearLayout(getContext(),null);
        h.setOrientation(LinearLayout.HORIZONTAL);
        h.setShowDividers(LinearLayout.SHOW_DIVIDER_MIDDLE);
        h.setDividerPadding(0);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.gravity = Gravity.FILL_HORIZONTAL;
        int margin =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, dm);
        lp.setMargins(margin,0,margin,0);
        h.setLayoutParams(lp);

        dateTimeDisplay = new Button(getContext());
        updateButtonText();
        lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.weight = 4;
        lp.setMargins(-dip5,0,-dip5,0);
        lp.gravity = Gravity.FILL_VERTICAL | Gravity.FILL_HORIZONTAL;
        dateTimeDisplay.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
        dateTimeDisplay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FragmentTransaction ft = getContentActivity().getSupportFragmentManager().beginTransaction();
                android.support.v4.app.Fragment prev = getContentActivity().getSupportFragmentManager().findFragmentByTag("dialog");
                if (prev != null) {
                    ft.remove(prev);
                }
                ft.addToBackStack(null);

                if (useDuration) {
                    DurationPickerFragment picker = new DurationPickerFragment();
                    picker.show(ft,"picker");
                } else if (timeOnly) {
                    TimePickerFragment picker = new TimePickerFragment();
                    picker.show(ft,"picker");
                } else if (dateOnly) {
                    DatePickerFragment picker = new DatePickerFragment();
                    picker.show(ft,"picker");
                } else {
                    DateTimePickerFragment picker = new DateTimePickerFragment();
                    picker.show(ft,"picker");
                }
            }
        });
        h.addView(dateTimeDisplay,lp);

        if (alarmSelectionVariable != null) {
            alarmButton = new ImageButton(getContext());
            String alarmID = (String)getVariable(alarmSelectionVariable);
            if (alarmID != null) {
                alarmButton.setImageResource(R.drawable.alarmclock_highlighted);
            } else {
                alarmButton.setImageResource(R.drawable.alarmclock);
            }
            lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
            lp.weight = 1;
            lp.setMargins(-dip5, 0, -dip5, 0);
            lp.gravity = Gravity.FILL_VERTICAL | Gravity.FILL_HORIZONTAL;
            alarmButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String alarmID = (String)getVariable(alarmSelectionVariable);
                    if (alarmID != null) {
                        unsetAlarm();
                    } else {
                        setAlarm();
                    }
                }
            });
            h.addView(alarmButton, lp);
        }

/*        if (!useDuration) {
            if (!self.defaultValue || ![self.defaultValue isEqualToString:@"nil"]) {
                NSDate *date = (NSDate*)[self getVariable:self.selectionVariable];
                if (!date) date = [NSDate date];
                [self setVariable:self.selectionVariable to:date];
            }
        } else {
            NSNumber *duration = (NSNumber*)[self getVariable:self.selectionVariable];
            if (duration) [self setVariable:self.selectionVariable to:duration];
        }
        */

        clientView.addView(h);
    }

}
