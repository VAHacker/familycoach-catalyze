package gov.va.contentlib.controllers;

import gov.va.contentlib.services.TtsContentProvider;
import gov.va.contentlib.views.LoggingButton;

import java.util.ArrayList;
import java.util.Map;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;

public class ContentViewController extends ContentViewControllerBase {

	static final int TAP_TO_LISTEN = 1100;

	public ContentViewController(Context ctx) {
		super(ctx);
	}
	

}
