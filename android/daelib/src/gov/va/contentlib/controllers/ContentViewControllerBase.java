package gov.va.contentlib.controllers;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.content.Caption;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.content.ContentActivity.ActivityResultListener;
import gov.va.contentlib.content.Record;
import gov.va.contentlib.services.TtsContentProvider;
import gov.va.contentlib.views.LoggingButton;
import gov.va.contentlib.views.LoggingImageButton;

import android.R;
import android.text.Html;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.text.BreakIterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.PorterDuff.Mode;
import android.graphics.Picture;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.speech.tts.TextToSpeech;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.GestureDetector;
import android.view.GestureDetector.OnGestureListener;
import android.view.Gravity;
import android.view.LayoutInflater;

import com.actionbarsherlock.app.SherlockFragment;
import com.actionbarsherlock.internal.widget.IcsLinearLayout;
import com.actionbarsherlock.view.Menu;
import com.actionbarsherlock.view.MenuItem; 
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityNodeProvider;
import android.view.animation.AlphaAnimation;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.view.animation.TranslateAnimation;
import android.webkit.WebSettings;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.FrameLayout.LayoutParams;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ContentObjectSelectedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ContentScreenViewedEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.TimePerScreenEvent;
import com.openmhealth.ohmage.core.EventLog;


abstract public class ContentViewControllerBase {

	static final private String TAG = "ContentViewControllerBase";
	
	public ContentActivity getSherlockActivity() {
		return (ContentActivity)context;
	}

	static final Pattern VARIABLE_PATTERN = Pattern.compile("\\$\\{([a-zA-Z0-9_]*)\\}");
	static final private String webviewFormat = 
		"<html><head>"+
		"<script type=\"text/javascript\">function PFC_countLinks() { window.location.href = 'linkcount:'+document.links.length; }</script>"+
//	    "<script type=\"text/javascript\" src=\"content://gov.va.ptsd.ptsdfamilycoach.services.localjs/ideal-loader.js\"/>"+
		"<style>body{background-color:transparent;color:%s;font-size:%s;margin:0px;padding:0px;}\na:link {color:#4444CC;}</style></head><body>%s</body></html>";

	private final Context context;
	
	protected ContentDBHelper db;
	protected UserDBHelper userDb;
	protected Content content;
	protected Content selectedContent;
	
	int contentsToLoad = 0;
	OnViewReadyListener listener;
	ContentViewControllerBase parentController;

	FrameLayout rootView;
	LinearLayout topView;
	ScrollView scroller;
	ViewGroup clientView;

	LinearLayout buttonBar;
	LinearLayout rightButtons;
	LinearLayout leftButtons;

	int dynamicViewID = 1;
	boolean everVisible = false;

	String title;
	String spokenText;
    String dynamicPredicate;
	MediaPlayer audioPlayer;
	long audioPlayerStartTime;
	Caption[] captions;
	CaptionPlayer captionPlayer;
	CaptionView captionView;
	WebView lastWebView;
	boolean blocked = false;
	long timeAppeared;
	public int viewTypeID=2;
	boolean isInline = false;
	boolean contentVisible = false;
	
	TreeMap<String,Method> actions = null;

	TreeMap<String,Object> localVariables = null;
	private List<ContentViewControllerBase> childContentControllers = new ArrayList<ContentViewControllerBase>();
	
	class JSInterface {
		public void listen() {
			playAudio();
		}
	}

	class JSTalkBackInterface {
		public void deliverText(String text) {
			Log.d("JSTalkBackInterface","deliverText: "+text);
		}

		public void speakInteractive(String text) {
			Log.d("JSTalkBackInterface","speakInteractive: "+text);
		}
	}

	class CaptionView extends TextView {
		Paint bgPaint;

		public CaptionView(Context ctx) {
			super(ctx);
			bgPaint = new Paint();
			bgPaint.setColor(0xA0808080);
			bgPaint.setStyle(Style.FILL);
			setTextColor(0xFFFFFFFF);
			setTextSize(18);
			setGravity(Gravity.CENTER);
			setPadding(30, 10, 30, 10);
			setBackgroundColor(0);
		}
		
		@Override
		protected void onTextChanged(CharSequence text, int start, int before, int after) {
			super.onTextChanged(text, start, before, after);
		}
		
		@Override
		protected void onDraw(Canvas canvas) {
			RectF r = new RectF(10, 0, getWidth()-10, getHeight());
			canvas.drawRoundRect(r, 10, 10, bgPaint);
			super.onDraw(canvas);
		}
	}
	
	public Resources getContentResources() {
		return getContext().getResources();
	}

	public Context getContext() {
//		if (context != null) return context;
//		return getActivity();
		return context;
	}

	public int getDynamicViewID() {
		return rootView.getId();
	}

	static int nextDynamicViewID = 100;
	public int allocDynamicViewID() {
		return nextDynamicViewID++;
	}
	
	public Handler getHandler() {
//		return null;
		return getContentActivity().getWindow().getDecorView().getHandler();
	}
	
	class CaptionPlayer implements Runnable {
		Handler handler;
		int captionIndex;
		boolean shown;
		boolean on;
		String currentCaption;

		public void start() {
			handler = getHandler();
			captionIndex = 0;
			shown = false;
			on = captionsAreOn();
			
			Caption c = captions[0];
			handler.postAtTime(this, audioPlayerStartTime + c.startTime);
			
			AlphaAnimation alpha = new AlphaAnimation(0, 0);
			alpha.setInterpolator(new LinearInterpolator());
			alpha.setDuration(0);
			alpha.setFillAfter(true);
			alpha.setFillBefore(true);
			alpha.setFillEnabled(true);
			getCaptionView().startAnimation(alpha);
		}
		
		@Override
		public void run() {
			if (!shown) {
				Caption c = captions[captionIndex];
				currentCaption = c.text;
				if (on) {
					// show it
					getCaptionView().setText(currentCaption);
					AlphaAnimation alpha = new AlphaAnimation(0, 1);
					alpha.setInterpolator(new LinearInterpolator());
					alpha.setDuration(500);
					alpha.setFillAfter(true);
					alpha.setFillBefore(true);
					alpha.setFillEnabled(true);
					getCaptionView().startAnimation(alpha);
				}

				shown = true;
				handler.postAtTime(this, audioPlayerStartTime + c.endTime);
			} else {
				// hide it
				if (on) {
					AlphaAnimation alpha = new AlphaAnimation(1, 0);
					alpha.setInterpolator(new LinearInterpolator());
					alpha.setDuration(500);
					alpha.setFillAfter(true);
					alpha.setFillBefore(true);
					alpha.setFillEnabled(true);
					getCaptionView().startAnimation(alpha);
				}

				shown = false;
				captionIndex++;
				
				//check if we are beyond our bounds yet..if so, stop this
				if(captionIndex >= captions.length)
				{
					stop();
				}
				else
				{		
					Caption c = captions[captionIndex];
					handler.postAtTime(this, audioPlayerStartTime + c.startTime);
				}
			}
		}
		
