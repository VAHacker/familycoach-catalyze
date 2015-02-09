package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.Button;

public class SafetyPlanController extends BaseExerciseController {

	public SafetyPlanController(Context ctx) {
		super(ctx);
	}

	public ContentViewControllerBase checkProxy() {
		if ("true".equals(UserDBHelper.instance(getNavigator()).getSetting("finishedSafetyPlan"))) {
			return getContent().getChildByName("@subsequent").createContentView(getNavigator());
		}
		
		return getContent().getChildByName("@first").createContentView(getNavigator());
	}
}
