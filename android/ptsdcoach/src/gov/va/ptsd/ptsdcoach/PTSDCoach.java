package gov.va.ptsd.ptsdcoach;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.TopContentActivity;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.contentlib.services.TtsContentProvider;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

import com.flurry.android.FlurryAgent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.AppExitedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.AppLaunchedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TimeElapsedBetweenSessionsEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TotalTimeOnAppEvent;
import com.openmhealth.ohmage.core.EventLog;

import android.app.Activity;
import android.app.TabActivity;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetManager;
import android.database.SQLException;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TabHost;
import android.widget.TabWidget;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ImageView.ScaleType;
import android.speech.tts.TextToSpeech;
import android.speech.tts.TextToSpeech.OnInitListener;
import android.widget.Toast;

public class PTSDCoach extends ContentActivity {

	private View splash = null;
	private long sessionStartTime;
	private boolean triggerAssessment = false;
		
	public void addSplash() {
		LayoutInflater inflater = LayoutInflater.from(this);
		splash = (View)inflater.inflate(gov.va.ptsd.ptsdcoach.R.layout.splash, getRootFrame(), false);
		getRootFrame().addView(splash);
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		String assessmentIntent = Util.getAssessmentIntent(this);
		if ((assessmentIntent != null) && assessmentIntent.equals(getIntent().getAction())) {
			triggerAssessment = true;
		}
		
		getSupportActionBar().hide();
		setContent(getDB().getContentForName("ROOT"));

		AlphaAnimation alpha = new AlphaAnimation(1,0);
		alpha.setInterpolator(new AccelerateDecelerateInterpolator());
		alpha.setDuration(1000L);
		alpha.setFillAfter(true);
		alpha.setFillBefore(true);
		alpha.setFillEnabled(true);
		alpha.setStartTime(AnimationUtils.currentAnimationTimeMillis()+3000);
		alpha.setAnimationListener(new Animation.AnimationListener() {
			public void onAnimationStart(Animation animation) {
			}
			public void onAnimationRepeat(Animation animation) {
			}
			public void onAnimationEnd(Animation animation) {
				getSupportActionBar().show();
				getRootFrame().removeView(splash);
				splash = null;
			}
		});
		splash.setAnimation(alpha);

	}
	
	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		String assessmentIntent = Util.getAssessmentIntent(this);
		if ((assessmentIntent != null) && assessmentIntent.equals(intent.getAction())) {
			triggerAssessment = true;
		}
	}
	
	@Override
	protected void onResume() {
		super.onResume();
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

		if (triggerAssessment) {
			triggerAssessment = false;
			Content c = getDB().getContentForName("takeAssessment");
			navigateToContent(c);
		}
	}
	
	@Override
	protected void onPause() {
		super.onPause();
		
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
	}
	
	@Override
	protected void onStart() {
		super.onStart();
		FlurryAgent.onStartSession(this, "15TJQ1LZBD8MNZTRNF3K");
		
//		if(tts==null)
	//		checkForTTS();

	}
	
	@Override
	protected void onStop() {
		FlurryAgent.onEndSession(this);

		super.onStop();
	}
	
}