		public void toggleOnOff() {
			boolean newOn = captionsAreOn();
			if (shown) {
				if (newOn && !on) {
					AlphaAnimation alpha = new AlphaAnimation(1, 1);
					alpha.setInterpolator(new LinearInterpolator());
					alpha.setDuration(0);
					alpha.setFillAfter(true);
					alpha.setFillBefore(true);
					alpha.setFillEnabled(true);
					getCaptionView().setText(currentCaption);
					getCaptionView().startAnimation(alpha);
				} else if (on && !newOn) {
					if (captionView != null) {
						AlphaAnimation alpha = new AlphaAnimation(0, 0);
						alpha.setInterpolator(new LinearInterpolator());
						alpha.setDuration(0);
						alpha.setFillAfter(true);
						alpha.setFillBefore(true);
						alpha.setFillEnabled(true);
						captionView.startAnimation(alpha);
					}
				}
			}
			
			 on = newOn;
		}
		
		public void stop() {
			if (handler != null) {
				handler.removeCallbacks(captionPlayer);
				handler = null;
			}
		}
	}	
	
	public interface OnViewReadyListener {
		public void onViewReady();
	}
	
	public ContentViewControllerBase(Context ctx) {
		super();
		this.context = ctx;
		db = ContentDBHelper.instance(ctx);
		userDb = UserDBHelper.instance(ctx);
	}
	
	public void setInline(boolean isInline) {
		this.isInline = isInline;
	}
	
	public void addTitle(String title) {
		clientView.addView(makeTitleView(title));
	}
	
	public UserDBHelper getUserDB() {
		return userDb;
	}

	protected int getIntAttr(int attr) {
		TypedValue typedvalueattr = new TypedValue();
		boolean r = getContext().getTheme().resolveAttribute(attr, typedvalueattr, true);
		if (!r) {
			Log.d(TAG,"getResourceAttr couldn't resolve attr "+attr);
		}
		return typedvalueattr.data;
	}
	
	protected int getColorAttr(int attr) {
		int rid = getResourceAttr(attr);
		return getContext().getResources().getColor(rid);		
	}

	protected boolean getBooleanAttr(int attr) {
		int value = getIntAttr(attr);
		return value != 0;
	}

	public int getResourceAttr(int attr) {
		return getResourceAttr(getContext(), attr);
	}

	static public int getResourceAttr(Context ctx, int attr) {
		TypedValue typedvalueattr = new TypedValue();
		boolean r = ctx.getTheme().resolveAttribute(attr, typedvalueattr, true);
		if (!r) {
			Log.d(TAG,"getResourceAttr couldn't resolve attr "+attr);
		}
		return typedvalueattr.resourceId;
	}

	protected float getDimAttr(int attr) {
		TypedValue typedvalueattr = new TypedValue();
		getContext().getTheme().resolveAttribute(attr, typedvalueattr, true);
		return typedvalueattr.getDimension(getContentResources().getDisplayMetrics());
	}

	public void setDefaultChildPadding(View v) {
		v.setPadding((int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft), 0, (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight), 0);
	}

	public float dipsToPixels(float dips) {
		DisplayMetrics dm = getContentResources().getDisplayMetrics();
		return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dips, dm);
	}
	
	public View makeTitleView(String title) {
		this.title = title;
		LayoutInflater inflater = LayoutInflater.from(getContext());
		TextView titleView = (TextView)inflater.inflate(gov.va.daelib.R.layout.title_view, clientView, false);
//		TextView titleView = new TextView(getContext());
//		titleView.setTextAppearance(getContext(), getResourceAttr(R.attr.textAppearanceLarge));
		titleView.setText(title);
//		titleView.setPadding((int)getDimAttr(R.attr.listPreferredItemPaddingLeft), 0, (int)getDimAttr(R.attr.listPreferredItemPaddingRight), 0);
//		titleView.setTextColor(0xFFFFFFFF);
//		titleView.setShadowLayer(1, 1, 1, 0xFF000000);
//		titleView.setTextSize(24);
//		titleView.setTypeface(titleView.getTypeface(), Typeface.BOLD);
//		titleView.setGravity(Gravity.CENTER);
//		LinearLayout.LayoutParams layout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);

//		DisplayMetrics dm = getContentResources().getDisplayMetrics();
//		int margin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm);

//		layout.setMargins(margin,0,margin,margin);
//		layout.gravity = Gravity.CENTER;
//		titleView.setLayoutParams(layout);
        titleView.setContentDescription(title+" title");
		return titleView;
	}
