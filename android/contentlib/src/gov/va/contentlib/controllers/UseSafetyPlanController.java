package gov.va.contentlib.controllers;

import java.util.Arrays;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.LoggingButton;
import gov.va.contentlib.views.PackingList;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

public class UseSafetyPlanController extends BaseExerciseController {

	public UseSafetyPlanController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();
		
		LoggingButton changeMyPlan = new LoggingButton(getContext());
		changeMyPlan.setText("Change my Plan");
		changeMyPlan.setTextSize(17);
		changeMyPlan.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Content next = getContent().getParent().getChildByName("@first");
				getNavigator().pushReplaceViewForContent(next);
			}
		});
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
		lp.gravity = Gravity.CENTER_HORIZONTAL;
		clientView.addView(changeMyPlan,lp);
		
		for (Content child : getContent().getChildren()) {
			String text = child.getMainText();
			String special = child.getStringAttribute("special");
			UserDBHelper db = UserDBHelper.instance(getNavigator());
			if (special != null) {
				if (special.startsWith("contacts")) {
					addMainTextContent(text);
					ContactList contactList = new ContactList(this,false);
					lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
					lp.setMargins(10, 0, 10, 0);
					clientView.addView(contactList,lp);
					contactList.bindToSetting(special.substring(9), true);
				} else if (special.startsWith("packing")) {
					String data = db.getSetting(special.substring(8));
					if ((data != null) && !data.equals("")) {
						addMainTextContent(text);
						String[] ids = data.split("\\|");
						PackingList packingList = new PackingList(this, Arrays.asList(ids));
						lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
						lp.setMargins(10, 0, 10, 0);
						clientView.addView(packingList,lp);
					}
				} else {
					addMainTextContent(text);
				}
			} else {
				addMainTextContent(text);
			}
		}
	}
}
