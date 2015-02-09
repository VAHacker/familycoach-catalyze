package gov.va.contentlib.controllers;

import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

public class CategoryIntroController extends BaseExerciseController {

	public CategoryIntroController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText("Begin Exercise");
		beginExerciseButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				navigateToNextContent(selectedContent);
			}
		});		
		clientView.addView(beginExerciseButton);
	
		addThumbs();
	}
	
}
