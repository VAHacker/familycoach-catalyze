package gov.va.contentlib;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.services.TtsContentProvider;
import gov.va.daelib.R;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.AppExitedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.AppLaunchedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TimeElapsedBetweenSessionsEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TotalTimeOnAppEvent;
import com.openmhealth.ohmage.core.EventLog;

import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

abstract public class TopContentActivity extends ContentActivity {

	private long sessionStartTime;
	
	private Dialog mSplashDialog;
	private View mSplashView;
	
	protected void removeSplashScreen() {
		AlphaAnimation alpha = new AlphaAnimation(1,0);
		alpha.setInterpolator(new AccelerateDecelerateInterpolator());
		alpha.setDuration(1000L);
		alpha.setFillAfter(true);
		alpha.setFillBefore(true);
		alpha.setFillEnabled(true);
		alpha.setAnimationListener(new Animation.AnimationListener() {
			public void onAnimationStart(Animation animation) {
			}
			public void onAnimationRepeat(Animation animation) {
			}
			public void onAnimationEnd(Animation animation) {
				if (mSplashDialog != null) {
			        mSplashDialog.dismiss();
			        mSplashDialog = null;
			        mSplashView = null;
			    }
			}
		});
		mSplashView.startAnimation(alpha);
	}
	 
	/**
	 * Shows the splash screen over the full Activity
	 */
	protected void showSplashScreen() {
		LayoutInflater inflater = LayoutInflater.from(this);
		mSplashView = (View)inflater.inflate(getSplashResource(), getRootFrame(), false);
		mSplashDialog = new Dialog(this, R.style.SplashScreen);
	    mSplashDialog.setContentView(mSplashView);

	    WindowManager manager = (WindowManager) getSystemService(Activity.WINDOW_SERVICE);
	    int width, height;
        width = manager.getDefaultDisplay().getWidth();
        height = manager.getDefaultDisplay().getHeight();
        WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
        lp.copyFrom(mSplashDialog.getWindow().getAttributes());
        lp.width = width;
        lp.height = height;
        mSplashDialog.getWindow().setAttributes(lp);
        
	    mSplashDialog.setCancelable(false);
	    mSplashDialog.show();

	    // Set Runnable to remove splash screen just in case
	    final Handler handler = new Handler();
	    handler.postDelayed(new Runnable() {
	      @Override
	      public void run() {
	        removeSplashScreen();
	      }
	    }, 3000);
	}
	
	abstract public int getSplashResource();
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		showSplashScreen();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		/*
		sessionStartTime = System.currentTimeMillis();
		
		String lastSessionTSStr = UserDBHelper.instance(this).getSetting("lastSessionEndTime");
		if (lastSessionTSStr != null) {
			long lastSessionTS = Long.parseLong(lastSessionTSStr);
			TimeElapsedBetweenSessionsEvent e = new TimeElapsedBetweenSessionsEvent();
			e.timeElapsedBetweenSessions = System.currentTimeMillis() - lastSessionTS;
			EventLog.log(e);
		}
		
		AppLaunchedEvent e = new AppLaunchedEvent();
		e.accessibilityFeaturesActiveOnLaunch = TtsContentProvider.shouldSpeak(this) ? 1 : 0;
		EventLog.log(e);
		*/
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		/*
        String uptimeStr = UserDBHelper.instance(this).getSetting("totalUptime");
        long uptime = (uptimeStr == null) ? 0 : Long.parseLong(uptimeStr);
        uptime += System.currentTimeMillis() - sessionStartTime;
        
        {
        	TotalTimeOnAppEvent e = new TotalTimeOnAppEvent();
        	e.totalTimeOnApp = uptime;
        	EventLog.log(e);
        }
        UserDBHelper.instance(this).setSetting("totalUptime",""+uptime);

        UserDBHelper.instance(this).setSetting("lastSessionEndTime", ""+System.currentTimeMillis());

        {
        	AppExitedEvent e = new AppExitedEvent();
        	e.appExitedAccessibilityFeaturesActive = TtsContentProvider.shouldSpeak(this) ? 1 : 0;
        	EventLog.log(e);
        }
        */
	}
	
	@Override
	protected void onStart() {
		super.onStart();
//		new Thread(new Runnable() {
//			public void run() {
//			}
//		}).start();
//		FlurryAgent.onStartSession(this, "15TJQ1LZBD8MNZTRNF3K");
		
//		if(tts==null)
	//		checkForTTS();
	}
	
	@Override
	protected void onStop() {
//		FlurryAgent.onEndSession(this);

		super.onStop();
	}
	
}
