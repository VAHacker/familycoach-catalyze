package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;

import java.util.ArrayList;
import java.util.List;

import android.app.AlertDialog;
import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.view.accessibility.AccessibilityManager;
import android.webkit.WebView;
import android.widget.EditText;

public class PickSafetyDestinationController extends BaseExerciseController {

	static final int ANOTHER_30_SECONDS = 701;
	
	List<EditText> fields;
	
	public PickSafetyDestinationController(Context ctx) {
		super(ctx);
	}
/*
	@Override
	public boolean shouldAddButtonsInScroller() {
		return true;
	}
*/	
	
	@Override
	public boolean navigateToNext() {
		for (EditText field : fields) {
			Editable s = field.getText();
			if ((s == null) || (s.length() == 0)) {
				AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
				builder.setTitle("Some Fields Empty");
				builder.setMessage("Please fill in the requested fields to continue.");
				builder.setPositiveButton("Ok", null);
				builder.show();
				return false;
			}
		}
		
		return super.navigateToNext();
	}
	
	@Override
	public void build() {
		super.build();
		
		List<Content> children = getContent().getChildren();
		fields = new ArrayList<EditText>();

		final UserDBHelper db = UserDBHelper.instance(getContext());
//		lastWebView.setFocusable(true);
//		lastWebView.setFocusableInTouchMode(false);
//		lastWebView.setContentDescription("");

        AccessibilityManager am = (AccessibilityManager)getContext().getSystemService(Context.ACCESSIBILITY_SERVICE);
        boolean accessibilityEnabled = am.isEnabled();

		for (Content child : children) {
			if ((child.getName() != null) && !child.getName().startsWith("@")) {
				
				WebView wv = createWebView(child.getMainText());
				wv.setFocusable(true);
				wv.setFocusableInTouchMode(false);
				clientView.addView(wv);
/*				
				TextView tv = new TextView(getContext());
				tv.setText(" "+child.getMainText());
				tv.setTextColor(0xFFFFFFFF);
				tv.setFocusable(true);
				tv.setFocusableInTouchMode(false);
				LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
				lp.leftMargin = 10;
				lp.bottomMargin = 3;
				clientView.addView(tv);//,lp);
*/

				final String key = child.getName();
				String placeholder = child.getStringAttribute("exampleText");
                String contentDescription = child.getStringAttribute("contentDescription");
                if (accessibilityEnabled) placeholder = contentDescription;
				final String storeAs = child.getStringAttribute("storeAs");
				String value = (storeAs != null) ? db.getSetting(storeAs) : null;
				EditText field = new EditText(getContext());
				field.setMaxLines(4);
				field.setMinLines(4);
				field.setHint(placeholder);
				field.setGravity(Gravity.LEFT|Gravity.TOP);
				if (value != null) {
					field.setText(value);
				}
				field.addTextChangedListener(new TextWatcher() {
					public void onTextChanged(CharSequence s, int start, int before, int count) {
						if (storeAs != null) db.setSetting(storeAs, s.toString());
					}
					
					public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
					public void afterTextChanged(Editable s) {}
				});
								
				fields.add(field);
				clientView.addView(field);
			}
		}
		
	}
}
