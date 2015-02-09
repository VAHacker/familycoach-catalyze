package gov.va.contentlib.views;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.daelib.R;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.TreeMap;

import com.actionbarsherlock.internal.widget.IcsLinearLayout;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.graphics.Path.Direction;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.util.TypedValue;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.TextView;

public class InlineList<T> extends IcsLinearLayout {
	
	private final static int MENU_ITEM_DELETE = Menu.FIRST;

	private final static int BIND_TO_VARIABLE = 1;
	private final static int BIND_TO_SETTING = 2;
	
	OnItemClickListener<T> itemClickListener;
	OnItemCheckStateListener<T> checkStateListener;
	ContentViewControllerBase contentController;
	boolean editable;
	boolean radioBehavior = true;
	boolean pickMode = false;
	List<T> list = new ArrayList<T>();
	HashMap<T,View> viewsByItem = new HashMap<T, View>();
	List<CheckBox> checkList = new ArrayList<CheckBox>();
	View addItem = null;
	
	int bindingType = 0;
	String bindingID = null;
	
	public interface OnItemClickListener<T> {
		public void onItemClick(int i, View v, T item);
	}

	public interface OnItemCheckStateListener<T> {
		public void onCheckStateChanged(int i, View v, T item);
	}

	public interface OnAddListener {
		public void onAdd(View v);
	}

	@SuppressLint("NewApi")
	public InlineList(ContentViewControllerBase _contentController) {
		super(_contentController.getContext(),null);
		contentController = _contentController;
		setBackgroundColor(0);
		setBackgroundDrawable(null);
		setOrientation(VERTICAL);
		setWillNotDraw(false);
		setShowDividers(SHOW_DIVIDER_BEGINNING|SHOW_DIVIDER_MIDDLE|SHOW_DIVIDER_END);
		setDividerDrawable(contentController.getContentResources().getDrawable(contentController.getResourceAttr(android.R.attr.listDivider)));
	}

	public InlineList(ContentViewControllerBase context, List<T> _list) {
		this(context);
		for (T item : _list) {
			addItem(item);
		}
	}

	public InlineList(ContentViewControllerBase context, T singleItem) {
		this(context,Collections.singletonList(singleItem));
	}
	
	public void setPickMode(boolean pickMode) {
		this.pickMode = pickMode;
	}
	
	public void setRadioBehavior(boolean radioBehavior) {
		this.radioBehavior = radioBehavior;
	}
	
	public List<T> getItems() {
		return list;
	}
	
	public void setEditable(boolean editable) {
		this.editable = editable;
	}

	public void bindToVariable(String id, boolean shouldLoad) {
		bindingType = BIND_TO_VARIABLE;
		bindingID = id;
		if (shouldLoad) load();
		else save();
	}

	public T idToItem(String str) {
		return null;
	}

	public String itemToID(T item) {
		return null;
	}

	public Uri imageForItem(T item) {
		return null;
	}

	public Drawable iconForItem(T item) {
		return null;
	}

	public String labelForItem(T item) {
		return item.toString();
	}

	public String sublabelForItem(T item) {
		return null;
	}
	
	public String detailLabelForItem(T item) {
		return null;
	}

	public void bindToSetting(String id, boolean shouldLoad) {
		bindingType = BIND_TO_SETTING;
		bindingID = id;
		if (shouldLoad) load();
		else save();
	}

	public int getItemResource() {
		return R.layout.simple_list_item;
	}
	
