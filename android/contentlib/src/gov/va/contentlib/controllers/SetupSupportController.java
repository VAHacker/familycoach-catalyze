package gov.va.contentlib.controllers;

import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ContactsEditListActivity;
import gov.va.contentlib.activities.FirstLaunch;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.widget.LinearLayout;
import android.widget.FrameLayout.LayoutParams;

public class SetupSupportController extends ContentViewController {

	static final int SETUP_SUPPORT = 1001;
	
	public SetupSupportController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		addButton("Select Support Contacts", SETUP_SUPPORT);
	}

	public void buttonTapped(int id) {
		Activity activity = (Activity)getContext();
        Intent intent = new Intent(getContext(), ContactsEditListActivity.class);
        addActivityResultListener(new ActivityResultListener() {
			@Override
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
		        getNavigator().popToRoot();
			}
		});
        activity.startActivityForResult(intent, Activity.RESULT_FIRST_USER);
	}

}
