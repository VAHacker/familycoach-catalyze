package gov.va.contentlib.controllers;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.Button;

public class SafetyPlanFinishedController extends BaseExerciseController {

	public SafetyPlanFinishedController(Context ctx) {
		super(ctx);
	}

	public void nonExerciseBuild() {
		super.build();
	}
	
	@Override
	public void build() {
		super.build();
		
		UserDBHelper.instance(getNavigator()).setSetting("finishedSafetyPlan", "true");
		
		Content nextChild = getContent().getChildByName("@next");
		if (nextChild != null) {
			LoggingButton b = addButton(nextChild.getDisplayName());
			b.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					Content top = ContentDBHelper.instance(getNavigator()).getContentForName("safetyPlan");
					getNavigator().pushView(top.getChildByName("@subsequent").createContentView(getNavigator()), 1);
				}
			});
		}
	}
}
