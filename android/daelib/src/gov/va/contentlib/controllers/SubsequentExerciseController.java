package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

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
			addButton(nextChild.getDisplayName()).setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					navigateToNext();
				}
			});		
		}
	}
}
