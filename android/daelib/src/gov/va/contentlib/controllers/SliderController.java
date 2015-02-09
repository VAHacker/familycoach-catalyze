package gov.va.contentlib.controllers;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.Shape;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.SeekBar;

import gov.va.contentlib.content.Content;

/**
 * Created by geh on 2/6/14.
 */
public class SliderController extends ContentViewController {

    String selectionVariable;

    public SliderController(Context c) {
        super(c);
    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        Content c = getContent();
        selectionVariable = c.getStringAttribute("selectionVariable");
        int min = c.getIntAttribute("min");
        int max = c.getIntAttribute("max");

        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
        final SeekBar seekBar = new SeekBar(getContext());
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.gravity = Gravity.FILL_HORIZONTAL;
        int margin =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, dm);
        lp.setMargins(margin,0,margin,0);
        seekBar.setMax(max);
        seekBar.setLayoutParams(lp);

        int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
        seekBar.setMinimumHeight(h);

        final Paint circleStroke = new Paint();
        circleStroke.setARGB(255,128,128,255);
        circleStroke.setStrokeWidth(5);
        circleStroke.setStyle(Paint.Style.STROKE);
        circleStroke.setAntiAlias(true);

        final Paint circleFill = new Paint();
        circleFill.setARGB(255, 255, 255, 255);
        circleFill.setStyle(Paint.Style.FILL);
        circleFill.setAntiAlias(true);

        final Paint textPaint = new Paint();
        textPaint.setARGB(255,128,128,255);
        textPaint.setStyle(Paint.Style.FILL);
        textPaint.setAntiAlias(true);
        textPaint.setTextSize(48);

        final Rect bounds = new Rect();

        Shape thumbShape = new Shape() {
            @Override
            public void draw(Canvas canvas, Paint paint) {
                float rad = getWidth()/2.0f;
                canvas.drawCircle(rad,rad,rad-4,circleFill);
                canvas.drawCircle(rad,rad,rad-4,circleStroke);
                Number value = (Number)getVariable(selectionVariable);
                String label = "?";
                if (value != null) {
                    label = ""+seekBar.getProgress();
                }
                float width = textPaint.measureText(label,0,label.length());
                canvas.drawText(label, rad-width/2, rad - textPaint.ascent()/2, textPaint);
            }
        };

        ShapeDrawable thumbDrawable = new ShapeDrawable(thumbShape);
        thumbDrawable.setIntrinsicHeight(100);
        thumbDrawable.setIntrinsicWidth(85);
        seekBar.setThumb(thumbDrawable);

        Number value = (Number)getVariable(selectionVariable);
        if (value != null) {
            seekBar.setProgress(value.intValue());
        } else {
            seekBar.setProgress(min + ((max-min)/2));
        }

        seekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                setVariable(selectionVariable,seekBar.getProgress());
            }
        });

        clientView.addView(seekBar);
    }

}