/*
	public Drawable getBackground() {
		if (isInline()) return null;
		return Util.makeDrawable(getContext(), "table_bg_darker.png", true);
	}
*/
	public boolean captionsAreOn() {
		UserDBHelper db = UserDBHelper.instance(getContext());
		String cc = db.getSetting("cc");
		return "true".equals(cc);
	}
	
	public void toggleCC() {
		UserDBHelper db = UserDBHelper.instance(getContext());
		String cc = db.getSetting("cc");
		if ("true".equals(cc)) {
			db.setSetting("cc", "false");
		} else {
			db.setSetting("cc", "true");
		}
		
		if (captionPlayer != null) {
			captionPlayer.toggleOnOff();
		}
	}

	public void setOnViewReadyListener(OnViewReadyListener listener) {
		if ((rootView != null) && (contentsToLoad == 0)) {
			listener.onViewReady();
		} else {
			this.listener = listener;
		}
	}
	
	public void setNavigator(ContentViewControllerBase parentController) {
		this.parentController = parentController;
	}
	
	public ContentViewControllerBase getNavigator() {
		return parentController;
	}
	/*
	public void pushContent(Content c) {
		getNavigator().pushViewForContent(c);
	}
	 */
	public boolean hasCaptions() {
		return getCaptions().length > 0;
	}
	
	public CaptionView getCaptionView() {
		if (captionView == null) {
			FrameLayout captionParent = new FrameLayout(getContext());
			FrameLayout.LayoutParams params = new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
			DisplayMetrics dm = getContentResources().getDisplayMetrics();
			int margin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 60, dm);
			params.bottomMargin = margin;
			params.gravity = Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM;
			captionView = new CaptionView(getContext());

			captionParent.addView(captionView, params);
			params = new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT);
			rootView.addView(captionParent);
			
			AlphaAnimation alpha = new AlphaAnimation(0, 0);
			alpha.setInterpolator(new LinearInterpolator());
			alpha.setDuration(0);
			alpha.setFillAfter(true);
			alpha.setFillBefore(true);
			alpha.setFillEnabled(true);
			captionView.startAnimation(alpha);
		}
		
		return captionView;
	}

	public Map<String,Object> getVariables() {
		TreeMap<String,Object> vars = new TreeMap<String, Object>();
		getVariables(vars);
		return vars;
	}

	public void clearVariable(String name) {
		setVariable(name,null);
	}

    public void variablesChanged() {
        if (rootView != null) {
            rootView.requestLayout();
        }
        for (ContentViewControllerBase cvc : getChildControllers()) {
            cvc.variablesChanged();
        }
    }

	public void setLocalVariable(String name, Object value) {
		if (localVariables == null) localVariables = new TreeMap<String, Object>();
		localVariables.put(name, value);
        variablesChanged();
	}

	public void setVariable(String name, Object value) {
		if (getNavigator() != null) {
			getNavigator().setVariable(name, value);
			return;
		}

		setLocalVariable(name, value);
	}

	public String getVariableAsString(String name) {
		Object val = getVariable(name);
		return (val == null) ? null : val.toString();
	}
	
	public Object getVariable(String name) {
		Object value = null;
		
		if (localVariables != null) {
			value = localVariables.get(name);
		}
		
		if (value == null) {
			if (getNavigator() != null) {
				value = getNavigator().getVariableForChild(name,this);
			} else {
				value = userDb.getSetting(name);
			}
		}
		
		return value;
	}

	public Object getVariableForChild(String name, ContentViewControllerBase from) {
		return getVariable(name);
	}

	public Map<String, Object> getLocalVariables() {
		return localVariables;
	}
	
	public void getVariables(Map<String,Object> vars) {
		if (getNavigator() != null) {
			getNavigator().getVariablesForChild(vars,this);
		} else {
			userDb.getSettings(vars);
		}
		if (localVariables != null) vars.putAll(localVariables);
	}

	public void getVariablesForChild(Map<String,Object> vars, ContentViewControllerBase from) {
		getVariables(vars);
	}

	public Caption[] getCaptions() {
		if (captions == null) {
			captions = getContent().getCaptions();
			Log.v("PTSD", "Caption count: " + captions.length);
			
		}
		
		return captions;
	}

	public void stopAudio() {
		TtsContentProvider.stopSpeech(this);

		if (audioPlayer != null) {
			audioPlayer.stop();
			audioPlayer = null;
		}

		if (captionPlayer != null) {
			captionPlayer.stop();
			captionPlayer = null;
		}
	}
	
	public boolean playAudio() {
		TtsContentProvider.stopSpeech(this);
		if (audioPlayer != null) {
			audioPlayer.stop();
			audioPlayer = null;

			if (captionPlayer != null) {
				captionPlayer.stop();
				captionPlayer = null;
			}

			return false;
		}
		
		audioPlayer = new MediaPlayer();
		audioPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
			@Override
			public boolean onError(MediaPlayer mp, int what, int extra) {
				// TODO Auto-generated method stub
				return false;
			}
		});

		AssetFileDescriptor fd = getContent().getAudio();
		
		if (fd == null) {
			audioPlayer = null;
			return false;
		}
		
		try {
			audioPlayer.setDataSource(fd.getFileDescriptor(),fd.getStartOffset(),fd.getLength());
			fd.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		audioPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
		audioPlayer.setVolume(1, 1);
		try {
			audioPlayer.prepare();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		if (hasCaptions()) {
			captionPlayer = new CaptionPlayer();
		}
		
		if (audioPlayer != null) {
			audioPlayer.start();
			audioPlayerStartTime = SystemClock.uptimeMillis();
			if (captionPlayer != null) {
				captionPlayer.start();
			}
			return true;
		}
		
		return false;
	}

	public void onViewReady() {
		AccessibilityManager mgr = (AccessibilityManager)getContext().getSystemService(Context.ACCESSIBILITY_SERVICE);
        /*
		if (mgr.isEnabled()) {
			speakSpokenText();		
		}
		*/
		if (listener != null) {
			listener.onViewReady();
			listener = null;
		}
		
	}

	public void parentActivityPaused() {
		
	}
	
	public static void fillWebViewWithContent(WebView wv, Content c) {
		String html = String.format(webviewFormat, c.getMainText());
		wv.loadDataWithBaseURL("file:///android_asset/",html, "text/html", "utf-8", null);
	}

	public String replaceVariables(String text) {
		while (true) {
			Matcher matcher = VARIABLE_PATTERN.matcher(text);
			if (matcher.find()) {
				String var = matcher.group(1);
				Object value = getVariable(var);
				if (value == null) {
					value = UserDBHelper.instance(getContext()).getSetting(var);
					if (value == null) {
						value = "(value of '"+var+"')";
					}
				}
				int start = matcher.start();
				int end = matcher.end();
				text = text.substring(0, start) + value + text.substring(end);
			} else {
				break;
			}
		}
		
		return text;
	}

	public void speakBlock(String msg) {
		msg = msg.replace("\r\n", " ");
		
		BreakIterator iterator = BreakIterator.getSentenceInstance(Locale.US);
		iterator.setText(msg);
		int start = iterator.first();
		
		ArrayList<String> lines = new ArrayList<String>();
		for (int end = iterator.next(); end != BreakIterator.DONE; start = end, end = iterator.next()) {
			lines.add(msg.substring(start, end));
		}

		String _title = this.title;
		if (_title != null) {
			_title = _title.replace("PTSD","P T S D");
			TtsContentProvider.speak(this, _title.trim(), TextToSpeech.QUEUE_ADD);
		}

		for (int i=0;i<lines.size();i++) {
			String line = lines.get(i);
			line = line.replace("PTSD","P T S D");
			line = line.replace("VA ","V A ");
			TtsContentProvider.speak(this, line.trim(), TextToSpeech.QUEUE_ADD);
		}
		Log.d("tts","done with queuing full page");
	}
	
	public boolean trySpeech(String message) {
		if (message.startsWith("deliverText:")) {			
			int startAt = message.lastIndexOf('}');
			if (startAt == -1) 
				startAt = 12;
			else
				startAt++;
			String msg = message.substring(startAt).trim();
			speakBlock(msg);
			return true;
		} else if (message.startsWith("speak:")) {
			String msg = message.substring(6).trim();
			TtsContentProvider.stopSpeech(this);
			TtsContentProvider.speak(this, msg, TextToSpeech.QUEUE_FLUSH);
			return true;
		}
		
		return false;
	}
	/*
	static WebChromeClient wcc = new WebChromeClient() {
		@Override
		public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
			if (trySpeech())
				return true;
			}
			return super.onJsAlert(view, url, message, result);
		}
	};
*/	
	public void incrementContentLoadingCount() {
		contentsToLoad++;
	}
	
	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public void forceSoftwareLayer(View target) {
		ContentViewControllerBase cvc = this;
		while (cvc.isInline) {
			cvc = cvc.getNavigator();
		}
		cvc.rootView.setLayerType(WebView.LAYER_TYPE_SOFTWARE, null);
		if (target != null) {
			target.setLayerType(View.LAYER_TYPE_NONE, null);
		}
	}

    public WebView createWebView(String htmlBody) {
        return createWebView(htmlBody,false);
    }

    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
	public WebView createWebView(String htmlBody, boolean scrollable) {
		DisplayMetrics dm = getContentResources().getDisplayMetrics();
		htmlBody = replaceVariables(htmlBody);

		TextView tv = new TextView(getContext());
//		tv.setTextAppearance(getContext(), getResourceAttr(R.attr.textAppearance));
		String textColor = String.format("#%06X", (0xFFFFFF & tv.getCurrentTextColor()));
//		String fontFamily = "Helvetica"; 
		String fontSize = ""+(tv.getTextSize() / dm.density)+"px";
		
		String html = String.format(webviewFormat, textColor, fontSize, htmlBody);

		final WebView wv = new WebView(getContext());
		wv.setFocusable(false);
		lastWebView = wv;

		WebSettings webSettings = wv.getSettings();
		webSettings.setNeedInitialFocus(false);
		webSettings.setAllowFileAccess(true);
		webSettings.setDatabaseEnabled(true);
		webSettings.setLayoutAlgorithm(LayoutAlgorithm.NARROW_COLUMNS);
  		webSettings.setJavaScriptEnabled(Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT);

        wv.setBackgroundColor(0x00000000);
		wv.setBackgroundDrawable(null);
		
		forceSoftwareLayer(wv);

        if (!scrollable) {
            wv.setHorizontalScrollBarEnabled(false);
	    	wv.setVerticalScrollBarEnabled(false);
        }

		wv.addJavascriptInterface(new JSInterface(), "ptsdcoach");
//		wv.setWebChromeClient(wcc);

		LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);

        if (scrollable) p.height = LayoutParams.MATCH_PARENT;

		p.gravity = Gravity.CENTER;
//		p.rightMargin = p.leftMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm);
		p.topMargin = p.bottomMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5, dm);
		p.leftMargin = (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft);
		p.rightMargin = (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight);
		wv.setLayoutParams(p);

