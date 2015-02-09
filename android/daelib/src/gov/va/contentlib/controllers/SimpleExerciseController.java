package gov.va.contentlib.controllers;

import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

public class SimpleExerciseController extends BaseExerciseController {

	public SimpleExerciseController(Context ctx) {
		super(ctx);
	}

	public void nonExerciseBuild() {
		super.build();
	}
	
	@Override
	public void build() {
		super.build();
		addThumbs();
		addButton("I'm Done").setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				navigateToNext();
			}
		});		
	}
}
