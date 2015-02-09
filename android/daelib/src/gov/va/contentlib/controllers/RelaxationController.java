package gov.va.contentlib.controllers;

import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;

public class RelaxationController extends BaseExerciseController {

	public RelaxationController(Context ctx) {
		super(ctx);
	}

	public void nonExerciseBuild() {
		super.build();
	}
	
	@Override
	public void onContentBecameVisibleForFirstTime() {
		super.onContentBecameVisibleForFirstTime();
		playAudio();
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
		
		clientView.setKeepScreenOn(true);
	}
}
