package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;

import java.util.List;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.actionbarsherlock.internal.widget.IcsLinearLayout;

public class ButtonGridController extends ContentViewControllerBase {

//	Theme buttonTheme;
	ViewGroup grid;
	List<Content> buttons;
	
	final static int SETUP_BUTTON = 1001;
	final static int FAVORITES_BUTTON = 1002;
	
	public ButtonGridController(Context ctx) {
		super(ctx);
	}
	
	class SelectionOverlay extends View {
		Drawable drawable;
		public SelectionOverlay(Context ctx) {
			super(ctx);
			drawable = getContentResources().getDrawable(getResourceAttr(gov.va.daelib.R.attr.contentListChoiceBackgroundIndicator));
		}
		
		@Override
		protected void drawableStateChanged() {
			super.drawableStateChanged();
			if (drawable != null) {
				int [] state = ((View)getParent()).getDrawableState();
				drawable.setState(state);
			}
			invalidate();
		}

		@Override
		protected void onDraw(Canvas canvas) {
			// TODO Auto-generated method stub
			super.onDraw(canvas);
			//boolean pressed = isPressed();

			//if (!pressed) return;
			
			int l = getLeft();
			int r = getRight();
			int t = getTop();
			int b = getBottom();
			
			drawable.setBounds(l,t,r,b);
			drawable.draw(canvas);
		}
	}
	
	class PictureButton extends ViewGroup {
		ImageView icon;
		TextView label;
		SelectionOverlay overlay;
		Paint selectionOverlay;
		Drawable buttonBackground;
		int paddingLeft, paddingRight;
		int orientation = IcsLinearLayout.HORIZONTAL;
		
		public PictureButton(Context ctx) {
			super(ctx);
			DisplayMetrics dm = getResources().getDisplayMetrics();
			LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
			icon = new ImageView(ctx);
			icon.setScaleType(ScaleType.CENTER_INSIDE);
			addView(icon,p);
			p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
			label = new TextView(ctx);
			label.setTextAppearance(getContext(), getResourceAttr(android.R.attr.textAppearanceLarge));
//			label.setTextColor(theme.getTextColor());
//			label.setTextSize(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, theme.getFontSize(), dm));
			p.weight = 1;

			overlay = new SelectionOverlay(getContext());
			addView(overlay,new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
			addView(label,p);

			label.setGravity(Gravity.CENTER_VERTICAL | Gravity.RIGHT);
//			buttonBackground = getContentResources().getDrawable(getResourceAttr(gov.va.daelib.R.attr.contentListChoiceBackgroundIndicator));
//			setBackgroundDrawable(buttonBackground);
			paddingLeft = (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft);
			paddingRight = (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight);
//			setPadding((int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft), 0, (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight), 0);

//            setBackgroundDrawable(getContentResources().getDrawable(getResourceAttr(gov.va.daelib.R.attr.contentListChoiceBackgroundIndicator)));

/*
			buttonBackground = theme.getBackgroundImage();
			setBackgroundDrawable(buttonBackground);
			Rect padding = new Rect();
			if (buttonBackground.getPadding(padding)) {
				setPadding(
					(int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, padding.left, dm), 
					(int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, padding.top, dm), 
					(int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, padding.right, dm), 
					(int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, padding.bottom, dm));
			}
*/
			setClickable(true);
            setFocusable(true);
            setFocusableInTouchMode(false);
		}

        public void setOrientation(int o) {
			orientation = o;
			if (o == IcsLinearLayout.HORIZONTAL) {
				label.setGravity(Gravity.CENTER_VERTICAL | Gravity.RIGHT);
			} else {
				label.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.BOTTOM);
			}
		}
		
		@Override
		protected void drawableStateChanged() {
			super.drawableStateChanged();
            overlay.drawableStateChanged();
			if (buttonBackground != null) {
				boolean pressed = isPressed();
				int [] state = getDrawableState();
//				buttonBackground.setState(state);
//				setPadding((int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingLeft), 0, (int)getDimAttr(gov.va.daelib.R.attr.contentListPreferredItemPaddingRight), 0);
			}
			invalidate();
		}
		
		@Override
		protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
			
