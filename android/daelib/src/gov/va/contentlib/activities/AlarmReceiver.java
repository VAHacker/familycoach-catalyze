package gov.va.contentlib.activities;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.util.Log;

import gov.va.contentlib.Util;
import gov.va.daelib.R;

/**
 * Created by geh on 2/23/14.
 */
public class AlarmReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d("AlarmReceiver", "got "+intent.toString());

        String alarmName = intent.getStringExtra("alarmName");
        String alarmDestination = intent.getStringExtra("alarmDestination");
        String alarmAction = intent.getStringExtra("alarmAction");
        String alarmBody = intent.getStringExtra("alarmBody");

        NotificationManager nm = (NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);
        Notification.Builder nb = new Notification.Builder(context);

        nb.setSmallIcon(R.drawable.icon);
        nb.setContentTitle(alarmAction);
        nb.setContentText(alarmBody.replace("%@", context.getResources().getString(R.string.app_name)));
        nb.setAutoCancel(true);
        Uri notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        nb.setSound(notification);

        Intent reminderIntent = Util.getNotificationIntent(context);
        reminderIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        reminderIntent.setData(Uri.parse("content:"+alarmDestination));
        PendingIntent reminderPendingIntent = PendingIntent.getActivity(context.getApplicationContext(), 0, reminderIntent, 0);
        nb.setContentIntent(reminderPendingIntent);

        Notification noti = nb.getNotification();
        nm.notify(alarmName, 0, noti);
    }
}
