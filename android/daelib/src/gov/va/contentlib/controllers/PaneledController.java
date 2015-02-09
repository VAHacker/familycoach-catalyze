package gov.va.contentlib.controllers;

import java.util.List;

import com.nineoldandroids.animation.ValueAnimator;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.daelib.R;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;
import android.widget.TextView;

public class PaneledController extends ContentViewControllerBase {

	Content topContent, bottomContent;
	ContentViewControllerBase topController = null;
	ContentViewControllerBase bottomController = null;
	View splitBar;
	TextView splitLabel;
	ImageView collapseArrow;
	boolean panelOpened = false;
	int panelHeightWhenOpen = 200;
	boolean didInitialRotation = false;
	
	public PaneledController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public boolean shouldUseScroller() {
		return false;
	}

	public void setPanelOpened(boolean opened) {
		setPanelOpened(opened,false,500);
	}

	public void setPanelOpened(boolean opened, boolean force, long animationDuration) {
		if (!force && (opened == panelOpened)) return;
		
		float start = 0;
		float end = 1;
		if (!opened) {
			start = 1;
			end = 0;
		}
		
		if (animationDuration > 0) {
			ValueAnimator animation = ValueAnimator.ofFloat(start,end).setDuration(animationDuration);
			animation.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
				public void onAnimationUpdate(ValueAnimator animation) {
					Float val = ((Number)animation.getAnimatedValue()).floatValue();
					LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,(int)(val*getView().getHeight()*1/4));
					bottomController.getView().setLayoutParams(p);
					getView().requestLayout();
				}
			});
			animation.start();
		} else {
			LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, opened ? getView().getHeight()*1/4 : 0);
			bottomController.getView().setLayoutParams(p);
			getView().requestLayout();
		}

		Animation an = new RotateAnimation(end*-90, start*-90, collapseArrow.getWidth()/2, collapseArrow.getHeight()/2);
		an.setDuration(animationDuration);
		an.setFillAfter(true);
		collapseArrow.setAnimation(an);
		
		panelOpened = opened;
		bottomController.setContentVisible(isContentVisible() && panelOpened);
	}
	
	public void togglePanelOpened() {
		setPanelOpened(!panelOpened);
	}
/*	
	@Override
	protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
		super.onLayout(changed, left, top, right, bottom);
		if (!didInitialRotation) {
			setPanelOpened(panelOpened, true, 0);
			didInitialRotation = true;
		}
	}
*/	
	public void updatePanel() {
		if (bottomController.hasAnyContent()) {
			String label = bottomContent.getTitleOrDisplayName();
			int badge = bottomController.getBadgeValue();
			if (badge > 0) {
				label = label + "("+badge+")";
			}
			splitLabel.setText(label);
			splitBar.setVisibility(View.VISIBLE);
		} else {
			setPanelOpened(false, false, 0);
			splitBar.setVisibility(View.GONE);
		}
	}
	
	public void refreshContentAfterChildren() {
		updatePanel();
	}

	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		
		getView().setBackgroundDrawable(null);
		clientView.setPadding(0, 0, 0, 0);
		
		List<Content> children = content.getChildren();
		topContent = children.get(0);
		bottomContent = children.get(1);

		LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT);
		topController = topContent.createContentView(this,getContext());
		p.weight = 1;
		topController.getView().setLayoutParams(p);
		addChildController(topController);

		p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT);
		LayoutInflater li = LayoutInflater.from(getContext());
		splitBar = li.inflate(R.layout.panel_bar, getView(), false);
		p.weight = 0;
		splitBar.setLayoutParams(p);
		splitLabel = (TextView)splitBar.findViewById(android.R.id.text1);
		collapseArrow = (ImageView)splitBar.findViewById(android.R.id.icon);
		
		p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,0);
		bottomController = bottomContent.createContentView(this,getContext());
		p.weight = 0;
		bottomController.getView().setLayoutParams(p);
		addChildController(bottomController);
		
		clientView.addView(topController.getView());
		clientView.addView(splitBar);
		clientView.addView(bottomController.getView());
		
		splitBar.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				togglePanelOpened();
			}
		});
		
		updatePanel();
	}

}