			int width = right-left-getPaddingLeft()-getPaddingRight()-paddingLeft-paddingRight;
			int height = bottom-top-getPaddingTop()-getPaddingBottom();


			if (orientation == IcsLinearLayout.HORIZONTAL) {
				if ((icon != null) && (icon.getDrawable() != null)) {
					int iwidth = icon.getDrawable().getIntrinsicWidth();
					int iheight = icon.getDrawable().getIntrinsicHeight();
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
					icon.layout(getPaddingLeft()+paddingLeft, getPaddingTop(), w, h);

					int l = getPaddingLeft()+w+paddingLeft;
					int t = getPaddingTop();
					int b = getPaddingTop()+height;
					int r = getPaddingLeft()+width+paddingLeft;
					label.measure(MeasureSpec.makeMeasureSpec(r-l, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(b-t, MeasureSpec.EXACTLY));
					int mheight = label.getMeasuredHeight();
					/*
					if (b-t > mheight) {
						int center = (b-t)/2;
						t = center - mheight/2;
						b = t+mheight;
					}
					 */				
					label.layout(l, t, r, b);
				}
			} else {
				int l = getPaddingLeft()+paddingLeft;
				int t = getPaddingTop();
				int b = getPaddingTop()+height;
				int r = getPaddingLeft()+width+paddingLeft;
				label.setPadding(0, 0, 0, 20);
				label.measure(MeasureSpec.makeMeasureSpec(r-l, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(b-t, MeasureSpec.AT_MOST));
				int mheight = label.getMeasuredHeight();

				if ((icon != null) && (icon.getDrawable() != null)) {
					int iwidth = icon.getDrawable().getIntrinsicWidth();
					int iheight = icon.getDrawable().getIntrinsicHeight();
					int w = iwidth;
					int h = iheight;
					if (mheight > height/2) {
						mheight = height/2;
					}
					if (h > height-mheight) {
						h = height-mheight;
						w = h * iwidth / iheight;
					}
					if (w > width) {
						w = width;
						h = w * iheight / iwidth;
					}
					if (h > height*2/3) {
						h = height*2/3;
						w = h * iwidth / iheight;
					}

					t = h+getPaddingTop();
					b = t+mheight;
					
					int totalHeight = (b-t)+h;
					int offset = (height-totalHeight)/2;
					
					int imageLeft = getPaddingLeft()+paddingLeft+width/2-w/2;
					icon.layout(imageLeft, getPaddingTop()+offset, imageLeft+w, getPaddingTop()+h+offset);
					
					t+=offset;
//					b+=offset;
					b = height+getPaddingTop();
					t = b-mheight;
				} else {
					int center = (b-t)/2;
					t = center - mheight/2;
					b = t+mheight;
				}
				label.layout(l, t, r, b);
			}
			
			overlay.layout(0,0,right-left,bottom-top);
		}
		
	}

	@Override
	public boolean shouldUseScroller() {
		return false;
	}
	
	class SimpleGridLayout extends ViewGroup {
		int columns;
		Drawable divider;
		
		public SimpleGridLayout(Context ctx, int cols) {
			super(ctx);
			columns = cols;
			divider = getContentResources().getDrawable(getResourceAttr(android.R.attr.listDivider));
			setWillNotDraw(false);
            setFocusable(false);
		}
		
		@Override
		protected void onDraw(Canvas canvas) {
			super.onDraw(canvas);
			int l = getLeft();
			int r = getRight();
			int t = getTop();
			int b = getBottom();
			
			int width = r-l;
			int height = b-t;
			int rows = (getChildCount() + columns-1) / columns;
			for (int i=0;i<columns;i++) {
				int left = i * width / columns;
				int right = (i+1) * width / columns;
				int top = t;
				int bottom = b;
				divider.setBounds(left-1,top,left+1,bottom);
				divider.draw(canvas);
			}
			for (int i=0;i<rows;i++) {
				int top = i * height / rows;
				int left = l;
				int right = r;
				divider.setBounds(left,top-1,right,top+1);
				divider.draw(canvas);
			}
		}
		
