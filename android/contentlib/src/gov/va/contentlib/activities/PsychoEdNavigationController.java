package gov.va.contentlib.activities;

import gov.va.contentlib.controllers.ContentViewControllerBase;
import android.view.View;

public class PsychoEdNavigationController extends NavigationController {

	@Override
	public void pushView(View cv, int toRemain) {
		if (cv instanceof ContentViewControllerBase) {
			ContentViewControllerBase b = (ContentViewControllerBase)cv;
			b.viewTypeID = 1; // psycho-ed
		}
		super.pushView(cv, toRemain);
	}
	
	@Override
	public void flipReplaceView(View cv, int toKeep) {
		if (cv instanceof ContentViewControllerBase) {
			ContentViewControllerBase b = (ContentViewControllerBase)cv;
			b.viewTypeID = 1; // psycho-ed
		}
		super.flipReplaceView(cv, toKeep);
	}
}
