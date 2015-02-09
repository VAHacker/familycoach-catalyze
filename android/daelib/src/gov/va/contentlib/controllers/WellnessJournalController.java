package gov.va.contentlib.controllers;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.text.InputType;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.CursorAdapter;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;

import com.haarman.listviewanimations.ArrayAdapter;
import com.haarman.listviewanimations.itemmanipulation.OnDismissCallback;
import com.haarman.listviewanimations.itemmanipulation.SwipeDismissAdapter;
import com.haarman.listviewanimations.itemmanipulation.SwipeDismissListViewTouchListener;
import com.haarman.listviewanimations.view.DynamicListView;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Goal;
import gov.va.contentlib.content.JournalEntry;
import gov.va.daelib.R;

public class WellnessJournalController extends ContentViewController {

    ListView listView;
	String selectionVariable;
    Paint black, blackFill, whiteFill;
    DBAdapter adapter;
    String addStyle;
    View addItem;
    Spinner filterSpinner;
    Content alarmContent;
    ImageButton alarmButton;
    long currentSymptomFilter = -1;

    public WellnessJournalController(Context ctx) {
		super(ctx);
        black = new Paint();
        black.setARGB(255,128,128,128);
        black.setStrokeWidth(5);
        black.setStyle(Paint.Style.STROKE);

        blackFill = new Paint();
        blackFill.setARGB(255, 128, 128, 128);
        blackFill.setStyle(Paint.Style.FILL);

        whiteFill = new Paint();
        whiteFill.setARGB(255, 255, 255, 255);
        whiteFill.setStyle(Paint.Style.FILL);
    }

    public class ListItemView extends LinearLayout {
        TextView title;
        TextView detail;
        TextView subtitle;

        public ListItemView(Context c) {
            super(c);
            LayoutParams p;

            setOrientation(VERTICAL);

            LinearLayout ll = new LinearLayout(getContext());
            ll.setOrientation(HORIZONTAL);
            p = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            p.weight = 1;
            ll.setLayoutParams(p);
            addView(ll);

            Resources r = getResources();
            DisplayMetrics dm = getContext().getResources().getDisplayMetrics();

            title = new TextView(c);
            title.setTextAppearance(c, getResourceAttr(R.attr.contentTextAppearanceListItem));
            p = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            p.weight = 2;
            p.rightMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 15, r.getDisplayMetrics());
            p.gravity = Gravity.CENTER_VERTICAL | Gravity.LEFT;
            title.setLayoutParams(p);
            ll.addView(title, p);

            detail = new TextView(c);
            detail.setTextAppearance(c, getResourceAttr(R.attr.contentTextAppearanceListItem));
            p = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            p.weight = 1;
            p.gravity = Gravity.CENTER_VERTICAL | Gravity.RIGHT;
            detail.setLayoutParams(p);
            detail.setGravity(Gravity.CENTER_VERTICAL | Gravity.RIGHT);
            ll.addView(detail, p);

            subtitle = new TextView(c);
            subtitle.setTextAppearance(c, getResourceAttr(R.attr.contentTextAppearanceListItem));
            subtitle.setTextSize(subtitle.getTextSize() / dm.scaledDensity * 0.7f);
            p = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            p.weight = 1;
            p.gravity = Gravity.CENTER_VERTICAL | Gravity.LEFT;
            subtitle.setLayoutParams(p);
            addView(subtitle, p);
        }

