package gov.va.contentlib.controllers;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import java.util.Calendar;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.daelib.R;

public class AlarmController extends ContentViewController {

    AlarmManager am;
    String alarmName;
    String alarmDestination;
    String alarmAction;
    String alarmBody;

	public AlarmController(Context ctx) {
		super(ctx);
        am = (AlarmManager)getContext().getSystemService(Context.ALARM_SERVICE);
	}

    @Override
    public void setVariable(String name, Object value) {
        setLocalVariable(name, value);
        if ("dailyAlarmOn".equals(name) || "alarmTime".equals(name)) {
            updateAlarm();
        }
    }

    public void updateAlarm() {
        Boolean b = (Boolean)getVariable("dailyAlarmOn");
        Long time = (Long)getVariable("alarmTime");
        if (time == null) time = System.currentTimeMillis();

        getUserDB().setSetting("dailyAlarmOn_"+alarmName,(b == null) ? "false" : b.toString());
        getUserDB().setSetting("alarmTime_"+alarmName,time.toString());

        Intent alarmIntent = Util.getAlarmIntent(getContext());
        alarmIntent.setData(Uri.parse("alarm:"+alarmName));
        alarmIntent.putExtra("alarmName", alarmName);
        alarmIntent.putExtra("alarmDestination", alarmDestination);
        alarmIntent.putExtra("alarmAction", alarmAction);
        alarmIntent.putExtra("alarmBody",alarmBody);

        PendingIntent alarmPendingIntent = PendingIntent.getBroadcast(getContext().getApplicationContext(), 0, alarmIntent, 0);
        am.cancel(alarmPendingIntent);

        if (b) {
            Calendar timecal = Calendar.getInstance();
            timecal.setTimeInMillis(time);

            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.HOUR,timecal.get(Calendar.HOUR));
            cal.set(Calendar.MINUTE,timecal.get(Calendar.MINUTE));
            cal.set(Calendar.SECOND,0);
            cal.set(Calendar.MILLISECOND,0);

            cal.roll(Calendar.DATE,1);

            long when = cal.getTimeInMillis();
            am.setRepeating(AlarmManager.RTC_WAKEUP, when, 1000L * 60 * 60 * 24, alarmPendingIntent);
        }
    }

    @Override
    public void buildClientViewFromContent() {
        Content c = getContent();
        alarmName = c.getStringAttribute("alarmName");
        alarmDestination = c.getStringAttribute("alarmDestination");
        alarmAction = c.getStringAttribute("alarmAction");
        alarmBody = c.getStringAttribute("alarmBody");

        String isOnStr = getUserDB().getSetting("dailyAlarmOn_"+alarmName);
        boolean isOn = (isOnStr == null) ? false : Boolean.parseBoolean(isOnStr);
        setLocalVariable("dailyAlarmOn",isOn);

        String alarmTimeStr = getUserDB().getSetting("alarmTime_"+alarmName);
        Long alarmTime = (alarmTimeStr == null) ? null : Long.parseLong(alarmTimeStr);
        setLocalVariable("alarmTime",alarmTime);

        super.buildClientViewFromContent();
    }
}
