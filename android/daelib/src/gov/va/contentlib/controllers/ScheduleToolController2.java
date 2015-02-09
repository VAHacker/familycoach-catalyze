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

public class ScheduleToolController2 extends EventEditorController {

	public ScheduleToolController2(Context ctx) {
		super(ctx);
		eventType = "tool";
	}
	
}
