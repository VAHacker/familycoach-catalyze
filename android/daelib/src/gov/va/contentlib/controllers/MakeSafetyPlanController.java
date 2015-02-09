package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

public class MakeSafetyPlanController extends BaseExerciseController {

	public MakeSafetyPlanController(Context ctx) {
		super(ctx);
	}

	public String getContentMainText() {
		UserDBHelper db = UserDBHelper.instance(getContext());
		if ("true".equals(db.getSetting("finishedSafetyPlan"))) {
			return content.getChildByName("@recreate").getMainText();
		} else if ("true".equals(db.getSetting("startedSafetyPlan"))) {
			return content.getChildByName("@incomplete").getMainText();
		}
		
		return content.getMainText();
	}
	
	@Override
	public void build() {
		super.build();
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText(getContent().getChildByName("@next").getDisplayName());
		beginExerciseButton.setTextSize(17);
		beginExerciseButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Content next = getContent().getNext();
				UserDBHelper.instance(getContext()).setSetting("startedSafetyPlan", "true");
				contentSelected(next);
			}
		});
		beginExerciseButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				navigateToNext();
			}
		});		
		clientView.addView(beginExerciseButton);
	}

}