//		wv.setPadding((int)getDimAttr(R.attr.listPreferredItemPaddingLeft), 0, (int)getDimAttr(R.attr.listPreferredItemPaddingRight), 0);
		
		incrementContentLoadingCount();
		incrementContentLoadingCount();

		wv.setPictureListener(new WebView.PictureListener() {
			@Override
			public void onNewPicture(WebView view, Picture picture) {
				int top = wv.getTop();
				int bottom = wv.getBottom();
				int left = wv.getLeft();
				int right = wv.getRight();
				viewLoaded();
			}
		});
		
		final String strippedHtml = html.replaceAll("<style>(.|\n)*?</style>", "").replaceAll("<script(.|\n)*?</script>", "").replaceAll("<(.|\n)*?>", "");

		wv.setWebViewClient(new WebViewClient() {

			@Override
			public void onPageFinished(WebView view, String url) {
				wv.setBackgroundColor(0x00000000);
				wv.setBackgroundDrawable(null);
				wv.setLayerType(WebView.LAYER_TYPE_SOFTWARE, null);
				view.loadUrl("javascript:PFC_countLinks()");
				// TODO Auto-generated method stub
				super.onPageFinished(view, url);
			}

			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				url = URLDecoder.decode(url);
				if (url.startsWith("log:")) {
					Log.d("ptsdfamilycoach",url.substring(4));
				} else if (url.startsWith("content:")) {
					String contentName = url.substring(8);
					while (contentName.startsWith("/")) contentName = contentName.substring(1);
					navigateToContentName(contentName);
				} else if (url.startsWith("linkcount:")) {
					int linkcount = Integer.parseInt(url.substring(10));
					if (linkcount > 0) view.setFocusable(true);
					else addSpokenText(strippedHtml);
					viewLoaded();
				} else if (!trySpeech(url)) {
					getContext().startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
				}
				return true;
			}
		});
	
		wv.loadDataWithBaseURL("file:///android_asset/",html, "text/html", "utf-8", null);

		return wv;
	}
	
	public void addSpokenText(String text) {
		if (spokenText == null) spokenText = text;
		else spokenText = spokenText + " " + text;
	}
	
	public void speakSpokenText() {
		stopAudio();
		
		if ((getContent() != null) && getContent().hasAudio()) {
			if (playAudio()) return;
		}
		
		if (spokenText != null) speakBlock(spokenText);
	}
	  
	public void buttonTapped(int id) {
		getNavigator().buttonTapped(id);
	}
	
	public void handleButtonTap(int id) {
		// Do nothing
	}

	public void setSelectedContent(Content selectedContent) {
		this.selectedContent = selectedContent;
	}	

	public Content getContent() {
		return content;
	}

	public void unblockInput() {
		blocked = false;
	}

	public void blockInput() {
		blocked = true;
	}
	
	public class RootView extends FrameLayout {
		
		public RootView(Context ctx) {
			super(ctx);
			setBackgroundColor(0);
			setBackgroundDrawable(null);
		}

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);
            if (dynamicPredicate != null) {
                if (!evalJavascriptPredicate(dynamicPredicate)) {
                    int width = getMeasuredWidth();
                    setMeasuredDimension(width,0);
                }
            }
        }

        @Override
		public boolean dispatchTouchEvent(MotionEvent ev) {
			if (blocked) return true;
			return super.dispatchTouchEvent(ev);
		}

		@Override
		protected void onAttachedToWindow() {
			super.onAttachedToWindow();
			timeAppeared = System.currentTimeMillis();
			unblockInput();
		}

    }
	
	public String checkPrerequisites() {
		return null;
	}
	
	public void addButtonAsActionItems(Menu menu, View v) {
		if (v instanceof ImageButton) {
			final LoggingImageButton b = (LoggingImageButton)v;
			MenuItem item = menu.add("CC");
			item.setIcon(b.getDrawable());
			item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
			item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
				public boolean onMenuItemClick(MenuItem item) {
					return b.performClick();
				}
			});
		} else if (v instanceof LoggingButton) {
			final LoggingButton b = (LoggingButton)v;
			MenuItem item = menu.add(b.getText());
			item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS | MenuItem.SHOW_AS_ACTION_WITH_TEXT);
			item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
				public boolean onMenuItemClick(MenuItem item) {
					return b.performClick();
				}
			});
		}
	}
	
	public boolean gatherOptions(ContentEvent event) {
		if (content == null) return false;
		final Content left = content.getChildByName("@left");
		Content _help = content.getSingleReference("help");
		if (_help == null) _help = content.getChildByName("@help");
		final Content help = _help;
		if (left != null) {
			if (event.menu != null) {
				android.view.MenuItem item = event.menu.add(left.getDisplayName());
				item.setIcon(left.getIcon());
				item.setOnMenuItemClickListener(new android.view.MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(android.view.MenuItem item) {
						contentSelected(left);
						return true;
					}
				});
				event.booleanResult = true;
			} else {
				MenuItem item = event.sherlockMenu.add(left.getDisplayName());
				Drawable d = left.getIcon();
				if (d != null) {
					d = d.mutate();
					d.setColorFilter(getColorAttr(R.attr.textColorPrimary),Mode.MULTIPLY);
					item.setIcon(d);
				}
				item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(MenuItem item) {
						contentSelected(left);
						return true;
					}
				});
				item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
				event.booleanResult = true;
			}
		}
		if (help != null) {
			String name = "Help";
			if (event.menu != null) {
				android.view.MenuItem item = event.menu.add(name);
				item.setIcon(getResourceAttr(gov.va.daelib.R.attr.contentHelpIcon));
				item.setOnMenuItemClickListener(new android.view.MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(android.view.MenuItem item) {
						contentSelected(help);
						return true;
					}
				});
				event.booleanResult = true;
			} else {
				MenuItem item = event.sherlockMenu.add(name);
				item.setIcon(getResourceAttr(gov.va.daelib.R.attr.contentHelpIcon));
				item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(MenuItem item) {
						contentSelected(help);
						return true;
					}
				});
				item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
				event.booleanResult = true;
			}
		}