	public View setOnAddListener(String text, final OnAddListener listener, ViewExtensions extensions) {
		LayoutInflater li = LayoutInflater.from(getContext());
		View item = li.inflate(R.layout.add_list_item, null);
		item.setBackgroundResource(android.R.drawable.list_selector_background);
		TextView tv = (TextView) item.findViewById(android.R.id.title);
		tv.setTextColor(0xFF000000);
		tv.setText(text);    

		item.setFocusable(true);
		item.setFocusableInTouchMode(false);

        String contentDescription = text.replace("...","") + " button";
        item.setContentDescription(contentDescription);

		addItem = item;
		addView(addItem);
		contentController.registerForContextMenu(addItem);

		item.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				listener.onAdd(v);
			}
		});

		item.setTag(extensions);
		return item;
	}
	
	public void setOnItemClickListener(OnItemClickListener<T> l) {
		itemClickListener = l;
	}

	public void setOnItemCheckStateListener(OnItemCheckStateListener<T> _checkStateListener) {
		checkStateListener = _checkStateListener;
	}
	
	public boolean shouldSaveItem(int index, T item) {
		return pickMode || ((checkList.size() > index) && checkList.get(index).isChecked());
	}

	public String saveState() {
		StringBuilder data = new StringBuilder();
		int i = 0;
		for (T item : list) {
			if (shouldSaveItem(i, item)) {
				String id = itemToID(item);
				if (data.length() > 0) data.append("|");
				data.append(id);
			}
			i++;
		}
		
		return data.toString();
	}
	
	public void loadState(String data) {
		if ((data != null) && !data.equals("")) {
			String[] ids = data.split("\\|");
			for (String id : ids) {
				T item = idToItem(id);
				addItem(item);
			}
		}
	}
	
	public void save() {
		if (bindingType != 0) {
			String data = saveState();
			if (bindingType == BIND_TO_VARIABLE) {
				contentController.getNavigator().setVariable(bindingID, data);
			} else if (bindingType == BIND_TO_SETTING) {
				UserDBHelper.instance(contentController.getContext()).setSetting(bindingID, data);
			}
		}
	}
	
	public void load() {
		if (bindingType != 0) {
			String data = null;
			if (bindingType == BIND_TO_VARIABLE) {
				data = contentController.getNavigator().getVariableAsString(bindingID);
			} else if (bindingType == BIND_TO_SETTING) {
				data = UserDBHelper.instance(contentController.getContext()).getSetting(bindingID);
			}
			
			loadState(data);
		}
	}

	public void clearChecks() {
		for (CheckBox cb : checkList) {
			cb.setChecked(false);
		}
	}

	public void onDuplicateAddAttempted(T item) {
	}

	public void onItemAdded(T item) {
	}

	public void onItemRemoved(T item) {
	}

	public void onCheckStateChanged(T item, CompoundButton checkbox) {
		if (checkStateListener != null) {
			checkStateListener.onCheckStateChanged(list.indexOf(item), checkbox, item);
		}
		save();
	}

	public T getCheckedItem() {
		int index = 0;
		for (CheckBox cb : checkList) {
			if (cb.isChecked()) break;
			index++;
		}
		
		if (index > list.size()-1) return null;
		T item = list.get(index);
		return item;
	}
	
	public boolean getCheckStateForItem(T item) {
		return checkList.get(list.indexOf(item)).isChecked();
	}

	public void setCheckStateForItem(T item, boolean checked) {
		checkList.get(list.indexOf(item)).setChecked(checked);
	}

	public boolean getCheckStateForIndex(int i) {
		return checkList.get(i).isChecked();
	}

	public void setCheckStateForIndex(int i, boolean checked) {
		checkList.get(i).setChecked(checked);
	}
	
	public View createItemView() {
		LayoutInflater li = LayoutInflater.from(getContext());
		final View itemView = li.inflate(getItemResource(), null);
		return itemView;
	}

	public View viewForItem(final T item) {
		final View itemView = createItemView();
		ImageView iv = (ImageView) itemView.findViewById(android.R.id.icon);
		if (iv != null) {
			Drawable icon = iconForItem(item);
			if (icon != null) {
				iv.setImageDrawable(icon);
				iv.setVisibility(View.VISIBLE);
				iv.setScaleType(ScaleType.FIT_CENTER);
			} else {
				Uri imageURI = imageForItem(item);
				if (imageURI != null) {
					try {
						contentController.getContext().getContentResolver().openInputStream(imageURI).close();
						iv.setImageURI(imageURI);
						iv.setVisibility(View.VISIBLE);
					} catch (IOException e) {
						// ignore
					}
				}
			}
		}

		TextView tv = (TextView) itemView.findViewById(android.R.id.title);
		if (tv != null) {
			tv.setText(labelForItem(item));    
		}

		tv = (TextView) itemView.findViewById(android.R.id.text1);
		if (tv != null) {
			String sublabel = sublabelForItem(item);
			if (sublabel != null) {
				tv.setText(sublabel);
				tv.setVisibility(View.VISIBLE);
			}
		}

		tv = (TextView) itemView.findViewById(android.R.id.text2);
		if (tv != null) {
			String sublabel = detailLabelForItem(item);
			if (sublabel != null) {
				tv.setText(sublabel);
				tv.setVisibility(View.VISIBLE);
			}
		}

		final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
		if (cb != null) {
			cb.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
				public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
					if (radioBehavior && isChecked) {
						for (CheckBox otherCB : checkList) {
							if (otherCB != buttonView) {
								if (otherCB.isChecked()) {
									otherCB.setChecked(false);
								}
							}
						}
					}
					onCheckStateChanged(item, buttonView);
				}
			});
		}
		
		itemView.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (itemClickListener != null) {
					itemClickListener.onItemClick(list.indexOf(item), v, item);
				}
				if (cb != null) {
					if (!cb.isFocusable()) {
						if (cb.isChecked()) {
							cb.setChecked(false);
							v.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED);
						} else {
							cb.setChecked(true);
							v.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED);
						}
					}
				}
			}
		});

		itemView.setFocusable(true);
		itemView.setFocusableInTouchMode(false);

		itemView.setTag(new ViewExtensions() {
			public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
				if (!editable) return;
				menu.setHeaderTitle(item.toString());
				MenuItem menuItem = menu.add(0, MENU_ITEM_DELETE, 0, "Remove");
				menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(MenuItem menuItem) {
						removeItem(item);
						return true;
					}
				});
			}
		});
		return itemView;
	}

	public void removeItem(final T item) {
		View itemView = viewForItem(item);
		final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
		if (cb != null) {
			checkList.remove(cb);
		}
		list.remove(item);
		removeView(viewsByItem.remove(item));
		onItemRemoved(item);
		save();
	}
	
	public void addItem(final T item) {
		if (list.contains(item)) {
			onDuplicateAddAttempted(item);
			return;
		}
		
		list.add(item);
		
		View itemView = viewForItem(item);
		viewsByItem.put(item, itemView);
		addView(itemView,list.size()-1);
		final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
		if (cb != null) {
			checkList.add(cb);
		}
		contentController.registerForContextMenu(itemView);
		onItemAdded(item);
		save();
	}
	
	public void setItems(List<T> items) {
		removeAllViews();
		
		HashMap<T,View> newViewsByItem = new HashMap<T, View>();
		
		list.clear();
		list.addAll(items);
		checkList.clear();
		for (T item : list) {
			View itemView = viewsByItem.get(item);
			if (itemView == null) {
				itemView = viewForItem(item);
			}
			newViewsByItem.put(item, itemView);
			addView(itemView);
			contentController.registerForContextMenu(itemView);
			final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
			if (cb != null) {
				checkList.add(cb);
			}
		}
		
		viewsByItem = newViewsByItem;
		if (addItem != null) addView(addItem);
		save();
	}
	
	/*		
	@Override
	public void draw(Canvas canvas) {
		float radius = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 5, getResources().getDisplayMetrics());
		RectF r = new RectF(0.5f,0.5f,getWidth()-0.5f,getHeight()-0.5f);
		Path path = new Path();
		path.addRoundRect(r, radius, radius, Direction.CW);

		Paint p = new Paint();
		p.setStyle(Style.FILL);
		p.setAntiAlias(false);
		p.setColor(0xFFFFFFFF);
		canvas.drawPath(path, p);
		
		canvas.save();
		canvas.clipPath(path);
		super.draw(canvas);
		canvas.restore();
		
		p = new Paint();
		p.setStyle(Style.STROKE);
		p.setAntiAlias(true);
		p.setColor(0xFF404040);
		p.setStrokeWidth(1);
		canvas.drawPath(path, p);
		
		for (int i=0;i<getChildCount()-1;i++) {
			View v = getChildAt(i);
			canvas.drawLine(0.5f, v.getBottom()+0.5f, getWidth()-0.5f, v.getBottom()+0.5f, p);
		}
	}
*/	
}