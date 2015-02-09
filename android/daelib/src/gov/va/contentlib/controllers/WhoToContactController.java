package gov.va.contentlib.controllers;

import gov.va.contentlib.views.ContactList;
import android.content.Context;
import android.widget.LinearLayout;

public class WhoToContactController extends SubsequentExerciseController {

	ContactList contactList;
	
	public WhoToContactController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		boolean editable = content.getBoolean("editing");
		contactList = new ContactList(this, editable, editable);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(contactList,lp);
		contactList.bindToSetting(getContent().getStringAttribute("storeAs"), true);
	}
}
