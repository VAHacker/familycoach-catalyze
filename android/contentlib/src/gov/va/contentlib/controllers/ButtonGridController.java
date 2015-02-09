package gov.va.contentlib.controllers;

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import gov.va.contentlib.TopContentActivity;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.HomeNavigationController;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.activities.NavigationController;
import gov.va.contentlib.activities.SetupActivity;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.GridLayout;
import gov.va.contentlib.views.LoggingButton;
import gov.va.contentlib.R;

public class ButtonGridController extends ContentViewControllerBase {

	GridLayout grid;
	List<Content> buttons;
	LinearLayout linear;
	
	final static int SETUP_BUTTON = 1001;
	final static int FAVORITES_BUTTON = 1002;
	
	public ButtonGridController(Context ctx) {
		super(ctx);
	}
	
	class PictureButton extends LoggingButton {
		public PictureButton(Context ctx) {
			super(ctx);
		}
		
		@Override
		protected void onLayout(boolean changed, int left, int top, int right,
				int bottom) {
			int width = right-left-20;
			int height = bottom-top-20;
			Drawable[] drawables =  getCompoundDrawables();
			
			Drawable image = drawables[0];
			if (image != null) {
				int iwidth = image.getIntrinsicWidth();
				int iheight = image.getIntrinsicHeight();
				int w = iwidth;
				int h = iheight;

				if (w > width/2) {
					w = width/2;
					h = w * iheight / iwidth;
				}

				if (h > height) {
					h = height;
					w = h * iwidth / iheight;
				}
				
				
				image.setBounds(new Rect(0,0,w,h));
			}
			
			setCompoundDrawables(drawables[0], drawables[1], drawables[2], drawables[3]);

			super.onLayout(changed, left, top, right, bottom);
		}
		
		@Override
		protected void onDraw(Canvas canvas) {
//			Drawable[] d = getCompoundDrawables();
//			String text = getText();
			int padding = getCompoundPaddingTop();
			super.onDraw(canvas);
		}
		
	}

	@Override
	public void build() {
		setBackgroundColor(0);
		setBackgroundDrawable(getBackground());
		
		linear = new LinearLayout(getContext());
		linear.setOrientation(LinearLayout.VERTICAL);
		addView(linear);

		String showTitle = content.getStringAttribute("showTitle");
		if ((showTitle != null) && (showTitle.equals("true"))) {
			String title = content.getTitle();
			if (title != null) {
				linear.addView(makeTitleView(title));
			}
		}
		
		String mainText = getContent().getMainText();
		if (mainText != null) {
			WebView wv = createWebView(mainText);
			LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT);
			lp.setMargins(10, 10, 10, 0);
			linear.addView(wv,lp);
		}
		
		grid = new GridLayout(getContext());
		grid.setBackgroundColor(0);
		grid.setId(100);
		
		Integer cellsPerRow = getContent().getIntAttribute("buttongrid_cellsPerRow");
		Integer outerMarginX = getContent().getIntAttribute("buttongrid_outerMarginX");
		Integer outerMarginY = getContent().getIntAttribute("buttongrid_outerMarginY");
		Integer cellMarginY = getContent().getIntAttribute("buttongrid_cellMarginX");
		Integer cellMarginX = getContent().getIntAttribute("buttongrid_cellMarginY");

		grid.setOuterMargins((outerMarginX != null) ? outerMarginX : 0, (outerMarginY != null) ? outerMarginY : 0);
		grid.setCellSpacing((cellMarginX != null) ? cellMarginX : 0, (cellMarginY != null) ? cellMarginY : 0);
		
		LinearLayout.LayoutParams layout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
		layout.weight = 1; 
		grid.setLayoutParams(layout);

//		grid.setStretchAllColumns(true);

		int columns = (cellsPerRow == null) ? 2 : cellsPerRow;
		grid.setColumns(columns);
		buttons = getContent().getChildren();
		
		int count = 0;
		for (Content button : buttons) {
			PictureButton b = new PictureButton(getContext());
//			b.setBackgroundResource(R.drawable.button_bg);
			b.setGravity(Gravity.CENTER);
			b.setMaxLines(2);
			b.setId(count);
			b.setCompoundDrawablePadding(12);
			b.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					int id = v.getId();
					buttonTapped(id);
				}
			});
			b.setText(button.getDisplayName());
			Drawable image = button.getButtonImage();
			if (image != null) {
				int iwidth = image.getIntrinsicWidth();
				int iheight = image.getIntrinsicHeight();
				int width = iwidth;
				int height = iheight;
				if (columns == 1) {
//					if (width > 100) {
						width = 100;
						height = width * iheight / iwidth;
//					}
				} else {
//					if (height > 100) {
						height = 120;
						width = height * iwidth / iheight;
//					}
				}
				image.setBounds(new Rect(0,0,width,height));
				if (columns == 1) {
					b.setCompoundDrawables(image, null, null, null);
					b.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
				} else {
					b.setCompoundDrawables(null, image, null, null);
					b.setTypeface(b.getTypeface(), Typeface.BOLD);
					b.setTextSize(17);
				}
			}

			LayoutParams lp = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
			lp.gravity = Gravity.CENTER;
			
			grid.addView(b,lp);
			b.requestLayout();
			count++;
		}
		
		linear.addView(grid);

		if (getContent() != null) {
			Content c = getContent();
			if ("home".equals(c.getName())) {
				LoggingButton setupButton = new LoggingButton(getContext());
				setupButton.setText("Setup");
				LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, 50);
				params.weight = 0;
				setupButton.setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						handleButtonTap(SETUP_BUTTON);
					}
				});
				linear.addView(setupButton, params);
			} else if ("manage".equals(c.getName()) || "feelBetterNow".equals(c.getName())) {
				LoggingButton favoritesButton = new LoggingButton(getContext());
				favoritesButton.setText("Favorites");
				LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT, 50);
				params.weight = 0;
				favoritesButton.setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						handleButtonTap(FAVORITES_BUTTON);
					}
				});
				linear.addView(favoritesButton, params);
			}
			
		}
	}

	public void contentSelected(Content c) {
		getNavigator().contentSelected(c);
	}
	
	public void handleButtonTap(int id) {
		if (id == SETUP_BUTTON) {
			HomeNavigationController nc = (HomeNavigationController)getNavigator();
			nc.gotoSetup();
			return;
		}

		if (id == FAVORITES_BUTTON) {
			ManageNavigationController nc = (ManageNavigationController)getNavigator();
			nc.gotoFavorites();
			return;
		}
		
		contentSelected(buttons.get(id));
	}
	
	@Override
	public void parentActivityPaused()
	{
		TopContentActivity a =(TopContentActivity)getNavigator().getParent();
		
		if((a != null) && a.fromBackground)
		{
			//we are going into the background,go back 
			getNavigator().goBack();
		}
	}
}
