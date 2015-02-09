package gov.va.contentlib.activities;

import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.contentlib.controllers.NavController;
import android.content.Context;
import android.view.View;

public class PsychoEdNavigationController extends NavController {
	
	public PsychoEdNavigationController(Context ctx) {
		super(ctx);
	}
/*
	@Override
	public void pushView(View cv, int toRemain, Runnable after) {
		if (cv instanceof ContentViewControllerBase) {
			ContentViewControllerBase b = (ContentViewControllerBase)cv;
			b.viewTypeID = 1; // psycho-ed
		}
		super.pushView(cv, toRemain, after);
	}
	
	@Override
	public void flipReplaceView(View cv, int toKeep) {
		if (cv instanceof ContentViewControllerBase) {
			ContentViewControllerBase b = (ContentViewControllerBase)cv;
			b.viewTypeID = 1; // psycho-ed
		}
		super.flipReplaceView(cv, toKeep);
	}
*/	
}
