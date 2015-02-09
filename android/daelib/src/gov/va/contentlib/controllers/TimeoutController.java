package gov.va.contentlib.controllers;


import android.content.Context;
import android.os.Handler;
import android.os.SystemClock;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.view.accessibility.AccessibilityManager;
import android.widget.LinearLayout;
import android.widget.TextView;

import gov.va.contentlib.services.TtsContentProvider;
import gov.va.contentlib.views.LoggingButton;

public class TimeoutController extends SimpleExerciseController {

	TextView timer;
	long timeout;
	Runnable timerUpdateRunnable;
	Handler handler;
    boolean autoStartTimer;
	
	public TimeoutController(Context ctx) {
		super(ctx);
	}

	public String textForDuration(long duration) {
        long minutes;
        long seconds;

        seconds=(duration/1000);

        minutes = seconds / 60;
        seconds -= (minutes*60);
        return String.format("%02d:%02d",new Long(minutes), new Long(seconds));
    }

	public void updateTimer() {
		String label;
		long now = SystemClock.elapsedRealtime();
		
		if (timer.getHandler() == null) {
			if (handler != null) {
				handler.removeCallbacks(timerUpdateRunnable);
			}
			return;
		}
		
		long delta = timeout - now;
		if (delta <= 0) {
			label = "00:00";
			if (handler != null) {
				handler.removeCallbacks(timerUpdateRunnable);
			}
		} else {
			label = textForDuration(delta);
			if (handler != null) {
				handler.postDelayed(timerUpdateRunnable, 500);
			}
		}
		timer.setText(label);
	}
	
	@Override
	public void build() {
		super.build();

        AccessibilityManager am = (AccessibilityManager)getContext().getSystemService(Context.ACCESSIBILITY_SERVICE);
        autoStartTimer = !am.isEnabled();
        if (!autoStartTimer) {
            LoggingButton b = new LoggingButton(getContext());
            b.setText("Start Timer");
            b.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    startTimer();
                }
            });
            clientView.addView(b, new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
        }

		DisplayMetrics dm = getContentResources().getDisplayMetrics();
		timer = new TextView(getContext());
		timer.setGravity(Gravity.CENTER);
		timer.setTextSize(64);
        Integer timeoutDuration = getContent().getIntAttribute("timeoutDuration");
        if (timeoutDuration == null) timeoutDuration = 5;
        timer.setText(textForDuration((timeoutDuration*60*1000L)));

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
		clientView.addView(timer,params);

		timerUpdateRunnable = new Runnable() {
			@Override
			public void run() {
				updateTimer();
			}
		};
		
	}

    public void startTimer() {
        handler = getHandler();
        Integer timeoutDuration = getContent().getIntAttribute("timeoutDuration");
        if (timeoutDuration == null) timeoutDuration = 5;
        timeout = SystemClock.elapsedRealtime() + (timeoutDuration*60*1000L)+500; //set it to 5 minutes
        updateTimer();
    }

	@Override
	public void onContentBecameVisibleForFirstTime() {
		super.onContentBecameVisibleForFirstTime();
        if (autoStartTimer) startTimer();
	}

	@Override
	public void onContentBecameInvisible() {
		super.onContentBecameInvisible();
/*
		if (handler != null) {
			handler.removeCallbacks(timerUpdateRunnable);
			handler = null;
		}
*/		
	}
	
}
