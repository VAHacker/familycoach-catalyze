package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContentList;
import gov.va.contentlib.views.InlineList;
import gov.va.daelib.R;

import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.graphics.PorterDuff.Mode;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.StateListDrawable;
import android.graphics.drawable.shapes.RectShape;
import android.net.Uri;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.FrameLayout.LayoutParams;

public class ContentListViewController extends ContentViewControllerBase {

	InlineList list;
	boolean pick = false;
	boolean multi = false;

	public ContentListViewController(Context ctx) {
		super(ctx);
	}
	
	public List<Content> getContentList() {
		return content.getChildren();
	}
	
	public InlineList createList() {
		ContentList list = new ContentList(this, getContentList());
		list.setOnItemClickListener(new InlineList.OnItemClickListener() {
			public void onItemClick(int i, View v, Object item) {
				contentSelected((Content)item);
			}
		});

		return list;
	}

	@Override
	public boolean shouldUseScroller() {
		return !isInline();
	}

	public int getBadgeValue() {
		return list.getItems().size();
	}

	public boolean hasAnyContent() {
		return getBadgeValue() > 0;
	}

	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		
		if (true) { //isInline()) {
			pick = getContent().getBoolean("pick");
			multi = getContent().getBoolean("multi");
			String settingKey = getContent().getStringAttribute("settingKey");
			String variableKey = getContent().getStringAttribute("variableKey");

			list = createList();
			list.setPickMode(pick);
			list.setRadioBehavior(!multi);

			if (settingKey != null) {
				list.bindToSetting(settingKey, true);
			} else if (variableKey != null) {
				list.bindToVariable(variableKey, true);
			}

			LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
			clientView.addView(list, p);
		} else {
/*			
			setBackgroundColor(0xFF000000);
			setDrawingCacheBackgroundColor(0xFF000000);

			final ListView list = new ListView(getContext());
			list.setBackgroundColor(0xFF000000);
			list.setDrawingCacheBackgroundColor(0xFF000000);
			list.setCacheColorHint(0xFF000000);
			addView(list);

			children = getContent().getChildren();
			String[] items = new String[children.size()];
			for (int i=0;i<items.length;i++) {
				items[i] = children.get(i).displayName;
			}
			RectShape rect = new RectShape();
			ShapeDrawable shapeDrawable = new ShapeDrawable(rect);
			shapeDrawable.setColorFilter(0xFF808080, Mode.SRC);
			list.setDivider(shapeDrawable);
			list.setDividerHeight(1);

			StateListDrawable selector = new StateListDrawable();

			ShapeDrawable selectedDrawable = new ShapeDrawable(rect);
			selectedDrawable.setColorFilter(0xFF80FF80, Mode.SRC);
			selector.addState(new int[] {android.R.attr.state_pressed}, selectedDrawable);
			selector.addState(new int[] {android.R.attr.state_selected}, selectedDrawable);

			final ShapeDrawable focusedDrawable = new ShapeDrawable(rect);
			focusedDrawable.setColorFilter(0xFF80FF80, Mode.SRC);
			selector.addState(new int[] {android.R.attr.state_focused}, focusedDrawable);

			list.setSelector(selector);
			//		list.setFocusable(true);
			list.setItemsCanFocus(true);

			list.setAdapter(new ArrayAdapter<String>(getContext(),R.layout.list_item_with_disclosure,items) {
				@Override
				public View getView(int position, View convertView, ViewGroup parent) {
					View row = convertView;

					if (row == null) {
						LayoutInflater inflater = LayoutInflater.from(this.getContext());
						row = inflater.inflate(R.layout.list_item_with_disclosure,null);

						RectShape rect = new RectShape();
						final ShapeDrawable focusedDrawable = new ShapeDrawable(rect);
						focusedDrawable.setColorFilter(0xFF60A060, Mode.SRC);

						row.setOnFocusChangeListener(new OnFocusChangeListener() {
							@Override
							public void onFocusChange(View v, boolean hasFocus) {
								if (hasFocus) {
									v.setBackgroundDrawable(focusedDrawable);
								} else {
									v.setBackgroundDrawable(null);
								}
							}
						});

						//		            ImageView disclosure = (ImageView)row.findViewById(R.id.disclosure);
						//	            disclosure.setImageResource(R.drawable.disclosure);
					}

					TextView label = (TextView)row.findViewById(R.id.term);
					label.setText(this.getItem(position));

					row.setOnClickListener(new OnClickListener() {
						@Override
						public void onClick(View v) {
							v.requestFocus();
							int position = list.getPositionForView(v);
							contentSelected(children.get((int)position));
						}
					});
					row.setFocusable(true);

					return row;
				}			

			});
			list.setOnItemClickListener(new ListView.OnItemClickListener() {
				@Override
				public void onItemClick(android.widget.AdapterView<?> list, View child, int position, long rowid) {
					contentSelected(children.get((int)position));
				}
			});
*/		
		}
	}
	
}
