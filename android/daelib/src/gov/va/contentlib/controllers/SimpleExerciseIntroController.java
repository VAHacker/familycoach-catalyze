package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

public class SimpleExerciseIntroController extends BaseExerciseController {

	public SimpleExerciseIntroController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		LoggingButton beginExerciseButton = new LoggingButton(getContext());
		beginExerciseButton.setText("Begin Exercise");
		beginExerciseButton.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				Content next = getContent().getNext();
				contentSelected(next);
			}
		});
		beginExerciseButton.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				navigateToNext();
			}
		});		
		clientView.addView(beginExerciseButton);
	
		addThumbs();
	}
	
}
