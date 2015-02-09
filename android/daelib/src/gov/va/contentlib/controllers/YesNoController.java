package gov.va.contentlib.controllers;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RadioGroup;
import android.widget.Switch;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.SegmentedRadioGroup;

public class YesNoController extends ContentViewController {

    String selectionVariable;

	public YesNoController(Context ctx) {
		super(ctx);
	}

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();
        Content c = getContent();
        selectionVariable = c.getStringAttribute("selectionVariable");

        SegmentedRadioGroup seg = new SegmentedRadioGroup(getContext());
        seg.addOption("No",false,0);
        seg.addOption("Yes",true,1);

        int selection = 0;
        Boolean b = (Boolean)getVariable(selectionVariable);
        if ((b == null) || !b) {
            seg.check(0);
        } else {
            seg.check(1);
        }

        seg.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                setVariable(selectionVariable, (checkedId > 0));
            }
        });

        seg.setup();

        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        p.gravity = Gravity.CENTER_HORIZONTAL;
        p.weight = 1;

        clientView.addView(seg,p);
    }
}
