package gov.va.contentlib.controllers;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.view.View;

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
		
		UserDBHelper.instance(getContext()).setSetting("finishedSafetyPlan", "true");
		
		Content nextChild = getContent().getChildByName("@next");
		if (nextChild != null) {
			LoggingButton b = addButton(nextChild.getDisplayName());
			b.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					Content top = ContentDBHelper.instance(getContext()).getContentForName("safetyPlan");
					navigateToNextContent(top.getChildByName("@subsequent"));
				}
			});
		}
	}
}
