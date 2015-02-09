package gov.va.contentlib.controllers;

import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.content.Content;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.Button;

public class SubsequentExerciseController extends BaseExerciseController {

	public SubsequentExerciseController(Context ctx) {
		super(ctx);
	}

	public void nonExerciseBuild() {
		super.build();
	}
	
	@Override
	public void build() {
		super.build();
		Content nextChild = getContent().getChildByName("@next");
		if (nextChild != null) {
			addButton(nextChild.getDisplayName(), ManageNavigationController.BUTTON_NEXT);
		}
	}
}
