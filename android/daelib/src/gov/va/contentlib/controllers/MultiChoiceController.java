package gov.va.contentlib.controllers;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioGroup;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.SegmentedRadioGroup;

/**
 * Created by geh on 2/6/14.
 */
public class MultiChoiceController extends ContentViewController {

    String selectionVariable;

    public MultiChoiceController(Context c) {
        super(c);
    }

    @Override
    public void buildClientViewFromContent() {
        Content c = getContent();
        selectionVariable = c.getStringAttribute("selectionVariable");
        String labels = c.getStringAttribute("labels");

        super.buildClientViewFromContent();

        SegmentedRadioGroup seg = new SegmentedRadioGroup(getContext());
        String[] items = labels.split(" ");
        for (int i=0;i<items.length;i++) {
            items[i] = items[i].replace("_"," ");
            seg.addOption(items[i],i,i);
        }

        int selection = 0;
        Object val = getVariable(selectionVariable);
        if (val != null) selection = ((Number)val).intValue();
        seg.check(selection);

        seg.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                setVariable(selectionVariable, checkedId);
            }
        });

        seg.setup();

        LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        p.gravity = Gravity.CENTER_HORIZONTAL;
        p.weight = 1;

        clientView.addView(seg,p);
    }

}
