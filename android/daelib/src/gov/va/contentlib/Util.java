package gov.va.contentlib;

import gov.va.contentlib.activities.AlarmReceiver;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.content.JournalEntry;
import gov.va.contentlib.content.NamedNumber;
import gov.va.contentlib.content.PCLScore;
import gov.va.contentlib.content.Record;
import gov.va.contentlib.controllers.ContentViewController;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.daelib.R;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Member;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.mozilla.javascript.Function;
import org.mozilla.javascript.FunctionObject;
import org.mozilla.javascript.Scriptable;
import org.mozilla.javascript.ScriptableObject;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.NinePatch;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.NinePatchDrawable;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.WindowManager;

public class Util {

	static Context ctx = null;
	static HashMap<String,String> placeholderToRealAction = new HashMap<String, String>();
	static HashMap<String,Bitmap> cache = new HashMap<String, Bitmap>();
	static WindowManager windowManager = null;
	static DisplayMetrics metrics = null;
	
	static ThreadLocal<ContentViewControllerBase> currentCVC = new ThreadLocal<ContentViewControllerBase>();

	synchronized public static boolean evalJavascriptPredicate(String js, ContentViewControllerBase ctx) {
		return "true".equals(evalJavascript(js,ctx));
	}

	public static int timeSeriesCount(String seriesName) {
		return UserDBHelper.instance(currentCVC.get().getContext()).getTimeseriesCount(seriesName);
	}

	public static Long timeSeriesLastTime(String seriesName) {
		PCLScore score = UserDBHelper.instance(currentCVC.get().getContext()).getLastTimeseriesScore(seriesName);
		if (score == null) return null;
		return score.time;
	}

	public static Integer timeSeriesLastValue(String seriesName) {
		PCLScore score = UserDBHelper.instance(currentCVC.get().getContext()).getLastTimeseriesScore(seriesName);
		if (score == null) return null;
		return score.score;
	}

	public static void setSetting(String name, Object value) {
		UserDBHelper.instance(currentCVC.get().getContext()).setSetting(name,value.toString());
	}

	public static String getSetting(String name) {
		return UserDBHelper.instance(currentCVC.get().getContext()).getSetting(name);
	}

	public static long now() {
		return System.currentTimeMillis();
	}

	public static void setVariable(String name, Object value) {
		currentCVC.get().setVariable(name,value);
	}

	public static Object getVariable(String name) {
		Object o = currentCVC.get().getVariable(name);
        if (o == null) return null;
        if (o instanceof NamedNumber) {
            // XXX UGLY UGLY
            return o.toString();
        }
        return o;
	}

	public static boolean gotoContent(String name) {
		return currentCVC.get().navigateToContentName(name);
	}

	public static int countRefs(String name) {
		return UserDBHelper.instance(currentCVC.get().getContext()).countRefs(name);
	}

	public static int countChildren() {
        Record r = currentCVC.get().getBinding();
        if (r == null) return 0;
        return r.getChildren().size();
	}

	public static void addToTimeSeries(String seriesName, int value) {
		UserDBHelper.instance(currentCVC.get().getContext()).addTimeseriesScore(seriesName, System.currentTimeMillis(), value);
	}

