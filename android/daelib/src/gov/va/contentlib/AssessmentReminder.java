package gov.va.contentlib;

import gov.va.daelib.R;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;

public class AssessmentReminder extends BroadcastReceiver {

	public void notifyPCL(Context context) {
		// Set up the notification
		String ns = Context.NOTIFICATION_SERVICE;
		NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(ns);

		int icon = R.drawable.icon;
		long when = System.currentTimeMillis();

		try {
			String appName = Util.getAppName(context);
            Intent notificationIntent = Util.getNotificationIntent(context);

			notificationIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			PendingIntent contentIntent = PendingIntent.getActivity(context, 0, notificationIntent, 0);
			Notification notification = new Notification(icon, appName+" Assessment", when);
			notification.setLatestEventInfo(context, appName+" Assessment", "It is time to take your periodic "+appName+" assessment.", contentIntent);
			notification.defaults |= Notification.DEFAULT_SOUND;
			notification.flags |= Notification.FLAG_NO_CLEAR;

			mNotificationManager.notify(1, notification);
		} catch (Exception e1) {
			e1.printStackTrace();
		}
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		notifyPCL(context);
	}
}
