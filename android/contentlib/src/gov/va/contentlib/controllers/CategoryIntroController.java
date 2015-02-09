package gov.va.contentlib.controllers;

import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.view.View;
import android.widget.Button;

public class CategoryIntroController extends BaseExerciseController {

	
	public CategoryIntroController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText("Take a Timeout");
		beginExerciseButton.setTextSize(17);
		beginExerciseButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				getNavigator().pushReplaceViewForContent(selectedContent);
			}
		});
		beginExerciseButton.setId(ManageNavigationController.BUTTON_NEXT);
		clientView.addView(beginExerciseButton);
	
//		addThumbs();
		addNewToolButton();
	}
	
}
