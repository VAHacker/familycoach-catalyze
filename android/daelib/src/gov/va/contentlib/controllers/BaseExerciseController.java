package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.LoggingButton;
import gov.va.contentlib.views.LoggingImageButton;
import gov.va.daelib.R;
import android.content.Context;
import android.graphics.LightingColorFilter;
import android.graphics.drawable.Drawable;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.view.View;
import android.view.View.MeasureSpec;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;

public class BaseExerciseController extends ContentViewController {

	Integer score;
	LoggingImageButton thumbsUp;
	LoggingImageButton thumbsDown;
	LoggingImageButton ccToggle;

	boolean accelSupported;
	long lastUpdate=-1;
	float last_x, last_y, last_z;
	private static final int SHAKE_THRESHOLD = 800;
	
	public BaseExerciseController(Context ctx) {
		super(ctx);
		viewTypeID = 0; // tool
	}
	
	public void toggleCC() {
		super.toggleCC();
		updateThumbs();
	}
	
	public Content getExerciseContent() {
		return (Content)getVariable("selectedExercise");
	}
	
	public void updateThumbs() {
		int baseColor = getColorAttr(R.attr.textColorPrimary);
		if (thumbsUp != null) {
			if ((score == null) || (score.intValue() == 0)) {
				thumbsUp.setColorFilter(new LightingColorFilter(0xFFFFFFFF, baseColor));
				thumbsUp.setContentDescription("mark as favorite");
				if (thumbsDown != null) {
					thumbsDown.setColorFilter(new LightingColorFilter(0xFFFFFFFF, baseColor));
					thumbsDown.setContentDescription("thumbs down");
				}
			} else if (score.intValue() > 0) {
				thumbsUp.setColorFilter(new LightingColorFilter(0xFFFFFFFF, 0x00b0b000));
				thumbsUp.setContentDescription("mark as favorite selected");
				if (thumbsDown != null) {
					thumbsDown.setColorFilter(new LightingColorFilter(0xFFFFFFFF, baseColor));
					thumbsDown.setContentDescription("thumbs down");
				}
			} else {
				thumbsUp.setColorFilter(new LightingColorFilter(0xFFFFFFFF, baseColor));
				thumbsUp.setContentDescription("mark as favorite");
				if (thumbsDown != null) {
					thumbsDown.setColorFilter(new LightingColorFilter(0xFFFFFFFF, 0x00FF0000));
					thumbsDown.setContentDescription("thumbs down selected");
				}
			}
		}
		
		if (ccToggle != null) {
			String cc =  UserDBHelper.instance(getContext()).getSetting("cc");
			if ("true".equals(cc)) {
				ccToggle.setColorFilter(new LightingColorFilter(0xFFFFFFFF, 0x00FFFF00));
			} else {
				ccToggle.setColorFilter(new LightingColorFilter(0xFFFFFFFF, baseColor));
			}
		}
	}
	
	public void addThumbs() {
//		Theme theme = getTheme().getSubtheme("favorite");
		LoggingButton b = new LoggingButton(getContext());
		boolean thumbsEnabled = getBooleanAttr(R.attr.contentThumbsEnabled);
		boolean favoritesEnabled = getBooleanAttr(R.attr.contentFavoritesEnabled);
		b.setText("Some Text");
		b.measure(MeasureSpec.UNSPECIFIED,MeasureSpec.UNSPECIFIED);
		int height = b.getMeasuredHeight();

        Content exercise = getExerciseContent();
		score = (exercise == null) ? null : exercise.getScore();
		LinearLayout.LayoutParams layout;

		if ((exercise != null) && (thumbsEnabled || favoritesEnabled)) {

			thumbsUp = new LoggingImageButton(getContext());
			thumbsUp.setScaleType(ScaleType.CENTER_INSIDE);
			thumbsUp.setContentDescription(thumbsEnabled ? "thumbs up" : "mark as favorite");
			thumbsUp.setImageResource(thumbsEnabled ? getResourceAttr(R.attr.contentThumbsUpIcon) : getResourceAttr(R.attr.contentFavoritesIcon));
			layout = new LinearLayout.LayoutParams(height,height);
			thumbsUp.setLayoutParams(layout);
			thumbsUp.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					if ((score != null) && (score == 1))
						score = 0;
					else 
						score = 1;
					getExerciseContent().setScore(score);
					updateThumbs();
				}
			});
			getLeftButtons().addView(thumbsUp);
		}
		
		if ((exercise != null) && thumbsEnabled) {
			thumbsDown = new LoggingImageButton(getContext());
			thumbsDown.setScaleType(ScaleType.CENTER_INSIDE);
			thumbsDown.setContentDescription("thumbs down");
			thumbsDown.setImageResource(getResourceAttr(R.attr.contentThumbsDownIcon));
			layout = new LinearLayout.LayoutParams(height,height);
			thumbsDown.setLayoutParams(layout);
			thumbsDown.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					if ((score != null) && (score == -1))
						score = 0;
					else 
						score = -1;
					getExerciseContent().setScore(score);
					updateThumbs();
				}
			});
			getLeftButtons().addView(thumbsDown);
		}
		
		if (hasCaptions()) {
			ccToggle = new LoggingImageButton(getContext());
			ccToggle.setContentDescription("toggle closed captioning");
			ccToggle.setScaleType(ScaleType.CENTER_INSIDE);
			ccToggle.setImageResource(R.drawable.cc_icon);
			layout = new LinearLayout.LayoutParams(height,height);
			ccToggle.setLayoutParams(layout);
			ccToggle.setOnClickListener(new View.OnClickListener() {
				@Override
				public void onClick(View v) {
					toggleCC();
				}
			});
			getLeftButtons().addView(ccToggle);		
		}

		updateThumbs();
	}
	
	public boolean shouldAddListenButton() {
		return false;
	}

}
