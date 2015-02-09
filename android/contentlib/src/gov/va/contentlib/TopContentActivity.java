package gov.va.contentlib;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.AssessNavigationController;
import gov.va.contentlib.activities.HomeNavigationController;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.activities.NavigationController;
import gov.va.contentlib.activities.SetupActivity;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.contentlib.R;
import gov.va.contentlib.R.style;

import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

import com.flurry.android.FlurryAgent;

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
import android.view.WindowManager;
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

public class TopContentActivity extends Activity {

	public boolean fromBackground;
		
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_HIDDEN);
		
		fromBackground=false;
	}

	@Override
	protected void onPause()
	{
		fromBackground=true;

		super.onPause();
	}
	

	@Override
	protected void onResume()
	{
		fromBackground=false;
		
		super.onResume();
	}
}