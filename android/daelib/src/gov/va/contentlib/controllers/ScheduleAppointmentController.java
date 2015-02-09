package gov.va.contentlib.controllers;

import gov.va.contentlib.util.CalendarEventScheduler;

import java.util.Arrays;
import java.util.Calendar;

import android.annotation.TargetApi;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.provider.CalendarContract.Events;
import android.util.Log;

public class ScheduleAppointmentController extends EventEditorController {

	public ScheduleAppointmentController(Context ctx) {
		super(ctx);
		PackageManager pm = getContext().getPackageManager();
		String appLabel = null;
		try {
			appLabel = pm.getApplicationLabel(pm.getApplicationInfo(getContext().getPackageName(), PackageManager.GET_META_DATA)).toString() + " ";
		} catch (Exception e) {}
		eventName = appLabel + "Appointment";
		eventType = "appt";
	}
/*
	@Override
	public boolean isHeadless() {
		return true;
	}
	
	@Override
	public void exec() {
		Calendar cal = Calendar.getInstance();
		long millis = cal.getTimeInMillis();
		
		Intent intent = new Intent(Intent.ACTION_EDIT);  
		intent.setType("vnd.android.cursor.item/event");
		intent.putExtra("title", "Some title");
		intent.putExtra("description", "Some description");
		intent.putExtra("beginTime", millis);
		intent.putExtra("endTime", millis+60*60*1000);
		intent.putExtra("customAppPackage", getContext().getApplicationInfo().packageName);
		intent.putExtra("customAppUri", "foo:bar");
		startActivityForResult(intent, new ActivityResultListener() {
			@TargetApi(14)
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
				String msg = data == null ? "null" : data.toString();
				Log.d("dae",msg);
				Cursor cur = null;
				ContentResolver cr = getContext().getContentResolver();
				Uri uri = Events.CONTENT_URI;   
				cur = cr.query(uri, null, "customAppPackage=?", new String[] {getContext().getApplicationInfo().packageName}, null);
				if (cur.moveToFirst()) {
					msg = Arrays.toString(cur.getColumnNames());
					Log.d("dae",msg);
				}
			}
		});
	}
	*/
	
}