	public static void runDelayed(int millis, Scriptable s) {
		final ContentViewControllerBase cvc = currentCVC.get();
		final Function func = (Function)s;
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				currentCVC.set(cvc);
				org.mozilla.javascript.Context cx = org.mozilla.javascript.Context.enter();
				func.call(cx, func.getParentScope(), func.getParentScope(), new Object[]{});
				org.mozilla.javascript.Context.exit();
				currentCVC.set(null);
			}
		}, millis);
	}

	public static void showAlert(org.mozilla.javascript.Context cx, final Scriptable thisObj, final Object[] args, Function funObj) {
		final ContentViewControllerBase cvc = currentCVC.get();
		AlertDialog.Builder builder = new AlertDialog.Builder(cvc.getContext());
		builder.setTitle(args[0].toString());
		builder.setMessage(args[1].toString());
		
		ArrayList<String> options = new ArrayList<String>();
		final ArrayList<Object> functions = new ArrayList<Object>();
		
		for (int i=2;i<args.length;i+=2) {
			options.add(args[i].toString());
			functions.add(args[i+1]);
		}
		
		int neg=-1,pos=-1,neutral=-1;
		
		if (args.length >= 8) {
			neg = 2;
			pos = 4;
			neutral = 6;
		} else if (args.length == 6) {
			neg = 2;
			pos = 4;
		} else if (args.length == 4) {
			neutral = 2;
		}
		
		class Listener implements DialogInterface.OnClickListener {
			final Function func;
			public Listener(Function func) {
				this.func = func;
			}
			
			@Override
			public void onClick(DialogInterface dialog, int which) {
				if (func == null) return;
				currentCVC.set(cvc);
				org.mozilla.javascript.Context cx = org.mozilla.javascript.Context.enter();
				func.call(cx, thisObj, thisObj, new Object[]{});
				org.mozilla.javascript.Context.exit();
				currentCVC.set(null);
			}
		}

		if (neg != -1) builder.setNegativeButton(args[neg].toString(), new Listener((Function)args[neg+1]));
		if (pos != -1) builder.setPositiveButton(args[pos].toString(), new Listener((Function)args[pos+1]));
		if (neutral != -1) builder.setNeutralButton(args[neutral].toString(), new Listener((Function)args[neutral+1]));

        if ((neg == -1) && (pos == -1) && (neutral == -1)) {
            builder.setPositiveButton("Ok",new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                }
            });
        }

		builder.show();
	}

	static Scriptable jsGlobalScope;
	static BindingsObject jsBindings;
	
	static class BindingsObject extends ScriptableObject {
		
		Map<String, Object> bindings;
		
		public void setBindings(Map<String, Object> bindings) {
			this.bindings = bindings;
		}
		
		@Override
		public String getClassName() {
			return "Map";
		}
		
		@Override
		public Object get(String key, Scriptable start) {
			if (key.equals("platform")) return "android";
			ContentViewControllerBase cvc = currentCVC.get();
			Object value = cvc.getVariable(key);
			if (value != null) return value;
			value = super.get(key,start);
			if ((value == null) || (value.equals(org.mozilla.javascript.UniqueTag.NOT_FOUND))) {
				return org.mozilla.javascript.Context.getUndefinedValue();
			}
			return value;
		}
	};

	
	@SuppressLint("SetJavaScriptEnabled")
	synchronized public static String evalJavascript(String js, ContentViewControllerBase ctx) {		
		if (js.startsWith("js:")) js = js.substring(3);
		currentCVC.set(ctx);
		org.mozilla.javascript.Context cx = org.mozilla.javascript.Context.enter();
		cx.setOptimizationLevel(-1);
		
		Scriptable scope = jsGlobalScope;
		
		if (scope == null) {
			scope = cx.initStandardObjects();
			jsGlobalScope = scope;
			jsBindings = new BindingsObject();
			ScriptableObject.putProperty(scope, "dae", jsBindings);
		
			try {
				ScriptableObject.putProperty(scope, "runDelayed", new FunctionObject("runDelayed", Util.class.getMethod("runDelayed", int.class, Scriptable.class), scope));
				ScriptableObject.putProperty(scope, "showAlert", new FunctionObject("showAlert", Util.class.getMethod("showAlert", org.mozilla.javascript.Context.class, Scriptable.class, Object[].class, Function.class), scope));
				ScriptableObject.putProperty(scope, "gotoContent", new FunctionObject("gotoContent", Util.class.getMethod("gotoContent", String.class), scope));
				ScriptableObject.putProperty(scope, "countRefs", new FunctionObject("countRefs", Util.class.getMethod("countRefs", String.class), scope));
				ScriptableObject.putProperty(scope, "countChildren", new FunctionObject("countChildren", Util.class.getMethod("countChildren"), scope));
				ScriptableObject.putProperty(scope, "getSetting", new FunctionObject("getSetting", Util.class.getMethod("getSetting", String.class), scope));
				ScriptableObject.putProperty(scope, "setSetting", new FunctionObject("setSetting", Util.class.getMethod("setSetting", String.class, Object.class), scope));
				ScriptableObject.putProperty(scope, "getVariable", new FunctionObject("getVariable", Util.class.getMethod("getVariable", String.class), scope));
				ScriptableObject.putProperty(scope, "setVariable", new FunctionObject("setVariable", Util.class.getMethod("setVariable", String.class, Object.class), scope));
				ScriptableObject.putProperty(scope, "timeSeriesCount", new FunctionObject("timeSeriesCount", Util.class.getMethod("timeSeriesCount", String.class), scope));
				ScriptableObject.putProperty(scope, "timeSeriesLastTime", new FunctionObject("timeSeriesLastTime", Util.class.getMethod("timeSeriesLastTime", String.class), scope));
				ScriptableObject.putProperty(scope, "timeSeriesLastValue", new FunctionObject("timeSeriesLastValue", Util.class.getMethod("timeSeriesLastValue", String.class), scope));
				ScriptableObject.putProperty(scope, "addToTimeSeries", new FunctionObject("addToTimeSeries", Util.class.getMethod("addToTimeSeries", String.class, int.class), scope));
				ScriptableObject.putProperty(scope, "now", new FunctionObject("now", Util.class.getMethod("now"), scope));
			} catch (NoSuchMethodException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		Object result = cx.evaluateString(scope, js, "dae:", 1, null);  
		String resultStr = cx.toString(result);
		org.mozilla.javascript.Context.exit();
		currentCVC.set(null);
		return resultStr;
	}
	
	public static String getAppMetaString(Context ctx, String name) {
		try {
			return ctx.getPackageManager().
		            getApplicationInfo(
		                ctx.getApplicationInfo().packageName,
		                PackageManager.GET_META_DATA
		        ).metaData.getString(name);
		} catch (Exception e) {
			return null;
		}
	}

	public static String getAppName(Context ctx) {
		return getAppMetaString(ctx,"contentAppName");
	}

	public static Intent getAlarmIntent(Context ctx) {
        return new Intent(ctx.getApplicationContext(), AlarmReceiver.class);
	}

    static Class<? extends TopContentActivity> mainActivityClass = TopContentActivity.class;
    public static void setMainActivityClass(Class<? extends TopContentActivity> klass) {
        mainActivityClass = klass;
    }

	public static Intent getNotificationIntent(Context ctx) {
        return new Intent(ctx.getApplicationContext(), mainActivityClass);
	}

	public static void addActionMapping(String loose, String tight) {
		placeholderToRealAction.put(loose,tight);
	}

	public static String getActionMapping(String loose) {
		String s = placeholderToRealAction.get(loose);
		if (s == null) {
			throw new RuntimeException("no action mapping for '"+loose+"'");
		}
		return s;
	}

	public static Drawable makeDrawable(Context ctx, String name) {
		return makeDrawable(ctx, name, false);
	}

	public static Drawable makeDrawable(Context ctx, String name, boolean useCache) {
		if (metrics == null) {
			metrics = new DisplayMetrics();
			windowManager = (WindowManager)ctx.getSystemService(Context.WINDOW_SERVICE);
			windowManager.getDefaultDisplay().getMetrics(metrics);
		}

		BitmapFactory.Options options = new BitmapFactory.Options();
		options.inScaled = false;

		Bitmap bitmap = cache.get(name);

		if (bitmap == null) {
			AssetManager assets = ctx.getAssets();
			InputStream is = null;
			String fn = name;

			if (fn.endsWith(".png")) {
				String[] comp = name.split("\\.");
				fn = comp[0]+"@2x.png";
				String path = "Content/"+fn;
				try {
					is = assets.open(path);
					options.inDensity = 320;
				} catch (IOException io) {}
			}

			if (is == null) {
				String path = "Content/"+name;
				try {
					is = assets.open(path);
					options.inDensity = 160;
				} catch (IOException io) {}
			}

			options.inTargetDensity = (int)(160*metrics.density);
			bitmap = BitmapFactory.decodeStream(is,null,options);
			if (useCache) cache.put(name, bitmap);
		}
		
		try {
			Drawable d = null;
			if (name.endsWith(".9.png")) {
				byte [] chunk = bitmap.getNinePatchChunk();
				NinePatch np = new NinePatch(bitmap, chunk, null);
				NinePatchDrawable npd = new NinePatchDrawable(ctx.getResources(),np);
				d = npd;
			} else {
				BitmapDrawable bmd = new BitmapDrawable(ctx.getResources(),bitmap);
				d = bmd;
			}
			return d;
		} catch (Exception e) {
			e.printStackTrace();
		}

		return null;
	}

}