/*			
		if (event.sherlockMenu != null) {
			if (rightButtons != null) {
				for (int i=0;i<rightButtons.getChildCount();i++) {
					View v = (View)rightButtons.getChildAt(i);
					addButtonAsActionItems(event.sherlockMenu,v);
				}
			}
			if (leftButtons != null) {
				for (int i=0;i<leftButtons.getChildCount();i++) {
					View v = (View)leftButtons.getChildAt(i);
					addButtonAsActionItems(event.sherlockMenu,v);
				}
			}
		}
*/			
		event.booleanResult = true;
		return false;
	}
	
	public boolean dispatchContentEvent(ContentEvent event) {
		if (event.eventType == ContentEvent.Type.BACK_BUTTON) {
			final Content backChild = content.getChildByName("@back");
			if (backChild != null) {
				String confirmationMsg = backChild.getStringAttribute("confirmation");
				if (confirmationMsg != null) {
					AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
					builder.setTitle("Confirmation");
					builder.setMessage(confirmationMsg);
					builder.setNegativeButton("Never mind", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
						}
					});
					builder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
						@Override
						public void onClick(DialogInterface dialog, int which) {
							contentSelected(backChild);
						}
					});
					builder.show();
				} else {
					contentSelected(backChild);
				}
				return true;
			}
			
			return false;
		}
		
		if (event.eventType == ContentEvent.Type.GATHER_OPTIONS) {
			return gatherOptions(event);
		}
		
		return false;
	}
	
	public ContentActivity getContentActivity() {
		return (ContentActivity)getContext();
	}
	
	public void startActivityForResult(Intent intent, final ActivityResultListener listener) {
		getContentActivity().startActivityForResult(intent, listener);
	}

	public void startActivity(Intent intent) {
		getContentActivity().startActivityForResult(intent, null);
	}

	static Pattern looksLikeHTML = null;

    public View makeTextView(String text) {
        return makeTextView(text,false);
    }

    public View makeTextView(String text, boolean scrollable) {
		if (text.contains("<img") || text.contains("<li>") || text.contains("<script") || text.contains("<a ") || text.contains("style=\"")) {
			WebView wv = createWebView(text,scrollable);
			return wv;
		} else {
			DisplayMetrics dm = getContentResources().getDisplayMetrics();
			TextView tv = new TextView(getContext());
			text = replaceVariables(text);
			text = text.trim().replaceAll("\\p{Space}+", " ");
			tv.setText(Html.fromHtml(text));
			tv.setPadding((int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft), 0, (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight), 0);
			LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
//			p.rightMargin = p.leftMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm);
			p.topMargin = p.bottomMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5, dm);
			tv.setLayoutParams(p);
			return tv;
		}
	}
	
	public void registerAction(String name, Method actionMethod) {
		if (actions == null) actions = new TreeMap<String, Method>();
		actions.put(name, actionMethod);
	}

	public void registerAction(String name) {
		try {
			Method m = this.getClass().getMethod(name, Content.class);
			registerAction(name,m);
		} catch (Exception e) {
			Log.e("daelib", "BAD ACTION REGISTRATION");
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}

	public boolean performActionFromChild(String action, Content source, ContentViewControllerBase child) {
		if (tryPerformAction(action, source)) return true;
		if (getNavigator() != null) {
			return getNavigator().performActionFromChild(action, source, this);
		}
		return false;
	}

	public boolean performAction(String action, Content source) {
		if (tryPerformAction(action, source)) return true;
		if (getNavigator() != null) {
			return getNavigator().performActionFromChild(action, source, this);
		}
		return false;
	}

	public Object evalJavascript(String js) {
		return Util.evalJavascript(js, this);
	}

	public boolean evalJavascriptPredicate(String js) {
		return Util.evalJavascriptPredicate(js, this);
	}

    public Record getBinding() {
        ContentViewControllerBase p = parentController;
        if (p == null) return null;
        return p.getBinding();
    }

	public boolean tryPerformAction(String action, Content source) {
		if (actions != null) {
			Method method = actions.get(action);
			if (method != null) {
				try {
					method.invoke(this, source);
				} catch (Exception e) {
					e.printStackTrace();
				}
				
				return true;
			}
		}
		
		if (action.equals("pop")) {
			goBack();
			return true;
		}
		
	    if (action.equals("next")) {
	    	navigateToNext();
	        return true;
	    }

	    if (action.startsWith("js:")) {
	    	String s = action.substring(3);
	    	evalJavascript(s);
	        return true;
	    }
		
		for (ContentViewControllerBase child : childContentControllers) {
			if (child.tryPerformAction(action, source)) {
				return true;
			}
		}
		
		return false;
	}

	public void addText(String text) {
		clientView.addView(makeTextView(text,false));
	}

	public void addContentView(View view) {
		clientView.addView(view);
	}

	public String getContentMainText() {
		return content.getMainText();
	}

	public List<ContentViewControllerBase> getChildControllers() {
		return childContentControllers;
	}
	
	public final boolean navigateToChildController(ContentViewControllerBase cvc) {
		return navigateToChildControllerWithData(cvc,null);
	}

    public boolean navigateToChildControllerWithData(ContentViewControllerBase cvc, Object data) {
        return false;
    }

    public final boolean navigateToContentAtPath(List<Content> path, int startingAt) {
        return navigateToContentAtPathWithData(path,startingAt, null);
    }

    public boolean navigateToContentAtPathWithData(List<Content> path, int startingAt, Object data) {
		Content content = path.get(startingAt);
		for (ContentViewControllerBase cvc : getChildControllers()) {
			if (cvc.getContent().equals(content)) {
				boolean r = navigateToChildController(cvc);
				if (!r) return r;
				if (path.size() > startingAt+1) {
					return cvc.navigateToContentAtPathWithData(path, startingAt+1,data);
				}
				return r;
			}
		}
		
		return false;
	}

    public final boolean navigateToContentName(String name) {
        return navigateToContentNameWithData(name,null);
    }

    public boolean navigateToContentNameWithData(String name, Object data) {
		Content target = content.getChildByName(name);
		if (target != null) {
			contentSelected(target);
			return true;
		}
		
		if (isInline() && (getNavigator() != null)) {
			return getNavigator().navigateToContentNameWithData(name, data);
		}
		
		target = db.getContentForName(name);
		if (target != null) {
			return navigateToContentWithData(target,data);
		}
		
		return false;
	}

	public boolean goBack() {
		return goBack(false);
	}

	public boolean goBack(boolean immediate) {
		if (getNavigator() != null) {
			return getNavigator().goBackFrom(this,immediate);
		}
		return false;
	}

	public boolean goBackFrom(ContentViewControllerBase cv) {
		return goBackFrom(cv,false);
	}

	public boolean goBackFrom(ContentViewControllerBase cv, boolean immediate) {
		if (getNavigator() != null) {
			return getNavigator().goBackFrom(this,immediate);
		}
		return false;
	}

	public boolean navigateToNextFrom(ContentViewControllerBase next, ContentViewControllerBase from, boolean removeOriginal) {
		if (getNavigator() != null) {
			return getNavigator().navigateToNextFrom(next,this,removeOriginal);
		}
		return false;
	}

	public boolean navigateToNextContent(Content next) {
		return navigateToNext(next.createContentView(getNavigator(),getContext()));
	}

	public boolean navigateToNext() {
		return navigateToNext(null);
	}

	public boolean navigateToNext(ContentViewControllerBase next) {
		return  navigateToNext(next,false);
	}

	public boolean navigateToNext(ContentViewControllerBase next, boolean removeOld) {
		if (next == null) {
			Content nextContent = getContent().getNext();
			if (nextContent != null) {
				next = nextContent.createContentView(getNavigator(),getContext());
			}
		}
		
		if (getNavigator() != null) {
			return getNavigator().navigateToNextFrom(next,this,removeOld);
		}
		return false;
	}
	
	public void startContentActivity(Content c) {
		Intent intent = new Intent(getContext(),ContentActivity.class);
		intent.setData(Uri.parse("contentID:"+c.getID()));
		startActivity(intent);
	}

    public final boolean navigateToContent(Content c) {
        return navigateToContentWithData(c, null);
    }

    public boolean navigateToContentWithData(Content c, Object data) {
		if (getNavigator() != null) {
			return getNavigator().navigateToContentWithData(c, data);
		} else {
			return getContentActivity().navigateToContentWithData(c, data);
		}
	}

	public void execAction(String action) {
		if (action.equals("pop")) {
			goBack();
		} else if (action.startsWith("clear:")) {
			String var = action.substring("clear:".length());
			setVariable(var, null);
		}
	}

	public void navigateToHere() {
		if (isInline()) {
			getNavigator().navigateToHere();
		} else {
			navigateToContent(content);
		}
	}

	public void contentSelected(Content c) {
		String varName = content.getStringAttribute("selectionVariable");
		Content ref = c.getRef();
		if ((ref != null) && !c.getBoolean("inlineRef")) {
			String refAction = c.getStringAttribute("refAction");
			if (refAction != null) execAction(refAction);
			navigateToContent(ref);
			return;
		}
		
		String href = c.getStringAttribute("href");
		if (href != null) {
			Intent in = new Intent(Intent.ACTION_VIEW,Uri.parse(href));
			startActivity(in);
			return;
		}
		
		String action = c.getStringAttribute("action");
		if (action != null) {
			performAction(action, c);
			return;
		}
		
		if (varName != null) {
            boolean selectOnly = getContent().getBoolean("selectOnly");
			setVariable(varName, c);
			if (selectOnly) {
				goBack();
			} else {
				navigateToNext();
			}
		} else {
			navigateToNextContent(c);
		}
	}

	public boolean isInline() {
		return isInline;
	}
	
	public void setContent(Content content) {
		this.content = content;
	}

	public void resetApp(Content source) {
		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
	    String title = source.getTitle();
	    String mainText = source.getMainText();
	    builder.setTitle(title);
	    builder.setMessage(mainText);
	    builder.setNegativeButton("No, cancel", null);
	    builder.setPositiveButton("Yes, reset", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				getUserDB().resetAppData();
				getContentActivity().setResult(-1);
				getContentActivity().finish();
			}
		});

		builder.show();
	}

	public void clearToolPrefs(Content source) {
		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
	    String title = "Confirm Clear Tool Preferences";
	    String mainText = "This will clear all per-tool \"thumbs up\" and \"thumbs down\" preferences you've selected.  Are you sure?";
	    builder.setTitle(title);
	    builder.setMessage(mainText);
	    builder.setNegativeButton("No, cancel", null);
	    builder.setPositiveButton("Yes, clear them", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				getUserDB().resetTools();
			}
		});

		builder.show();
	}

	public ViewGroup createView() {
		if (rootView == null) {
			registerAction("resetApp");
			registerAction("clearToolPrefs");
			
			rootView = new RootView(getContext());
			rootView.setId(allocDynamicViewID());
			build();

			if ((buttonBar != null) && (buttonBar.getParent() == null)) {
				if (shouldAddButtonsInScroller()) {
					clientView.addView(buttonBar);
				} else {
					topView.addView(buttonBar);
				}
			}
			
			if ((listener != null) && (contentsToLoad == 0)) {
				listener.onViewReady();
				listener = null;
			}
		}
		return rootView;
	}
	
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		return createView();
	}

	public ViewGroup getView() {
		return createView();
	}

    public void navigationDataReceived(Object data) {
    }

	public void swapInChildController(ViewGroup container, ContentViewControllerBase child) {
		container.removeAllViews();
		container.addView(child.getView(),0);
	}

	public void addChildControllerView(ViewGroup container, ContentViewControllerBase child) {
		if (container == child.getView().getParent()) return;
		container.addView(child.getView(),0);
	}

	public void removeChildControllerView(ContentViewControllerBase child) {
		View v = child.getView();
		ViewParent p = v.getParent();
		if (p instanceof ViewGroup) {
			ViewGroup vg = (ViewGroup)p;
			vg.removeView(v);
		}
	}

	public void buildClientViewFromContent() {
		if (content != null) {
			String onload = content.getStringAttribute("onload");
		    if (onload != null) {
		    	evalJavascript(onload);
		    }

			
			for (Map.Entry<String,Object> entry : content.getAttributes().entrySet()) {
				if (entry.getKey().startsWith("variable_")) {
					String key = entry.getKey().substring("variable_".length());
					String value = entry.getValue().toString();
					getNavigator().setVariable(key,value);
				}
			}
			
			String title = content.getTitle();
			if (!isInline() && (title != null)) {
				if (!content.getBoolean("hideInlineTitle")) {
					clientView.addView(makeTitleView(title));
				}
			}

			Drawable image = content.getImage();
			if (image != null) {
				int height = image.getIntrinsicHeight();
				int width = image.getIntrinsicWidth();
				float scaledHeight = height;
				float scaledWidth = width;
				int maxHeight = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 150, getContentResources().getDisplayMetrics());
				if (scaledHeight > maxHeight) {
					scaledHeight = maxHeight;
					scaledWidth = (scaledHeight / height) * width;
				}
				image.setBounds(0, 0, (int)scaledWidth, (int)scaledHeight);

				ImageView imageView = new ImageView(getContext());
				imageView.setImageDrawable(image);

				LinearLayout.LayoutParams layout = new LinearLayout.LayoutParams((int)scaledWidth,(int)scaledHeight);
				int padding = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, getContentResources().getDisplayMetrics());
				imageView.setPadding(padding, padding, padding, padding);
				layout.gravity = Gravity.CENTER;
				imageView.setLayoutParams(layout);
				clientView.addView(imageView);
			}

            String text = getContentMainText();
            boolean letMainTextScroll = false;

