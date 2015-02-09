package gov.va.contentlib.controllers;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Resources;
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
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.haarman.listviewanimations.ArrayAdapter;
import com.haarman.listviewanimations.itemmanipulation.OnDismissCallback;
import com.haarman.listviewanimations.itemmanipulation.SwipeDismissAdapter;
import com.haarman.listviewanimations.itemmanipulation.SwipeDismissListViewTouchListener;
import com.haarman.listviewanimations.view.DynamicListView;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Goal;
import gov.va.daelib.R;

public class TreeView extends ContentViewController {

    final static int PADDING_ITEMS_WHILE_DRAGGING = 16;
    final static int TREE_LEVEL_INDENT = 80;

    BitmapDrawable treeBullet, treeBulletArrow, treeBulletOverlayEmpty, treeBulletOverlayHalf, treeBulletOverlayAlarm, treeBulletOverlayBang, addBullet;
    DynamicListView treeView;
	String selectionVariable;
    Paint black, blackFill, whiteFill;
    Goal root = null;
    Goal mDraggingCell;
    Goal mLocationReferenceCell;
    int mLocationReferenceY;
    int mLocationReferenceScrollTop;
    boolean mLocationReferenceFirstPass;
    DBAdapter adapter;
    String rootName;
    int baseIndent;

    class GoalUserData {
        boolean isBookend = false;
        boolean isDragging = false;
        boolean isAdd = false;
        boolean isEditing = false;
        int oldViewPos = -1;
    }

