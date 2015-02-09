package gov.va.contentlib.controllers;

import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.FrameLayout.LayoutParams;

public class WhoToContactController extends SubsequentExerciseController {

	ContactList contactList;
	
	public WhoToContactController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		contactList = new ContactList(this, true);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(contactList,lp);
		contactList.bindToSetting(getContent().getStringAttribute("storeAs"), true);
	}
}