        public void bind(Cursor c) {
            int i;

            boolean useSleepEfficiency = false;

            i = c.getColumnIndex("displayName");
            if (i != -1) {
                String label = c.getString(i);
                title.setText(label);
                if ("Trouble Sleeping".equals(label)) {
                    useSleepEfficiency = true;
                }
            }

            int sleepDurationIndex = c.getColumnIndex("sleepDuration");
            int bedDurationIndex = c.getColumnIndex("bedDuration");

            Long sleepDuration = (sleepDurationIndex == -1) ? null : c.getLong(sleepDurationIndex);
            Long bedDuration = (bedDurationIndex == -1) ? null : c.getLong(bedDurationIndex);

            if (useSleepEfficiency && (sleepDuration != null) && (bedDuration != null)) {
                int sleepEfficiency = (int)(sleepDuration*100 / bedDuration);
                subtitle.setText("Sleep efficiency: "+sleepEfficiency+"%");
                subtitle.setVisibility(VISIBLE);
            } else {
                i = c.getColumnIndex("severity");
                if (i != -1) {
                    int severity = c.getInt(i);
                    subtitle.setText("Severity: "+severity);
                    subtitle.setVisibility(VISIBLE);
                } else {
                    subtitle.setVisibility(GONE);
                }
            }

            i = c.getColumnIndex("occurred");
            if (i != -1) {
                long when = c.getLong(i);
                Calendar now = Calendar.getInstance();
                Calendar cal = Calendar.getInstance();
                cal.setTimeInMillis(when);
                Date t = cal.getTime();

                if ((now.get(Calendar.YEAR) == cal.get(Calendar.YEAR)) &&
                    (now.get(Calendar.MONTH) == cal.get(Calendar.MONTH)) &&
                    (now.get(Calendar.DAY_OF_MONTH) == cal.get(Calendar.DAY_OF_MONTH))) {
                    detail.setText(DateFormat.getTimeInstance(DateFormat.SHORT).format(t));
                } else {
                    detail.setText(DateFormat.getDateInstance(DateFormat.SHORT).format(t));
                }
                detail.setVisibility(VISIBLE);
            } else {
                detail.setVisibility(GONE);
            }

        }
    }

    public class DBAdapter extends CursorAdapter {

        public DBAdapter(Context ctx, Cursor c) {
            super(ctx,c,true);
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            ListItemView v = (ListItemView)view;
            v.bind(cursor);
            ViewGroup.LayoutParams lp = v.getLayoutParams();
            if (lp == null) lp = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.width = ViewGroup.LayoutParams.MATCH_PARENT;
            lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            v.setLayoutParams(lp);
            int l = (int)getDimAttr(R.attr.contentListPreferredItemPaddingLeft);
            int r = (int)getDimAttr(R.attr.contentListPreferredItemPaddingRight);
            v.setPadding(l, 0, r, 0);
            int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
            v.setMinimumHeight(h);
        }

        @Override
        public View newView(Context context, Cursor cursor, ViewGroup parent) {
            return new ListItemView(getContext());
        }
    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();

        int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);

        LinearLayout.LayoutParams lp;
        LinearLayout topBar = new LinearLayout(getContext());
        topBar.setOrientation(LinearLayout.HORIZONTAL);

        filterSpinner = new Spinner(getContext(), Spinner.MODE_DROPDOWN);
        Cursor symptoms = getUserDB().sql().query("symptomref",new String[]{"_id","displayName"},null,null,null,null,"displayName");
        final List<Long> filterIDs = new ArrayList<Long>();
        List<String> filterNames = new ArrayList<String>();
        filterNames.add("All");
        filterIDs.add(-1L);
        while (symptoms.moveToNext()) {
            String name = symptoms.getString(1);
            filterNames.add(name);
            filterIDs.add(symptoms.getLong(0));
        }
        symptoms.close();
        android.widget.ArrayAdapter<String> a = new android.widget.ArrayAdapter<String>(getContext(), R.layout.symptom_filter_spinner, android.R.id.text1, filterNames);
        a.setDropDownViewResource(android.R.layout.select_dialog_item);
        filterSpinner.setAdapter(a);
        filterSpinner.setBackgroundResource(android.R.drawable.btn_default);
        filterSpinner.setPrompt("Select symptom");
        filterSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                currentSymptomFilter = filterIDs.get(position);
                requery();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                currentSymptomFilter = -1;
            }
        });

        lp = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        lp.weight = 1;
        topBar.addView(filterSpinner,lp);

        int dip5 =  (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 7, dm);
        alarmButton = new ImageButton(getContext());

        alarmContent = getContent().getChildByName("alarm");
        updateAlarmButtonSelected();

        alarmButton.setBackgroundResource(android.R.drawable.btn_default);
        lp = new LinearLayout.LayoutParams(h, ViewGroup.LayoutParams.MATCH_PARENT);
        lp.weight = 0;
        lp.gravity = Gravity.FILL_VERTICAL | Gravity.FILL_HORIZONTAL;
        alarmButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                navigateToContentName("alarm");
            }
        });
        alarmButton.setSelected(true);
        topBar.addView(alarmButton, lp);

        lp = new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, h);
        clientView.addView(topBar,lp);

        addStyle = getContent().getStringAttribute("addStyle");

        ContentViewControllerBase headerController = null;
        Content headerContent = getContent().getChildByName("@header");
        if (headerContent != null) {
            headerController = headerContent.createContentView(this, getContext(), true);
            addChildController(headerController);
        }

        Cursor c = getUserDB().sql().query("journalentry",new String[]{"_id","symptom","displayName","occurred","sleepDuration","bedDuration","severity"},null,null,null,null,"occurred DESC");

        adapter = new DBAdapter(getContext(),c);
        listView = new ListView(getContext());
        listView.setLayoutParams(new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        if (headerController != null) {
            listView.addHeaderView(headerController.getView(),null,false);
        }

        if ("first".equals(addStyle)) {
            TextView addLabel = new TextView(getContext());
            addLabel.setText("Add an entry...");
            addLabel.setTextAppearance(getContext(), getResourceAttr(R.attr.contentTextAppearanceListItem));
            h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
            int l = (int)getDimAttr(R.attr.contentListPreferredItemPaddingLeft);
            int r = (int)getDimAttr(R.attr.contentListPreferredItemPaddingRight);
            addLabel.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
            addLabel.setMinimumHeight(h);
            ListView.LayoutParams lvlp = new ListView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            addLabel.setLayoutParams(lvlp);
            addLabel.setPadding(l,0,r,0);
            addItem = addLabel;

            listView.addHeaderView(addItem,null,true);
        }

        if (getContent().getBoolean("selectMulti")) {
            listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        }
        listView.setAdapter(adapter);
        clientView.addView(listView);

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                JournalEntry entry = null;
                if (view == addItem) {
                    entry = new JournalEntry();
                } else {
                    Cursor c = getUserDB().sql().query("journalentry",null,"_id=?",new String[]{""+id},null,null,null);
                    if (c.moveToFirst()) {
                        entry = new JournalEntry(c);
                    }
                    c.close();
                }
                Content editContent = getContent().getChildByName("@add");
                ContentViewControllerBase cvc = editContent.createContentView(WellnessJournalController.this,getContext());
                if (entry != null) {
                    cvc.setLocalVariable("@binding", entry);
                }
                navigateToNext(cvc);
            }
        });

    }

    public void updateAlarmButtonSelected() {
        String isOnStr = getUserDB().getSetting("dailyAlarmOn_"+alarmContent.getStringAttribute("alarmName"));
        boolean isOn = (isOnStr == null) ? false : Boolean.parseBoolean(isOnStr);
        if (isOn) {
            alarmButton.setImageResource(R.drawable.alarmclock_highlighted);
        } else {
            alarmButton.setImageResource(R.drawable.alarmclock);
        }
    }

    public void requery() {
        Cursor c;
        boolean hasItems = false;
        if (currentSymptomFilter == -1) {
            c = getUserDB().sql().query("journalentry",new String[]{"_id","symptom","displayName","occurred","sleepDuration","bedDuration","severity"},null,null,null,null,"occurred DESC");
            hasItems = !adapter.isEmpty();
        } else {
            c = getUserDB().sql().query("journalentry",new String[]{"_id"},null,null,null,null,null);
            hasItems = !adapter.isEmpty();
            c.close();
            c = getUserDB().sql().query("journalentry",new String[]{"_id","symptom","displayName","occurred","sleepDuration","bedDuration","severity"},"symptom=?",new String[]{""+currentSymptomFilter},null,null,"occurred DESC");
        }
        adapter.changeCursor(c);
        Boolean b = (Boolean)getVariable("listHasItems");
        if ((b == null) || (hasItems != b)) {
            setLocalVariable("listHasItems",hasItems);
        }
    }

    @Override
    public void navigationDataReceived(Object data) {
        super.navigationDataReceived(data);
        if (data instanceof Map) {
            Map<String,Object> map = (Map<String,Object>)data;
            JournalEntry entry = new JournalEntry();
            Content editContent = getContent().getChildByName("@add");
            ContentViewControllerBase cvc = editContent.createContentView(WellnessJournalController.this,getContext());
            for (Map.Entry<String,Object> e:entry.entrySet()) {
                Object val = map.get(e.getKey());
                if (val != null) e.setValue(val);
            }
            cvc.setLocalVariable("@binding", entry);
            navigateToNext(cvc);
        }
    }

    @Override
    public void onContentBecameVisible() {
        super.onContentBecameVisible();
        updateAlarmButtonSelected();
        requery();
    }
}