		@Override
		protected void onLayout(boolean changed, int l, int t, int r, int b) {
			int width = r-l;
			int height = b-t;
			int rows = (getChildCount() + columns-1) / columns;
			for (int i=0;i<getChildCount();i++) {
				int row = i / columns;
				int col = i % columns;
				int left = col * width / columns;
				int right = (col+1) * width / columns;
				int top = row * height / rows;
				int bottom = (row+1) * height / rows;
				View v = getChildAt(i);
				v.layout(left,top,right,bottom);
			}
		}

        public void init() {
            /*
            for (int i=0;i<getChildCount();i++) {
                int col = i%columns;
                View me = getChildAt(i);
                int upIndex = i - columns;
                int downIndex = i + columns;
                int rightIndex = i + 1;
                int leftIndex = i - 1;
                if (upIndex >= 0) me.setNextFocusUpId(getChildAt(upIndex).getId());
                if (leftIndex >= 0) {
                    me.setNextFocusLeftId(getChildAt(leftIndex).getId());
                    me.setNextFocusForwardId(getChildAt(leftIndex).getId());
                }
                if (downIndex < getChildCount()) me.setNextFocusDownId(getChildAt(downIndex).getId());
                if (rightIndex < getChildCount()) {
                    me.setNextFocusRightId(getChildAt(rightIndex).getId());
                    me.setNext(getChildAt(leftIndex).getId());
                }
            }
            */
        }
	}
	
	@SuppressLint("NewApi")
	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		
//		buttonTheme = getTheme().getSubtheme("button");
		
		Integer cellsPerRow = getContent().getIntAttribute("buttongrid_cellsPerRow");
		Integer outerMarginX = getContent().getIntAttribute("buttongrid_outerMarginX");
		Integer outerMarginY = getContent().getIntAttribute("buttongrid_outerMarginY");
		Integer cellMarginY = getContent().getIntAttribute("buttongrid_cellMarginX");
		Integer cellMarginX = getContent().getIntAttribute("buttongrid_cellMarginY");
		
		if (cellMarginX == null) cellMarginX = 3;
		if (cellMarginY == null) cellMarginY = 3;
		
		String showTitle = content.getStringAttribute("showTitle");
		if ((showTitle != null) && (showTitle.equals("true"))) {
			String title = content.getTitle();
			if (title != null) {
				clientView.addView(makeTitleView(title));
			}
		}

		String mainText = getContent().getMainText();
		if (mainText != null) {
			View wv = makeTextView(mainText);
			clientView.addView(wv);
		}

		if (cellsPerRow > 1) {
			SimpleGridLayout g = new SimpleGridLayout(getContext(), cellsPerRow);
			grid = g;
		} else {
			IcsLinearLayout ll = new IcsLinearLayout(getContext(),null);
			ll.setOrientation(IcsLinearLayout.VERTICAL);
			ll.setShowDividers(IcsLinearLayout.SHOW_DIVIDER_MIDDLE);
			ll.setDividerDrawable(getContentResources().getDrawable(getResourceAttr(android.R.attr.listDivider)));
			ll.setBackgroundColor(0);
			ll.setId(100);

			grid = ll;
		}

		LinearLayout.LayoutParams layout = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
		layout.weight = 1; 
		grid.setLayoutParams(layout);

		int columns = (cellsPerRow == null) ? 2 : cellsPerRow;
//		grid.setColumns(columns);
		buttons = getContent().getChildren();
		
		int count = 0;
		for (final Content button : buttons) {
			PictureButton b = new PictureButton(getContext());
			if (cellsPerRow > 1) b.setOrientation(IcsLinearLayout.VERTICAL);
			b.label.setMaxLines(3);
			b.setId(count);
			b.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					contentSelected(button);
				}
			});
            b.setContentDescription(button.getDisplayName()+" button");
			b.label.setText(button.getDisplayName());
			b.label.setSingleLine(false);
			Drawable image = button.getIcon();
			if (image != null) {
				if (columns == 1) {
					b.icon.setImageDrawable(image);
				} else {
					b.icon.setImageDrawable(image);
				}
			}

			LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
			lp.weight = 1;
			lp.gravity = Gravity.CENTER;
			
			grid.addView(b,lp);
			b.requestLayout();
			count++;
		}

		clientView.addView(grid);
	}
/*
	public void contentSelected(Content c) {
		getNavigator().contentSelected(c);
	}
*/	
	/*
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
	*/
	
}
