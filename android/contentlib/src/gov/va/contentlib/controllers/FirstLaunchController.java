package gov.va.contentlib.controllers;

import gov.va.contentlib.Util;
import gov.va.contentlib.activities.FirstLaunch;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.widget.LinearLayout;
import android.widget.FrameLayout.LayoutParams;

public class FirstLaunchController extends ContentViewController {

	static final int SKIP_SETUP = 1001;
	static final int ENTER_SETUP = 1002;
	
	public FirstLaunchController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		LinearLayout.LayoutParams params;

		params = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
		params.setMargins(10, 10, 5, 10);
		addButton("Skip Setup", SKIP_SETUP).setLayoutParams(params);

		params = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
		params.setMargins(5, 10, 10, 10);
		addButton("Continue with Setup", ENTER_SETUP).setLayoutParams(params);
	}
	
	public boolean shouldAddButtonsInScroller() {
		return false;
	}
	
	public void buttonTapped(int id) {
		FirstLaunch activity = (FirstLaunch)getContext();
		if (id == SKIP_SETUP) {
			Intent intent = new Intent(Util.getActionMapping("main"));
			activity.startActivityForResult(intent, Activity.RESULT_FIRST_USER);
		} else {
			Intent intent = new Intent(Util.getActionMapping("setup"));
			activity.startActivityForResult(intent, Activity.RESULT_FIRST_USER);
		}
	}

}
