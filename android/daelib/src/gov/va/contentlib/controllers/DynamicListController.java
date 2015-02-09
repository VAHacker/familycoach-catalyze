package gov.va.contentlib.controllers;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Paint;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.text.InputType;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.CheckBox;
import android.widget.Checkable;
import android.widget.CursorAdapter;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.ListView;
import android.widget.TextView;

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
import java.util.TreeMap;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Goal;
import gov.va.contentlib.content.JournalEntry;
import gov.va.contentlib.content.NamedNumber;
import gov.va.daelib.R;

public class DynamicListController extends ContentViewController {

    DynamicListView listView;
	String selectionVariable;
    Paint black, blackFill, whiteFill;
    DBAdapter adapter;
    String addStyle;
    String entityName;
    AddFooter addItem;

    public DynamicListController(Context ctx) {
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

    public class AddFooter extends FrameLayout {
        TextView textView;
        EditText editText;

        public AddFooter(Context ctx) {
            super(ctx);
            textView = new TextView(ctx);
            textView.setText("Add an item...");
            textView.setTextAppearance(getContext(), getResourceAttr(android.R.attr.textAppearanceListItemSmall));
            textView.setGravity(Gravity.CENTER_VERTICAL | Gravity.LEFT);
            addView(textView, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }

        public void startEditing() {
            if (editText == null) {
                editText = new EditText(getContext());
                editText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                    @Override
                    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                        boolean handled = false;
                        if (actionId == EditorInfo.IME_ACTION_DONE) {
                            doneEditing();
                            handled = true;
                        }
                        return handled;
                    }
                });
                ViewGroup.LayoutParams lp = textView.getLayoutParams();
                editText.setLayoutParams(lp);
                editText.setInputType(InputType.TYPE_CLASS_TEXT);
                addView(editText, indexOfChild(textView));
                removeView(textView);
                editText.requestFocus();
                InputMethodManager mgr = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                mgr.showSoftInput(editText, InputMethodManager.SHOW_IMPLICIT);
            }
        }

