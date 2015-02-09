package gov.va.contentlib;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.controllers.ContentViewControllerBase;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.util.HashMap;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.View;

public class Util {

	static HashMap<String,String> placeholderToRealAction = new HashMap<String, String>();
	static HashMap<String,Drawable> drawables = new HashMap<String, Drawable>();

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

	public static Drawable makeDrawable(Context ctx, String name, boolean cache) {
		Drawable d = drawables.get(name);
		if (d != null) return d;
		
		String path = "Content/"+name;
		try {
			InputStream is = ctx.getAssets().open(path);
			d = Drawable.createFromStream(is, name);
			if (cache) drawables.put(name, d);
			return d;
		} catch (IOException e) {
			e.printStackTrace();
		}

		return null;
	}

}