/*
            if ((text != null) && (image == null)) {
                letMainTextScroll = true;
                for (Content child : content.getAllChildren()) {
                    if ("@button".equals(child.getName())) continue;
                    letMainTextScroll = false;
                    break;
                }
                if (letMainTextScroll) {
                    clientView.addView(makeTextView(text,true));
                }
            }
*/

            if ((text != null) && !letMainTextScroll) {

				if(hasAudioLink() && shouldAddListenButton())
				{
					LinearLayout.LayoutParams params;
					params = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
					params.setMargins(10, 10, 5, 10);
							
					final LoggingButton button = addButton("Listen");
					button.setLayoutParams(params);
					button.setOnClickListener(new OnClickListener() {
						public void onClick(View v) {
							if (audioPlayer != null) {
								audioPlayer.stop();
								audioPlayer = null;
								button.setText("Listen");
							} else {
								playAudio();
								audioPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
									@Override
									public void onCompletion(MediaPlayer mp) {
										button.setText("Listen");
									}
								});
								button.setText("Stop Listening");
							}
						}
					});
				}
					
				addText(text);
//				Log.v("PTSD","text content=" + text);
			}
			
			for (final Content child : content.getAllChildren()) {
				if ("@button".equals(child.getName())) {
					LoggingButton b = addButton(child.getDisplayName());
					String enablement = child.getStringAttribute("enablement");
					if (enablement != null) {
						b.setEnablement(enablement,this);
					}
					b.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							contentSelected(child);
						}
					});

                    if ("inline".equals(child.getStringAttribute("disposition"))) {
                        ((ViewGroup)b.getParent()).removeView(b);
                        clientView.addView(b,new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                    }
				} else if ("inline".equals(child.getStringAttribute("disposition")) || "@inline".equals(child.getName())) {
					String predicate = child.getStringAttribute("predicate");
					if (predicate != null) {
						boolean result = evalJavascriptPredicate(predicate);
						if (!result) continue;
					}
					ContentViewControllerBase cv = child.createInlineContentView(this,getContext());
					cv.setNavigator(this);
					addChildController(cv);
					incrementContentLoadingCount();
					cv.setOnViewReadyListener(new OnViewReadyListener() {
						public void onViewReady() {
							viewLoaded();
						}
					});
                    clientView.addView(cv.getView());
					if (cv.hasRightButtons()) {
						while (cv.getRightButtons().getChildCount() > 0) {
							View v = cv.getRightButtons().getChildAt(0);
							cv.getRightButtons().removeView(v);
							getRightButtons().addView(v);
						}
					}
					if (cv.hasLeftButtons()) {
						while (cv.getLeftButtons().getChildCount() > 0) {
							View v = cv.getLeftButtons().getChildAt(0);
							cv.getLeftButtons().removeView(v);
							getLeftButtons().addView(v);
						}
					}
				}
			}
		}
	}

	public boolean shouldAddListenButton() {
		return true;
	}

	public boolean shouldUseScroller() {
		return !isInline();
	}

	public void build() {
		topView = new LinearLayout(getContext());
		topView.setOrientation(LinearLayout.VERTICAL);
		topView.setBackgroundColor(0);
		FrameLayout.LayoutParams topLayout = new FrameLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.FILL_PARENT);
		topView.setLayoutParams(topLayout);

		IcsLinearLayout ll = new IcsLinearLayout(getContext(), null);
		ll.setOrientation(LinearLayout.VERTICAL);
		ll.setBackgroundColor(0);
		ll.setBackgroundDrawable(null);
