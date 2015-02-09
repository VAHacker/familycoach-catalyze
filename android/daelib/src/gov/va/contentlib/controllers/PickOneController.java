package gov.va.contentlib.controllers;

import android.content.Context;
import android.database.Cursor;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import gov.va.contentlib.content.Content;

/**
 * Created by geh on 2/6/14.
 */
public class PickOneController extends ContentViewController {

    String selectionVariable;
    Button button;
    Content itemContent;
    String entityName;

    public PickOneController(Context c) {
        super(c);
    }

    public void updateLabel() {
        StringBuilder label = new StringBuilder();
        label.append(itemContent.getDisplayName());
        Object val = getVariable(selectionVariable);
        Number id = (Number)val;
        if (id != null) {
            Cursor c = getUserDB().sql().query(entityName,new String[]{"displayName"},"_id=?",new String[]{""+id.longValue()},null,null,"displayName");
            if (c.moveToFirst()) {
                label.setLength(0);
                label.append(c.getString(c.getColumnIndex("displayName")));
            }
        }
        button.setText(label.toString());
    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        Content c = getContent();
        itemContent = c.getChildByName("@item");
        Integer lines = c.getIntAttribute("lines");
        selectionVariable = c.getStringAttribute("selectionVariable");
        entityName = getContent().getStringAttribute("entityName").toLowerCase();

        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
        int dip5 =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 7, dm);

        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.gravity = Gravity.FILL_HORIZONTAL;
        int margin =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 20, dm);
        lp.setMargins(margin-dip5,0,margin-dip5,0);
//        lp.setMargins(-dip5,0,-dip5,0);
        button = new Button(getContext());
        button.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
        button.setMaxLines(lines != null ? lines : 3);
        button.setLayoutParams(lp);

        updateLabel();

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ContentViewControllerBase cvc = itemContent.createContentView(PickOneController.this,getContext());
                navigateToNext(cvc);
            }
        });

        clientView.addView(button);
    }

    @Override
    public void onContentBecameVisible() {
        super.onContentBecameVisible();
        updateLabel();
    }
}
