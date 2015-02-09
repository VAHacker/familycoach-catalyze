package gov.va.contentlib.views;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;
import android.view.ViewGroup;

public class GridLayout extends ViewGroup {

	int columns;
	int outerMarginX, outerMarginY;
	int cellSpacingX, cellSpacingY;
	
	public GridLayout(Context ctx) {
		super(ctx);
//		setFocusable(true);
//		setDescendantFocusability(FOCUS_BEFORE_DESCENDANTS);
	}
	
	public void setColumns(int cols) {
		this.columns = cols;
		requestLayout();
	}
/*	
	@Override
	public void requestChildFocus(View child, View focused) {
		View fv = (getChildCount() >= 2) ? getChildAt(1) : null;
		View lv = (getChildCount() >= 2) ? getChildAt(getChildCount()-2) : null;
		if (focused == fv) {
			super.requestChildFocus(getChildAt(0), getChildAt(0));
//			getChildAt(0).requestFocus();
		} else if (focused == lv) {
			getChildAt(getChildCount()-1).requestFocus();
		} else {
			super.requestChildFocus(child, focused);
		}
	}
	
	@Override
	public boolean requestFocus(int direction, Rect previouslyFocusedRect) {
		// TODO Auto-generated method stub
		return super.requestFocus(direction, previouslyFocusedRect);
	}
	
	@Override
	public boolean onRequestFocusInDescendants(int direction, Rect previouslyFocusedRect) {
		if ((direction == View.FOCUS_DOWN) || (direction == View.FOCUS_RIGHT) || (direction == View.FOCUS_FORWARD)) {
			getChildAt(0).requestFocus();
		} else if ((direction == View.FOCUS_UP) || (direction == View.FOCUS_LEFT) || (direction == View.FOCUS_BACKWARD)) {
			getChildAt(getChildCount() - 1).requestFocus();
		}
		return true;
	}
	
	@Override
	protected void onFocusChanged(boolean gainFocus, int direction, Rect previouslyFocusedRect) {
		super.onFocusChanged(gainFocus, direction, previouslyFocusedRect);
		if (gainFocus) {
			if ((direction == View.FOCUS_DOWN) || (direction == View.FOCUS_RIGHT) || (direction == View.FOCUS_FORWARD)) {
				getChildAt(0).requestFocus();
			} else if ((direction == View.FOCUS_UP) || (direction == View.FOCUS_LEFT) || (direction == View.FOCUS_BACKWARD)) {
				getChildAt(getChildCount() - 1).requestFocus();
			}
		}
	}
	
	@Override
	public void addView(View child, LayoutParams lp) {
		int newId = child.getId();
		View lastView = null;
		super.addView(child,lp);
		if (getChildCount() > 1) {
			lastView = getChildAt(getChildCount()-2);
			int lastId = lastView.getId();
			lastView.setNextFocusDownId(newId);
			lastView.setNextFocusRightId(newId);
			child.setNextFocusUpId(lastId);
			child.setNextFocusLeftId(lastId);
		}
	}
*/	
	public void setOuterMargins(int outerMarginX, int outerMarginY) {
		this.outerMarginX = outerMarginX;
		this.outerMarginY = outerMarginY;
		requestLayout();
	}
	
	public void setCellSpacing(int cellSpacingX, int cellSpacingY) {
		this.cellSpacingX = cellSpacingX;
		this.cellSpacingY = cellSpacingY;
		requestLayout();
	}
	
	@Override
	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
	}
	
	@Override
	protected void onLayout(boolean changed, int l, int t, int r, int b) {
		int width = r-l;
		float widthMinusMargin = width - (outerMarginX * 2);
		int height = b-t;
		float heightMinusMargin = height - (outerMarginY * 2);
		
		int rows = getChildCount() / columns;

		float childPlusSpacingWidth = (widthMinusMargin + cellSpacingX) / columns;
		float childPlusSpacingHeight = (heightMinusMargin + cellSpacingY) / rows;
		float childWidth = childPlusSpacingWidth - cellSpacingX;
		float childHeight = childPlusSpacingHeight - cellSpacingY;
		
		int childIndex = 0;
outer:	for (int row = 0; row < rows; row++) {
			for (int col = 0; col < columns; col++) {
				if (childIndex >= getChildCount()) break outer;
				float childL = outerMarginX + childPlusSpacingWidth * col;
				float childT = outerMarginY + childPlusSpacingHeight * row;
				float childR = childL + childWidth;
				float childB = childT + childHeight;

				View child = getChildAt(childIndex);
				l = Math.round(childL);
				t = Math.round(childT);
				r = Math.round(childR);
				b = Math.round(childB);
				child.measure(MeasureSpec.makeMeasureSpec(r-l, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(b-t, MeasureSpec.EXACTLY));
				child.layout(l, t, r, b);
				
				childIndex++;
			}
		}
	}
	
}
