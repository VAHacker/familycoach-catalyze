package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import android.content.Context;

public class SafetyPlanController extends BaseExerciseController {

	public SafetyPlanController(Context ctx) {
		super(ctx);
	}
	// XXX
/*
	public ContentViewControllerBase checkProxy() {
		if ("true".equals(UserDBHelper.instance(getContext()).getSetting("finishedSafetyPlan"))) {
			return getContent().getChildByName("@subsequent").createContentView(getContext());
		}
		
		return getContent().getChildByName("@first").createContentView(getContext());
	}
*/	
}