//		ll.setShowDividers(IcsLinearLayout.SHOW_DIVIDER_MIDDLE);
		
//		DisplayMetrics dm = getContentResources().getDisplayMetrics();
//		int padding = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5, dm);
//		ll.setPadding(padding, padding, padding, padding);
		clientView = ll;

		if (shouldUseScroller()) {
			scroller = new ScrollView(getContext());
			scroller.setFillViewport(true);
			scroller.setBackgroundColor(0);
			scroller.setHorizontalScrollBarEnabled(false);
			scroller.setVerticalScrollBarEnabled(true);
			scroller.addView(clientView);

			LinearLayout.LayoutParams scrollerLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
			scrollerLayout.weight = 1;
			scroller.setLayoutParams(scrollerLayout);
			topView.addView(scroller);
		} else {
			LinearLayout.LayoutParams scrollerLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
			scrollerLayout.weight = 1;
			clientView.setLayoutParams(scrollerLayout);
			topView.addView(clientView);
		}

		if (!isInline()) {
			topView.setBackgroundResource(getResourceAttr(gov.va.daelib.R.attr.contentViewBackground));
		} else {
			topView.setBackgroundColor(0);
			topView.setBackgroundDrawable(null);
		}
		rootView.addView(topView);

        dynamicPredicate = getContent().getStringAttribute("dynamicPredicate");

		buildClientViewFromContent();
	}

	public void registerForContextMenu(View v) {
		((Activity)getContext()).registerForContextMenu(v);
	}
	
	public boolean hasAudioLink() {
		return content.hasAudio();
	}
	
	public void viewLoaded() {
		if (contentsToLoad > 0) {
			if (scroller != null) {
				scroller.fullScroll(ScrollView.FOCUS_UP);
			}

			View v1=null,v2=null,v3=null;
			ArrayList<View> list = new ArrayList<View>();
			if (leftButtons != null) {
				for (int i=0;i<leftButtons.getChildCount();i++) {
					list.add(leftButtons.getChildAt(i));
				}
			}
			if (rightButtons != null) {
				for (int i=0;i<rightButtons.getChildCount();i++) {
					list.add(rightButtons.getChildAt(i));
				}
			}

			for (View v : list) {
				v1 = v2;
				v2 = v3;
				v3 = v;
				if (v2 != null) {
					if (v1 != null) v2.setNextFocusUpId(v1.getId());
					if (v3 != null) v2.setNextFocusDownId(v3.getId());
				}
			}

			while ((v1 != null) || (v2 != null) || (v3 != null)) {
				v1 = v2;
				v2 = v3;
				v3 = null;
				if (v2 != null) {
					if (v1 != null) v2.setNextFocusUpId(v1.getId());
				}
			}

			contentsToLoad--;
			if (contentsToLoad == 0) {
				onViewReady();
			}
		}
	}

	public boolean shouldAddButtonsInScroller() {
		return false;
	}
	
	public ViewGroup getButtonBar() {
		if (buttonBar == null) {
			leftButtons = new LinearLayout(getContext());
			leftButtons.setOrientation(LinearLayout.HORIZONTAL);
			leftButtons.setGravity(Gravity.LEFT);
			LinearLayout.LayoutParams leftLayout = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.FILL_PARENT);
			leftLayout.weight = 1;
			leftButtons.setLayoutParams(leftLayout);

			rightButtons = new LinearLayout(getContext());
			rightButtons.setOrientation(LinearLayout.HORIZONTAL);
			rightButtons.setGravity(Gravity.RIGHT);
			LinearLayout.LayoutParams rightLayout = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.FILL_PARENT);
			rightLayout.weight = 1;
			rightButtons.setLayoutParams(rightLayout);
			
			buttonBar = new LinearLayout(getContext());
			buttonBar.setBackgroundColor(0);
			buttonBar.setGravity(Gravity.FILL_HORIZONTAL);
			
			buttonBar.addView(leftButtons);
			buttonBar.addView(rightButtons);

			LinearLayout.LayoutParams buttonBarLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
			buttonBarLayout.weight = 0;
			buttonBar.setLayoutParams(buttonBarLayout);
			
			if (rootView != null) {
				if (shouldAddButtonsInScroller()) {
					clientView.addView(buttonBar);
				} else {
					topView.addView(buttonBar);
				}
			}
		}
		return buttonBar;
	}

	public boolean hasLeftButtons() {
		return (leftButtons != null);
	}

	public LinearLayout getLeftButtons() {
		if (leftButtons == null) {
			getButtonBar();
		}

		return leftButtons;
	}

	public boolean hasRightButtons() {
		return (rightButtons != null);
	}
	
	public LinearLayout getRightButtons() {
		if (rightButtons == null) {
			getButtonBar();
		}
		
		return rightButtons;
	}

	public LoggingButton addButton(String text) {
		return addButton(text,-1);
	}

	public LoggingButton addButton(String text, int id) {
		return addButton(-1,text,id);
	}

	public LoggingButton addButton(int index, String text, int id) {
		LoggingButton b = new LoggingButton(getContext());
//		b.setBackgroundResource(R.drawable.button_bg);
		
//		DisplayMetrics dm = getContentResources().getDisplayMetrics();
//		int margin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, dm);
//		b.setPadding(margin, b.getPaddingTop(), margin, b.getPaddingBottom());

//		b.setMinWidth(80);
		b.setText(text);
//		b.setGravity(Gravity.CENTER);
		b.setId(id);
		if (id != -1) {
			b.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					TtsContentProvider.stopSpeech(ContentViewControllerBase.this);
					buttonTapped(v.getId());
				}
			});
			
			b.setOnFocusChangeListener(new OnFocusChangeListener() {
				@Override
				public void onFocusChange(View v, boolean hasFocus) {
					TtsContentProvider.stopSpeech(ContentViewControllerBase.this);
				}
			});
		} else {
			
		}

		if (index != -1) {
			getRightButtons().addView(b,index);
		} else {
			getRightButtons().addView(b);
		}
		return b;
	}
	
	public int getBadgeValue() {
		return 0;
	}

	public boolean hasAnyContent() {
		return true;
	}

	public String getTitle() {
		if (!isInline() && (content != null)) {
			return content.getTitle();
		}
		return null;
	}
	
	public void refreshContent() {
	}

	public void refreshContentAfterChildren() {
	}
	
	public void updateChildContentVisibility() {
		for (ContentViewControllerBase cv : childContentControllers) {
			updateContentVisibilityForChild(cv);
		}
		refreshContentAfterChildren();
	}

	public void updateContentVisibilityForChild(ContentViewControllerBase child) {
		child.setContentVisible(isContentVisible());
	}

	public void onContentBecameVisibleForFirstTime() {
	}

	public void onContentBecameVisible() {
		if (!everVisible) {
			onContentBecameVisibleForFirstTime();
			everVisible = true;
		}

		String onShow = content.getStringAttribute("onShow");
		if (onShow != null) {
			execAction(onShow);
		}
		ActivityCompat.invalidateOptionsMenu(getContentActivity());
		refreshContent();
	}

	public void onContentBecameInvisible() {
		stopAudio();
		
		long timeGone = System.currentTimeMillis();

		if (content != null) {
			{
				ContentScreenViewedEvent e = new ContentScreenViewedEvent();
				e.contentScreenId = content.getUniqueID();
				e.contentScreenName = content.getName();
				e.contentScreenDisplayName = content.getDisplayName();
				e.contentScreenTimestampStart = timeAppeared;
				e.contentScreenTimestampDismissal = timeGone;
				e.contentScreenType = viewTypeID;
				EventLog.log(e);
			}

			{
				TimePerScreenEvent e = new TimePerScreenEvent();
				e.screenId = content.getUniqueID();
				e.screenStartTime = timeAppeared;
				e.timeSpentOnScreen = timeGone - timeAppeared;
				EventLog.log(e);
			}
		}
	}

	public void onContentVisibilityChanged(boolean newVisibility) {
		if (newVisibility) {
			onContentBecameVisible();
		} else {
			onContentBecameInvisible();
		}
		updateChildContentVisibility();
	}
	
	public boolean isContentVisible() {
		return contentVisible;
	}
	
	public void setContentVisible(boolean newVisibility) {
		if (contentVisible != newVisibility) {
			contentVisible = newVisibility;
			onContentVisibilityChanged(newVisibility);
		}
	}
	
	public ContentViewControllerBase removeChildController(ContentViewControllerBase cv) {
		childContentControllers.remove(cv);
		cv.setContentVisible(false);
		return cv;
	}
	
	public void addChildController(ContentViewControllerBase cv) {
		childContentControllers.add(cv);
		updateContentVisibilityForChild(cv);
	}
	
	public boolean isHeadless() {
		return false;
	}
	
	public void exec() {
	}
	
	public Iterable<LoggingButton> allButtons() {
		ArrayList<LoggingButton> list = new ArrayList<LoggingButton>();
		ViewGroup p = getLeftButtons();
		for (int i=0;i<p.getChildCount();i++) {
			list.add((LoggingButton)p.getChildAt(i));
		}
		p = getRightButtons();
		for (int i=0;i<p.getChildCount();i++) {
			list.add((LoggingButton)p.getChildAt(i));
		}
		return list;
	}
	
	public void updateEnablements() {
		for (LoggingButton b : allButtons()) {
			b.updateEnablement(this);
		}
	}
}