        public void doneEditing() {
            editText.clearFocus();
            InputMethodManager imm = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
            if (editText != null) {

                ContentValues values = new ContentValues(2);
                values.put("displayName",editText.getText().toString());
                values.put("userAdded",1);
                getUserDB().sql().insert(entityName, null, values);
                refreshCursor();

                ViewGroup.LayoutParams lp = editText.getLayoutParams();
                textView.setLayoutParams(lp);
                addView(textView,indexOfChild(editText));
                removeView(editText);
                editText = null;
            }
        }

    }

    public class DBAdapter extends CursorAdapter {

        public DBAdapter(Context ctx, Cursor c) {
            super(ctx,c,true);
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            TextView tv =(TextView)view.findViewById(android.R.id.text1);
            long id = cursor.getLong(cursor.getColumnIndex("_id"));
            tv.setText(cursor.getString(cursor.getColumnIndex("displayName")));
            Object o = getVariable(selectionVariable);
            boolean checkIt = false;
            if (o instanceof long[]) {
                long[] ids = (long[])o;
                if (ids != null) {
                    for (long i:ids) {
                        if (id == i) {
                            checkIt = true;
                            break;
                        }
                    }
                }
            } else if (o instanceof Number) {
                if (id == ((Number)o).longValue()) {
                    checkIt = true;
                }

            }

            Checkable cb = null;
            if (view instanceof Checkable) {
                cb = (Checkable)view;
            } else {
                cb =(CheckBox)view.findViewById(android.R.id.checkbox);
            }
            cb.setChecked(checkIt);
        }

        @Override
        public View newView(Context context, Cursor cursor, ViewGroup parent) {
            LayoutInflater inflater = LayoutInflater.from(getContext());
            int res;
            if (getContent().getBoolean("selectMulti")) {
                res = android.R.layout.simple_list_item_multiple_choice;
            } else {
                res = android.R.layout.simple_list_item_single_choice;
            }
            View view = inflater.inflate(res,null);
            ViewGroup.LayoutParams lp = view.getLayoutParams();
            if (lp == null) lp = new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.width = ViewGroup.LayoutParams.MATCH_PARENT;
            lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            view.setLayoutParams(lp);
            int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
            view.setMinimumHeight(h);
            return view;
        }
    }

    public void refreshCursor() {
        Cursor c = getUserDB().sql().query(entityName,new String[]{"_id","displayName","userAdded"},null,null,null,null,"displayName ASC");
        adapter.changeCursor(c);
        adapter.notifyDataSetChanged();
    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        selectionVariable = getContent().getStringAttribute("selectionVariable");
        addStyle = getContent().getStringAttribute("addStyle");
        entityName = getContent().getStringAttribute("entityName").toLowerCase();

        ContentViewControllerBase headerController = null;
        Content headerContent = getContent().getChildByName("@header");
        if (headerContent != null) {
            headerController = headerContent.createContentView(this, getContext(), true);
            addChildController(headerController);
        }

        Cursor c = getUserDB().sql().query(entityName,new String[]{"_id","displayName","userAdded"},null,null,null,null,"displayName ASC");
        TreeMap<Long,Long> idToPosition = new TreeMap<Long, Long>();
        int position = 0;
        while (c.moveToNext()) {
            long id = c.getLong(c.getColumnIndex("_id"));
            idToPosition.put(id,(long)position);
            position++;
        }

        adapter = new DBAdapter(getContext(),c);
        listView = new DynamicListView(getContext());
        listView.setLayoutParams(new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        if (headerController != null) {
            listView.addHeaderView(headerController.getView(),null,false);
        }

        if (addStyle != null) {
            AddFooter addLabel = new AddFooter(getContext());
            int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
            int l = (int)getDimAttr(R.attr.contentListPreferredItemPaddingLeft);
            int r = (int)getDimAttr(R.attr.contentListPreferredItemPaddingRight);
            addLabel.setMinimumHeight(h);
            ListView.LayoutParams lp = new ListView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.height = h;
            addLabel.setLayoutParams(lp);
            addLabel.setPadding(l,0,r,0);
            addItem = addLabel;

            if ("first".equals(addStyle)) {
                listView.addHeaderView(addItem,null,true);
            } else {
                listView.addFooterView(addItem,null,true);
            }
        }

        if (getContent().getBoolean("selectMulti")) {
            listView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        } else {
            listView.setChoiceMode(ListView.CHOICE_MODE_SINGLE);
        }

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                if (view == addItem) {
                    addItem.startEditing();
                    return;
                }
                long[] ids = listView.getCheckedItemIds();
                if (getContent().getBoolean("selectMulti")) {
                    setVariable(selectionVariable,ids);
                } else {
                    TextView tv =(TextView)view.findViewById(android.R.id.text1);
                    setVariable(selectionVariable,new NamedNumber(tv.getText(),ids[0]));
                }
            }
        });

        SwipeDismissAdapter dismissAdapter = new SwipeDismissAdapter(adapter, new OnDismissCallback() {
            @Override
            public void onDismiss(AbsListView listView, int[] reverseSortedPositions) {
                for (int pos:reverseSortedPositions) {
                    Cursor c = (Cursor)adapter.getItem(pos);
                    if (c != null) {
                        getUserDB().sql().delete(entityName,"_id=?",new String[]{""+c.getLong(0)});
                    }
                }
                refreshCursor();
            }
        }) {
            protected SwipeDismissListViewTouchListener createListViewTouchListener(AbsListView listView) {
                return new SwipeDismissListViewTouchListener(listView, mCallback, mOnScroll) {
                    @Override
                    protected void onDismiss(final PendingDismissData data) {
                        Cursor c = (Cursor)adapter.getItem(data.position);
                        if (c != null) {
                            if (c.getLong(c.getColumnIndex("userAdded")) != 0) {
                                performDismiss(data);
                                adapter.notifyDataSetChanged();
                                return;
                            }
                        }

                        class DismissConfirmationDialogFragment extends DialogFragment {
                            @Override
                            public Dialog onCreateDialog(Bundle savedInstanceState) {
                                // Use the Builder class for convenient dialog construction
                                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                                builder.setTitle("Can Not Delete");
                                builder.setMessage("Sorry, you cannot delete items you did not add.")
                                        .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int id) {
                                            }
                                        });
                                // Create the AlertDialog object and return it
                                return builder.create();
                            }

                            @Override
                            public void onDismiss(DialogInterface dialog) {
                                super.onDismiss(dialog);
                                cancelDismiss();
                                adapter.notifyDataSetChanged();
                            }
                        }

                        DismissConfirmationDialogFragment frag = new DismissConfirmationDialogFragment();
                        frag.show(getContentActivity().getSupportFragmentManager(),"deleteRejectionDialog");

                    }
                };
            }

        };
        dismissAdapter.setAbsListView(listView);

        listView.setAdapter(dismissAdapter);

        Object o = getVariable(selectionVariable);
        long[] ids = null;
        if (o instanceof long[]) {
            ids = (long[])o;
        } else if (o instanceof Number) {
            ids = new long[] {((Number)o).longValue()};
        }
        if (ids != null) {
            for (long i:ids) {
                Long pos = idToPosition.get(i);
                if (pos != null) {
                    listView.setItemChecked(pos.intValue(),true);
                }
            }
        }

        clientView.addView(listView);
    }

    @Override
    public void onContentBecameInvisible() {
        super.onContentBecameInvisible();
    }
}
