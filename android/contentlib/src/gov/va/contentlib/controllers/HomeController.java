package gov.va.contentlib.controllers;

import gov.va.contentlib.TopContentActivity;
import android.app.Activity;
import android.content.Context;

public class HomeController extends ButtonGridController {

	public HomeController(Context ctx) {
		super(ctx);
	}
	
	public void buttonTapped(final int id) {
		getNavigator().bgrunner.post(new Runnable() {
			
			@Override
			public void run() {
				TopContentActivity a = (TopContentActivity)(getNavigator().getParent());
//				a.getTabHost().setCurrentTab(1+id);
			}
		});
	}

}
