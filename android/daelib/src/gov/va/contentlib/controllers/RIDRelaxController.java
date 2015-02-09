package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.os.Handler;
import android.os.SystemClock;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

public class RIDRelaxController extends BaseExerciseController {

	static final int ANOTHER_30_SECONDS = 701;
	
	LoggingButton another30SecondsButton; 
	TextView timer;
	long timeout;
	Runnable timerUpdateRunnable;
	Handler handler;
	
	public RIDRelaxController(Context ctx) {
		super(ctx);
	}

	
	
	public void updateTimer() {
		String label;
		long now = SystemClock.elapsedRealtime();
		long delta = timeout - now;
		if (delta <= 0) {
			label = "00:00";
			another30SecondsButton.setEnabled(true);
			if (handler != null) {
				handler.removeCallbacks(timerUpdateRunnable);
			}
		} else {
			label = String.format("00:%02d",new Long(delta / 1000));
			another30SecondsButton.setEnabled(false);
			if (handler != null) {
				handler.postDelayed(timerUpdateRunnable, 500);
			}
		}
		timer.setText(label);
	}
	
	@Override
	public void build() {
		super.build();
		
		timer = new TextView(getContext());
		timer.setGravity(Gravity.CENTER);
//		timer.setTextColor(0xFFFFFFFF);
		timer.setTextSize(64);
		
		LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		clientView.addView(timer,params);

		timerUpdateRunnable = new Runnable() {
			@Override
			public void run() {
				updateTimer();
			}
		};
		
		another30SecondsButton = new LoggingButton(getContext());
		another30SecondsButton.setText("30 More Seconds Of 'Relax'");
		another30SecondsButton.setEnabled(false);
		another30SecondsButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				timeout = SystemClock.elapsedRealtime() + (30*1000L) + 500;
				updateTimer();
			}
		});
		clientView.addView(another30SecondsButton);

		LoggingButton goOn = addButton("Go On");
		goOn.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				navigateToNext();
			}
		});
	}
	
	@Override
	public void onContentBecameVisible() {
		super.onContentBecameVisible();
		handler = getHandler();
		timeout = SystemClock.elapsedRealtime() + (30*1000L) + 500;
		updateTimer();
	}

	@Override
	public void onContentBecameInvisible() {
		super.onContentBecameInvisible();
		if (handler != null) {
			handler.removeCallbacks(timerUpdateRunnable);
			handler = null;
		}
	}
}
