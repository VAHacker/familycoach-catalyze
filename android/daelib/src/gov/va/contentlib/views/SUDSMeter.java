package gov.va.contentlib.views;

import gov.va.contentlib.services.TtsContentProvider;
import gov.va.daelib.R;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.graphics.Path.Direction;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityEventSource;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeInfo;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

public class SUDSMeter extends LinearLayout {

    AccessibilityManager am;
    Meter meter;
    Drawable scrollup, scrolldown;
    ImageView scrollupButton, scrolldownButton;
    Integer reading = null;

    public SUDSMeter(Context ctx) {
        super(ctx);

        setOrientation(VERTICAL);

        LayoutParams layout;

        DisplayMetrics dm = getResources().getDisplayMetrics();
        int height = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, dm);

        scrollup = ctx.getApplicationContext().getResources().getDrawable(R.drawable.scrollup);
        scrolldown = ctx.getApplicationContext().getResources().getDrawable(R.drawable.scrolldown);

        meter = new Meter(ctx);
        int width = meter.getThermWidth();

        ImageView up = new ImageView(ctx);
        up.setScaleType(ImageView.ScaleType.FIT_XY);
        up.setImageDrawable(scrollup);
        up.setClickable(true);
        up.setFocusable(true);
        layout = new LinearLayout.LayoutParams(width,height);
        layout.gravity = Gravity.LEFT;
        layout.topMargin = height/5;
        up.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                updateReading(getIntScore() + 1);
                sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED);
            }
        });
        addView(up, layout);
        scrollupButton = up;

        layout = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.WRAP_CONTENT);
        layout.gravity = Gravity.LEFT;
        addView(meter,layout);

        ImageView down = new ImageView(ctx);
        down.setScaleType(ImageView.ScaleType.FIT_XY);
        down.setImageDrawable(scrolldown);
        down.setClickable(true);
        down.setFocusable(true);
        layout = new LinearLayout.LayoutParams(width,height);
        layout.gravity = Gravity.LEFT;
        layout.topMargin = height/5;
        layout.bottomMargin = height/5;
        down.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                updateReading(getIntScore()-1);
                sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED);
            }
        });
        addView(down, layout);
        scrolldownButton = down;

        scrollupButton.setContentDescription("Distress level "+((reading==null)?"unset":(reading))+", raise level");
        scrolldownButton.setContentDescription("Distress level "+((reading==null)?"unset":(reading))+", lower level");
    }

    @Override
    public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
        super.dispatchPopulateAccessibilityEvent(event);
        event.setContentDescription(event.getContentDescription());
        return true;
    }

    public int getIntScore() {
        return (reading == null) ? 5 : reading;
    }

    public Integer getScore() {
        return reading;
    }

    public void setScore(Integer newReading) {
        reading = newReading;
        if (reading.intValue() > 10) reading = 10;
        if (reading.intValue() < 0) reading = 0;
    }

    public void updateReading(Integer newReading) {
        Integer oldReading = reading;
        setScore(newReading);
        scrollupButton.setContentDescription("Distress level " + ((reading == null) ? "unset" : (reading)) + ", raise level");
        scrolldownButton.setContentDescription("Distress level "+((reading==null)?"unset":(reading))+", lower level");
        if (((oldReading == null) || (oldReading.intValue() != reading.intValue()))) {
            meter.invalidate();
            meter.sendAccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED);
        }

    }

    public class Meter extends RelativeLayout implements AccessibilityEventSource {
        Drawable bgd;
        Drawable marker;
        Drawable mercury;
        boolean selected = false;

        int thermW, thermH;
        int markerW, markerH;
        int mercuryW, mercuryH;

        final static private float SCALE = 0.75f;

        public Meter(Context ctx) {
            super(ctx);

            am = (AccessibilityManager)ctx.getSystemService(Context.ACCESSIBILITY_SERVICE);

            bgd = ctx.getApplicationContext().getResources().getDrawable(R.drawable.thermometer);
            marker = ctx.getApplicationContext().getResources().getDrawable(R.drawable.therm_marker);
            mercury = ctx.getApplicationContext().getResources().getDrawable(R.drawable.mercury);

            thermW = (int)(bgd.getIntrinsicWidth()*SCALE);
            thermH = (int)(bgd.getIntrinsicHeight()*SCALE);
            markerW = (int)(marker.getIntrinsicWidth()*SCALE);
            markerH = (int)(marker.getIntrinsicHeight()*SCALE);
            mercuryW = (int)(mercury.getIntrinsicWidth()*SCALE);
            mercuryH = (int)(mercury.getIntrinsicHeight()*SCALE);

            ImageView bg = new ImageView(ctx);
            RelativeLayout.LayoutParams layout = new RelativeLayout.LayoutParams(bgd.getIntrinsicWidth(),bgd.getIntrinsicHeight());
            bg.setImageDrawable(bgd);
            addView(bg,layout);

            setPadding(0,0,80,0);

            setWillNotDraw(false);
    //		setFocusableInTouchMode(false);
    		setFocusable(true);
//            setImportantForAccessibility(IMPORTANT_FOR_ACCESSIBILITY_YES);
//            setAccessibilityLiveRegion(ACCESSIBILITY_LIVE_REGION_ASSERTIVE);

    //		setDescendantFocusability(FOCUS_BLOCK_DESCENDANTS);
        }

        public int getThermWidth() {
            return (int)(bgd.getIntrinsicWidth()*SCALE);
        }

        @Override
        public boolean onKeyDown(int keyCode, KeyEvent event) {
            if ((event.getKeyCode() == KeyEvent.KEYCODE_DPAD_CENTER) || (event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                selected = !selected;
                invalidate();
                sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_SELECTED);
            } else if (selected) {
                if ((event.getKeyCode() == KeyEvent.KEYCODE_DPAD_DOWN) ||
                        (event.getKeyCode() == KeyEvent.KEYCODE_DPAD_LEFT)) {
                    if (reading == null) updateReading(5);
                    else updateReading(reading - 1);
                } else if (	(event.getKeyCode() == KeyEvent.KEYCODE_DPAD_UP) ||
                        (event.getKeyCode() == KeyEvent.KEYCODE_DPAD_RIGHT)) {
                    if (reading == null) updateReading(5);
                    else updateReading(reading + 1);
                }
                return true;
            }
            return super.onKeyDown(keyCode, event);
        }

        @Override
        protected void onFocusChanged(boolean gainFocus, int direction, Rect previouslyFocusedRect) {
            super.onFocusChanged(gainFocus, direction, previouslyFocusedRect);
        }
/*
        @Override
        public void onInitializeAccessibilityEvent(AccessibilityEvent event) {
            super.onInitializeAccessibilityEvent(event);
            if (event.getEventType() == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
                event.setContentChangeTypes(event.getContentChangeTypes() | AccessibilityEvent.CONTENT_CHANGE_TYPE_TEXT);
                event.getText().add("Distress level "+reading);
            }
        }
        */

        @Override
        public boolean dispatchPopulateAccessibilityEvent(AccessibilityEvent event) {
            super.dispatchPopulateAccessibilityEvent(event);
            if (reading == null) {
                event.setContentDescription("Distress meter, unset");
            } else {
                event.setContentDescription("Distress meter at level "+reading);
            }
/*
            if (event.getEventType() == AccessibilityEvent.TYPE_VIEW_SELECTED) {
                TtsContentProvider.stopSpeech(null);
                if (selected) {
                    event.setContentDescription("Distress meter selected");
                } else {
                    event.setContentDescription("Distress meter unselected");
                }
            } else if (event.getEventType() == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
                event.setContentDescription("Distress level "+reading);
            }
*/
            return true;
        }

        @Override
        protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
            int w = thermW+80;
            int h = thermH;
            setMeasuredDimension(w, h);
        }

        private static final int _pixPerMarker = 21;

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            DisplayMetrics dm = getResources().getDisplayMetrics();
            float x = event.getX();
            float y = event.getY();
            float height = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 245, dm)-y;
            float pixPerMarker = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, _pixPerMarker, dm);
            int dibit = (int)((height+(pixPerMarker*0.5)) / pixPerMarker);
            if (dibit < 0) dibit = 0;
            if (dibit > 10) dibit = 10;
            updateReading(dibit);
            return true;
        }

        @Override
        protected void dispatchDraw(Canvas canvas) {
            if (isFocused() || selected) {
                int width = getWidth();
                int height = getHeight();
                RectF bounds = new RectF(0,0,width,height);

                Paint paint = new Paint();
                paint.setAntiAlias(true);
                paint.setColor(0x8000FF00);
                paint.setStrokeWidth(2);
                if (selected) {
                    paint.setStyle(Style.FILL_AND_STROKE);
                } else {
                    paint.setStyle(Style.STROKE);
                }
                canvas.drawRoundRect(bounds, 10, 10, paint);
            }

            super.dispatchDraw(canvas);

            DisplayMetrics dm = getResources().getDisplayMetrics();
            float pixPerMarker = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, _pixPerMarker, dm);

            Rect r = new Rect(0,0,thermW,thermH);
            bgd.setBounds(r);
            bgd.draw(canvas);

            int level = (reading == null) ? 5 : reading.intValue();

            int left = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 18, dm);
            int top = (int)(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 239, dm)-(level*pixPerMarker));
            int bottom = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 245, dm);
            r = new Rect(left,top,left+mercuryW,bottom);
            mercury.setBounds(r);
            mercury.draw(canvas);

            r = new Rect(0,0,markerW,markerH);
            for (int i=0;i<11;i++) {
                int y = (int)(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 239, dm) - (i * pixPerMarker));
                r.offsetTo((int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 29, dm), y);
                marker.setBounds(r);
                marker.draw(canvas);
            }

            Paint paint = new Paint();
            paint.setAntiAlias(true);
            Path outline = new Path();
            left = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 48, dm);
            RectF rf = new RectF(left+0.5f,top-TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm)+0.5f,left+TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, dm)+0.5f,top+TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm)+0.5f);
            outline.addRect(rf, Direction.CW);
            paint.setColor(0xFFFFFF00);
            paint.setStrokeWidth(0);
            paint.setStyle(Style.FILL);
            canvas.drawPath(outline, paint);
            paint.setColor(0xFF000000);
            paint.setStyle(Style.STROKE);
            canvas.drawPath(outline, paint);

            int red = 255 * level / 10;
            int green = (200 - (200 * level / 10));
            paint.setARGB(255, red, green, 0);
            paint.setStyle(Style.FILL);
            paint.setTextSize(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, dm)+TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, level, dm));
            paint.setTypeface(Typeface.DEFAULT_BOLD);
            paint.setTextAlign(Align.CENTER);
            String str = (reading == null) ? "?" : reading.toString();
            Rect textBounds = new Rect();
            paint.getTextBounds(str, 0, str.length(), textBounds);
            canvas.drawText(str, left+TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 15, dm),top + (-textBounds.top / 2),paint);
        }
    }
}
