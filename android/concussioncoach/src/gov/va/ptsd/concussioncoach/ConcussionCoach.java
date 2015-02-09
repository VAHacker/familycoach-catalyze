package gov.va.ptsd.concussioncoach;

import gov.va.contentlib.TopContentActivity;
import gov.va.contentlib.Util;

public class ConcussionCoach extends TopContentActivity {

    static {
        Util.setMainActivityClass(ConcussionCoach.class);
    }

	@Override
	public int getSplashResource() {
		return gov.va.ptsd.concussioncoach.R.layout.splash;
	}
}