	public TreeView(Context ctx) {
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

        treeBullet = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet);
        treeBullet.setAntiAlias(true);
        treeBulletArrow = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet_arrow);
        treeBulletArrow.setAntiAlias(true);
        treeBulletOverlayEmpty = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet_overlay_empty);
        treeBulletOverlayEmpty.setAntiAlias(true);
        treeBulletOverlayHalf = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet_overlay_half);
        treeBulletOverlayHalf.setAntiAlias(true);
        treeBulletOverlayAlarm = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet_overlay_alarm);
        treeBulletOverlayAlarm.setAntiAlias(true);
        treeBulletOverlayBang = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.tree_bullet_overlay_bang);
        treeBulletOverlayBang.setAntiAlias(true);
        addBullet = (BitmapDrawable)ctx.getResources().getDrawable(R.drawable.add_icon72x72);
        addBullet.setAntiAlias(true);

        baseIndent = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, ctx.getResources().getDisplayMetrics());
    }

    public class TreeItemView extends LinearLayout {
        Goal goal;
        TreeStructureView structureView;
        TextView textView;
        EditText editText;
        boolean[] vertBarFlags = new boolean[16];
        boolean expanded;

        public TreeItemView(Context c) {
            super(c);
            setWillNotDraw(true);
            setOrientation(HORIZONTAL);

            LayoutParams p = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
            setLayoutParams(p);

            expanded = false;

            structureView = new TreeStructureView(c);
            p = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
            p.weight = 0;
            addView(structureView,p);

            Resources r = getResources();
            p = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
            p.weight = 1;
            p.topMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 19, r.getDisplayMetrics());
            p.rightMargin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 15, r.getDisplayMetrics());
            p.gravity = Gravity.TOP| Gravity.LEFT;

            textView = new TextView(c);
            textView.setTextAppearance(c, getResourceAttr(R.attr.contentTextAppearanceListItem));

            addView(textView, p);
        }

        public void clearVerticalBars() {
            for (int i=0;i<vertBarFlags.length;i++) {
                vertBarFlags[i] = false;
            }
        }

        @Override
        public void invalidate() {
            super.invalidate();
            structureView.invalidate();
        }

        public BitmapDrawable overlayForGoal(Goal goal, long now) {
            if (goal.getChildren().size() == 0) {
                if ((goal.dueDate != 0) && (goal.dueDate <= now)) {
                    return treeBulletOverlayBang;
                } else if (goal.doneState == 2) {
                    return null;
                } else if (goal.doneState == 1) {
                    return treeBulletOverlayHalf;
                } else {
                    return treeBulletOverlayEmpty;
                }
            } else {
                int minDoneState = Integer.MAX_VALUE;
                int maxDoneState = Integer.MIN_VALUE;
                for (Goal g : goal.getChildren()) {
                    BitmapDrawable o = overlayForGoal(g,now);
                    if (o == treeBulletOverlayBang) return treeBulletOverlayBang;
                    if (g.doneState < minDoneState) minDoneState = g.doneState;
                    if (g.doneState > maxDoneState) maxDoneState = g.doneState;
                }
                if (minDoneState == 2) return null;
                if (maxDoneState == 0) return treeBulletOverlayEmpty;
                return treeBulletOverlayHalf;
            }
        }

        public void doneEditing() {
            editText.clearFocus();
            ((GoalUserData)goal.userData).isEditing = false;
            goal.setDisplayName(editText.getText().toString());
            InputMethodManager imm = (InputMethodManager)getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(editText.getWindowToken(), 0);
            if (editText != null) {
                ViewGroup.LayoutParams lp = editText.getLayoutParams();
                textView.setText(goal.getDisplayName());
                textView.setLayoutParams(lp);
                addView(textView,indexOfChild(editText));
                removeView(editText);
                editText = null;
            }

            if (getBinding() == null) {
                goal.save();
            }
        }

        public void setGoal(Goal g) {
            goal = g;
            expanded = g.isExpanded;
            if (((GoalUserData)goal.userData).isEditing) {
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
                }
                int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
                setMinimumHeight(h);
                editText.setText(g.displayName);
                structureView.getLayoutParams().width = baseIndent + g.getTreeLevel(root)*TREE_LEVEL_INDENT;
                structureView.getLayoutParams().height = LayoutParams.MATCH_PARENT;
                editText.setVisibility(VISIBLE);
            } else {
                if (editText != null) {
                    ViewGroup.LayoutParams lp = editText.getLayoutParams();
                    textView.setLayoutParams(lp);
                    addView(textView,indexOfChild(editText));
                    removeView(editText);
                    editText = null;
                }
                if (((GoalUserData)goal.userData).isBookend) {
                    setMinimumHeight(60);
                    textView.setText(null);
                    structureView.getLayoutParams().width = LayoutParams.MATCH_PARENT;
                    structureView.getLayoutParams().height = LayoutParams.MATCH_PARENT;
                    textView.setVisibility(GONE);
                } else if (((GoalUserData)goal.userData).isAdd) {
                    int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
                    setMinimumHeight(h);
                    textView.setText(g.displayName);
                    structureView.getLayoutParams().width = addBullet.getIntrinsicWidth();
                    structureView.getLayoutParams().height = LayoutParams.MATCH_PARENT;
                    textView.setVisibility(VISIBLE);
                } else {
                    int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
                    setMinimumHeight(h);
                    textView.setText(g.displayName);
                    structureView.getLayoutParams().width = baseIndent + g.getTreeLevel(root)*TREE_LEVEL_INDENT;
                    structureView.getLayoutParams().height = LayoutParams.MATCH_PARENT;
                    textView.setVisibility(VISIBLE);
                }
            }

            long now = System.currentTimeMillis();
            structureView.overlay = overlayForGoal(goal,now);

            textView.requestLayout();
            requestLayout();
            invalidate();
        }

        @Override
        protected void dispatchDraw(Canvas canvas) {
            TextView tv = textView;
            if (((GoalUserData)goal.userData).isDragging && !treeView.isDrawingBitmap() && (tv.getVisibility() != View.INVISIBLE)) {
                tv.setVisibility(View.INVISIBLE);
            } else if ((!((GoalUserData)goal.userData).isDragging || treeView.isDrawingBitmap()) && (tv.getVisibility() == View.INVISIBLE)) {
                tv.setVisibility(View.VISIBLE);
            }
            super.dispatchDraw(canvas);
        }

        @Override
        public void draw(Canvas canvas) {
            TextView tv = textView;
            if (((GoalUserData)goal.userData).isDragging && !treeView.isDrawingBitmap() && (tv.getVisibility() != View.INVISIBLE)) {
                tv.setVisibility(View.INVISIBLE);
            } else if ((!((GoalUserData)goal.userData).isDragging || treeView.isDrawingBitmap()) && (tv.getVisibility() == View.INVISIBLE)) {
                tv.setVisibility(View.VISIBLE);
            }
            super.draw(canvas);
        }


        class TreeStructureView extends View {
            Rect bounds = new Rect();
            public BitmapDrawable overlay = treeBulletOverlayEmpty;

            TreeStructureView(Context c) {
                super(c);
                setClickable(true);
                setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (!goal.getChildren().isEmpty()) {
                            goal.isExpanded = !goal.isExpanded;
                            if (getBinding() == null) {
                                goal.save();
                            }
                            adapter.refreshGoalList(false,false);
                        }

                    }
                });
            }

            @Override
            protected void onDraw(Canvas canvas) {
                super.onDraw(canvas);

                float indent = ((goal.getTreeLevel(root)-1)*TREE_LEVEL_INDENT - 30) +0.5f;
                int width = getWidth();
                int height = getHeight();

                Path path = new Path();
                float[] pts = new float[32];
                float iconv = 19*5 + 0.5f;

                if (((GoalUserData)goal.userData).isAdd) {
                    int w = width/2 ;
                    int h = w;
                    int centerX = width/2;
                    int centerY = (int)iconv;
                    int left = centerX - (w/2);
                    int top = centerY - (h/2);
                    bounds.set(left, top, left + w, top + h);
                    addBullet.setBounds(bounds);
                    addBullet.draw(canvas);
                    return;
                }

                if (!treeView.isDrawingBitmap()) {
                    for (int i=1;i<vertBarFlags.length;i++) {
                        if (vertBarFlags[i]) {
                            float x = ((i-1)*TREE_LEVEL_INDENT - 30) +0.5f;
                            path.moveTo(x, 0);
                            path.lineTo(x, height);
                        }
                    }
                }

                boolean drawCircle = false;
                if (((GoalUserData)goal.userData).isBookend) {
                    float middlev = (height/2.0f) - 0.5f;
                    path.moveTo(indent,0);
                    path.lineTo(indent,middlev);
                    path.lineTo(width,middlev);
                } else {
                    float middlev = iconv;
                    boolean started = false;

                    if (!((GoalUserData)goal.userData).isDragging || treeView.isDrawingBitmap()) {
                        if (goal.getTreeLevel(root) > 1) {
                            if (treeView.isDrawingBitmap()) {
                                path.moveTo(indent, middlev);
                            } else {
                                path.moveTo(indent, 0);
                                path.lineTo(indent, middlev);
                            }
                            path.lineTo(indent+TREE_LEVEL_INDENT,middlev);
                            started = true;
                        }

                        if (expanded) {
                            if (!started) {
                                path.moveTo(indent + TREE_LEVEL_INDENT, middlev);
                            }
                            path.lineTo(indent+TREE_LEVEL_INDENT,height);
                        }

                        drawCircle = true;
                    }
                }

                canvas.drawPath(path,black);
                if (drawCircle) {
                    int w = treeBullet.getIntrinsicWidth();
                    int h = treeBullet.getIntrinsicHeight();
                    int centerX = (int)(indent+TREE_LEVEL_INDENT);
                    int centerY = (int)iconv;
                    int left = centerX - (w/2);
                    int top = centerY - (h/2);
                    bounds.set(left, top, left + w, top + h);

                    if (!goal.getChildren().isEmpty()) {
                        if (expanded) {
                            canvas.save();
                            canvas.rotate(90,left+(w/2.0f),top+(h/2.0f));
                        }
                        treeBulletArrow.setBounds(bounds);
                        treeBulletArrow.draw(canvas);
                        if (expanded) {
                            canvas.restore();
                        }
                    } else {
                        treeBullet.setBounds(bounds);
                        treeBullet.draw(canvas);
                    }

                    if (overlay != null) {
                        overlay.setBounds(bounds);
                        overlay.draw(canvas);
                    }
                }
            }
        }
    }

    public class DBAdapter extends ArrayAdapter<Goal> {

        List<Goal> oldList = null;

        public void onDismiss(Goal g) {
            mItems.remove(g);
        }

        public void addChildren(boolean dragging, List<Goal> list, boolean force, Goal goal) {
            if ((goal.isExpanded || force) && !goal.equals(mDraggingCell)) {
                for (Goal g : goal.getChildren()) {
                    if (g.userData == null) g.userData = new GoalUserData();
                    list.add(g);
                    addChildren(dragging,list,force,g);
                }
            }
            if (dragging && !goal.equals(mDraggingCell)) {
                Goal bookend = new Goal();
                bookend.setParent(goal);
                bookend.userData = new GoalUserData();
                bookend.recordID = goal.getID() + 1024;
                ((GoalUserData)bookend.userData).isBookend = true;
                bookend.setTransient(true);
                list.add(bookend);
            }
        }

        @Override
        public void swapItems(int positionOne, int positionTwo) {
            Goal o1 = getItem(positionOne);
            Goal o2 = getItem(positionTwo);
            set(positionOne, o2);
            set(positionTwo, o1);
            if (mDraggingCell != null) {
                int pos = mItems.indexOf(mDraggingCell);
                if (pos == mItems.size()-1) {
                    mDraggingCell.setParent(root);
                } else {
                    o1 = getItem(pos+1);
                    if (o1.parent == null) {
                        root.addChild(mDraggingCell);
                    } else {
                        if (((GoalUserData)o1.userData).isBookend) {
                            o1.parent.addChild(mDraggingCell);
                        } else {
                            o1.parent.addChild(mDraggingCell, o1);
                        }
                        if (getBinding() == null) {
                            o1.parent.save();
                            root.save(false);
                        }
                    }
                }

                final ViewTreeObserver observer = treeView.getViewTreeObserver();
                observer.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
                    @Override
                    public boolean onPreDraw() {
                        if (!observer.isAlive()) return true;
                        observer.removeOnPreDrawListener(this);
                        treeView.updateHoverView();
                        return true;
                    }
                });
            }
        }

        public void reloadGoalList() {
            Goal g = (Goal)getVariable("@binding");
            if (g == null) {
                if ((rootName != null) && rootName.equals("EXAMPLES")) {
                    g = Goal.getExampleRoot();
                } else {
                    g = Goal.getRoot();
                }
            }
            root = g;
            refreshGoalList(false,true);
        }

        public void refreshGoalList(boolean dragging, final boolean immediate) {
            ArrayList<Goal> list = new ArrayList<Goal>();

            if (dragging) {
                /*
                for (int i=0;i<PADDING_ITEMS_WHILE_DRAGGING;i++) {
                    Goal g = new Goal();
                    g.isTransient = true;
                    g.recordID = 2048+i;
                    g.displayName = "";
                    g.setTreeLevel(0);
                    g.userData = new GoalUserData();
                    list.add(g);
                }
                */
            }

            List<Goal> rootChildren = root.getChildren();
            Boolean b = (Boolean)getVariable("treeHasItems");
            if ((b == null) || (b == rootChildren.isEmpty())) {
                setLocalVariable("treeHasItems",!rootChildren.isEmpty());
            }
            for (Goal g : rootChildren) {
                if (g.userData == null) g.userData = new GoalUserData();
                list.add(g);
                addChildren(dragging,list,dragging,g);
            }

            oldList = new ArrayList<Goal>(mItems);

            for (Goal g : oldList) {
                View v = treeView.getViewForID(g.getID());
                if (v != null) {
                    ((GoalUserData)g.userData).oldViewPos = v.getTop();
                } else {
                    ((GoalUserData)g.userData).oldViewPos = -1;
                }
            }

            if (!dragging) {
                Goal g = new Goal();
                g.setTransient(true);
                g.recordID = 5192;
                g.displayName = "Add Goal...";
                g.setTreeLevel(0);
                GoalUserData ud = new GoalUserData();
                ud.isAdd = true;
                g.userData = ud;
                list.add(g);
            }

            if (dragging) {
                for (int i=0;i<PADDING_ITEMS_WHILE_DRAGGING;i++) {
                    Goal g = new Goal();
                    g.setTransient(true);
                    g.recordID = 4096+i;
                    g.displayName = "";
                    g.setTreeLevel(0);
                    g.userData = new GoalUserData();
                    list.add(g);
                }
            }

            mItems.clear();
            mItems.addAll(list);

            final ViewTreeObserver observer = treeView.getViewTreeObserver();
            observer.addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {

                int scrollBy=0;

                public boolean onPreDraw() {
                    if (!observer.isAlive()) return true;

                    if (isInline()) {
                        boolean resized = resizeToMaximumHeight();
                        if (resized) return false;
                    }

                    if (mLocationReferenceCell != null) {
                        int newpos = mItems.indexOf(mLocationReferenceCell);
                        treeView.setSelectionFromTop(newpos+treeView.getHeaderViewsCount(),mLocationReferenceY-mLocationReferenceScrollTop);
                        mLocationReferenceCell = null;
                        return false;
                    }

                    observer.removeOnPreDrawListener(this);

                    for (int pos=0;pos<mItems.size();pos++) {
                        Goal g = mItems.get(pos);
                        View v = treeView.getViewForID(g.getID());
                        if (v != null) {
                            for (Goal oldgoal : oldList) {
                                if (oldgoal.getID() == g.getID()) {
                                    g = oldgoal;
                                    break;
                                }
                            }
                            if (!immediate) {
                                int oldViewPos = ((GoalUserData)g.userData).oldViewPos;
                                if ((oldViewPos != -1) && oldList.contains(g)) {
                                    float offset = (v.getTop()-oldViewPos-scrollBy);
                                    if (offset != 0) {
                                        v.setAlpha(1);
                                        v.setTranslationY(-offset);
                                        v.animate().translationY(0).setDuration(300);
                                    }
                                } else /*if (!oldList.contains(g))*/ {
                                    v.setAlpha(0);
                                    v.animate().alpha(1).setDuration(300);
                                }
                            }
                            ((GoalUserData)g.userData).oldViewPos = -1;
                            if (((GoalUserData)g.userData).isEditing) {
                                TreeItemView tiv = (TreeItemView)v;
                                tiv.editText.requestFocus();
                                InputMethodManager mgr = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                                mgr.showSoftInput(tiv.editText, InputMethodManager.SHOW_IMPLICIT);
                            }
                        }
                    }
                    return true;
                }

            });


            notifyDataSetChanged();
        }

        @Override
        public boolean hasStableIds() {
            return true;
        }

        @Override
        public long getItemId(int position) {
            Goal g = getItem(position);
            return g.getID();
        }


        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            TreeItemView v = (TreeItemView)convertView;
            final Goal g = getItem(position);
            if (v == null) {
                v = new TreeItemView(getContext());
            }
            ViewGroup.LayoutParams lp = v.getLayoutParams();
            if (lp == null) lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.width = ViewGroup.LayoutParams.MATCH_PARENT;
            lp.height = ViewGroup.LayoutParams.WRAP_CONTENT;
            v.setLayoutParams(lp);
            v.setGoal(g);

            Goal nextGoal = (position+1 < getCount()) ? getItem(position+1) : null;
            v.expanded = (nextGoal != null) && (nextGoal.getTreeLevel(root) > g.getTreeLevel(root));

            int treeLevel = g.getTreeLevel(root);
            for (int i=0;i<v.vertBarFlags.length;i++) v.vertBarFlags[i] = false;
            for (int pos=position+1;pos<getCount();pos++) {
                nextGoal = getItem(pos);
                int l = nextGoal.getTreeLevel(root);
                if (l > treeLevel) continue;
                if (l <= 1) break;
                treeLevel = l;
                v.vertBarFlags[treeLevel] = true;
            }
            v.invalidate();

            return v;
        }


    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        ContentViewControllerBase headerController = null;
        Content headerContent = getContent().getChildByName("@header");
        if (headerContent != null) {
            headerController = headerContent.createContentView(this, getContext(), true);
            addChildController(headerController);
        }

        if (isInline()) {
            View divider = new View(getContext());
            Drawable dividerDrawable = getContentResources().getDrawable(android.R.drawable.divider_horizontal_bright);
            divider.setBackgroundDrawable(dividerDrawable);
            divider.setMinimumHeight(dividerDrawable.getIntrinsicHeight());
            clientView.addView(divider, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dividerDrawable.getIntrinsicHeight()));
        }

        rootName = getContent().getStringAttribute("root");

        adapter = new DBAdapter();
        treeView = new DynamicListView(getContext()) {
            public void onDragFinished() {
                if (mDraggingCell != null) {
                    final long id = mDraggingCell.getID();
                    View v = treeView.getViewForID(id);
                    ((GoalUserData)mDraggingCell.userData).isDragging = false;

                    Goal p = mDraggingCell.parent;
                    while (p != null) {
                        p.expand();
                        if (getBinding() == null) {
                            p.save();
                        }
                        p = p.parent;
                    }

                    if (v != null) {
                        mLocationReferenceScrollTop = treeView.getScrollY();
                        mLocationReferenceY = v.getTop();
                        mLocationReferenceCell = mDraggingCell;
                        mDraggingCell = null;
                    }
                }
                adapter.refreshGoalList(false,false);
            }
        };
        treeView.setDivider(null);

        if (isInline()) {
            treeView.setLayoutParams(new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            treeView.setScrollContainer(false);
//            treeView.setIsParentHorizontalScrollContainer(true);
        } else {
            treeView.setLayoutParams(new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }

        if (headerController != null) {
            treeView.addHeaderView(headerController.getView(),null,false);
        }

        SwipeDismissAdapter dismissAdapter = new SwipeDismissAdapter(adapter,new OnDismissCallback() {

            @Override
            public void onDismiss(AbsListView listView, int[] reverseSortedPositions) {

                for (int position : reverseSortedPositions) {
                    Goal g = adapter.getItem(position);
                    adapter.onDismiss(g);
                    g.delete();
                }

                if ((getBinding() == null) && (root != null)) {
                    root.save();
                }

                adapter.refreshGoalList(false,true);
            }
        }) {
            protected SwipeDismissListViewTouchListener createListViewTouchListener(AbsListView listView) {
                return new SwipeDismissListViewTouchListener(listView, mCallback, mOnScroll) {

                    private void gatherChildViews(Goal parent, List<View> list) {
                        if (!parent.isExpanded) return;
                        for (Goal g : parent.getChildren()) {
                            View v = treeView.getViewForID(g.getID());
                            if (v != null) list.add(v);
                            gatherChildViews(g,list);
                        }
                    }

                    protected List<View> getAllTreeChildViews(View v) {
                        if (v instanceof TreeItemView) {
                            ArrayList<View> list = new ArrayList<View>();
                            Goal g = ((TreeItemView)v).goal;
                            gatherChildViews(g,list);
                            return list;
                        }

                        return Collections.emptyList();
                    }

                    @Override
                    protected void onDismiss(final PendingDismissData data) {
                        class DismissConfirmationDialogFragment extends DialogFragment {
                            @Override
                            public Dialog onCreateDialog(Bundle savedInstanceState) {
                                // Use the Builder class for convenient dialog construction
                                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                                builder.setTitle("Confirm Deletion");
                                builder.setMessage("Do you really want to delete this item?")
                                        .setPositiveButton("Yes, delete it", new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int id) {
                                                performDismiss(data);
                                            }
                                        })
                                        .setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
                                            public void onClick(DialogInterface dialog, int id) {
                                                cancelDismiss();
                                            }
                                        });
                                // Create the AlertDialog object and return it
                                return builder.create();
                            }
                        }

                        DismissConfirmationDialogFragment frag = new DismissConfirmationDialogFragment();
                        frag.show(getContentActivity().getSupportFragmentManager(),"deleteConfirmationDialog");
                    }
                };
            }
        };

        treeView.setAdapter(dismissAdapter);
        dismissAdapter.setAbsListView(treeView);
        clientView.addView(treeView);

        final AdapterView.OnItemLongClickListener oldListener = treeView.getOnItemLongClickListener();
        treeView.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {
            @Override
            public boolean onItemLongClick(final AdapterView<?> parent, final View view, int position, final long id) {
                position -= treeView.getHeaderViewsCount();
                final Goal target = adapter.getItem(position);
                if (((GoalUserData)target.userData).isAdd) {
                    return false;
                }
                mDraggingCell = target;
                mLocationReferenceScrollTop = treeView.getScrollY();
                mLocationReferenceY = view.getTop();
                mLocationReferenceCell = mDraggingCell;

                final ViewTreeObserver observer = treeView.getViewTreeObserver();
                observer.addOnDrawListener(new ViewTreeObserver.OnDrawListener() {
                    public void onDraw() {
                        observer.removeOnDrawListener(this);

                        treeView.post(new Runnable() {
                            @Override
                            public void run() {
                                ((GoalUserData) target.userData).isDragging = true;
                                final int newPos = adapter.indexOf(target);
                                View v = treeView.getViewForID(id);
                                oldListener.onItemLongClick(parent, v, newPos+treeView.getHeaderViewsCount(), id);
                            }
                        });
                    }
                });

                adapter.refreshGoalList(true,false);

                return true;
            }
        });

        treeView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Goal g = (Goal) adapter.getItem(position-treeView.getHeaderViewsCount());
                if (((GoalUserData)g.userData).isAdd) {
                    Goal newGoal = new Goal();
                    newGoal.isExpanded = true;
                    GoalUserData ud = new GoalUserData();
                    ud.isEditing = true;
                    newGoal.userData = ud;
                    root.addChild(newGoal);
                    adapter.refreshGoalList(false,false);
                    return;
                }
                Content editContent = getContent().getChildByName("@add");
                ContentViewControllerBase cvc = editContent.createContentView(TreeView.this,getContext());
                cvc.setLocalVariable("@binding", g);
                navigateToNext(cvc);
            }
        });

//        list.setAdapter(adapter);

    }

    @Override
    public void onContentBecameVisibleForFirstTime() {
        super.onContentBecameVisibleForFirstTime();
        if (isInline()) {
            treeView.setProxyScroller();
        }
        adapter.reloadGoalList();
    }

    @Override
    public void onContentBecameVisible() {
        super.onContentBecameVisible();
        adapter.refreshGoalList(false, true);
    }

    public boolean resizeToMaximumHeight() {
        int totalHeight = 0;

        for (int i = 0; i < adapter.getCount(); i++) {
            View mView = adapter.getView(i, null, treeView);

            mView.measure(View.MeasureSpec.makeMeasureSpec(treeView.getWidth(), View.MeasureSpec.EXACTLY),
                          View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED));

            totalHeight += mView.getMeasuredHeight();
        }

        ViewGroup.LayoutParams params = treeView.getLayoutParams();
        int h = totalHeight + (treeView.getDividerHeight() * (adapter.getCount() - 1));
        h += treeView.getListPaddingTop() + treeView.getListPaddingBottom();
        if (params.height != h) {
            params.height = h;
            treeView.setLayoutParams(params);
            treeView.requestLayout();
            return true;
        } else {
            return false;
        }
    }
}
