package gov.va.contentlib.views;

import gov.va.contentlib.R;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.activities.NavigationController;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.controllers.ContentViewControllerBase;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Path;
import android.graphics.Path.Direction;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.Rect;
import android.graphics.RectF;
import android.net.Uri;
import android.provider.ContactsContract.Contacts;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.accessibility.AccessibilityEvent;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class InlineList<T> extends LinearLayout {
	
	private final static int MENU_ITEM_DELETE = Menu.FIRST;

	private final static int BIND_TO_VARIABLE = 1;
	private final static int BIND_TO_SETTING = 2;
	
	OnItemClickListener<T> itemClickListener;
	OnItemCheckStateListener<T> checkStateListener;
	ContentViewControllerBase contentController;
	boolean editable;
	List<T> list = new ArrayList<T>();
	List<CheckBox> checkList = new ArrayList<CheckBox>();
	
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

	public InlineList(ContentViewControllerBase _contentController) {
		super(_contentController.getNavigator());
		contentController = _contentController;
		setOrientation(VERTICAL);
		setWillNotDraw(false);
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

	public void bindToSetting(String id, boolean shouldLoad) {
		bindingType = BIND_TO_SETTING;
		bindingID = id;
		if (shouldLoad) load();
	}

	public int getItemResource() {
		return R.layout.simple_list_item;
	}
	
	public View setOnAddListener(String text, final OnAddListener listener, ViewExtensions extensions) {
		LayoutInflater li = LayoutInflater.from(getContext());
		View item = li.inflate(R.layout.add_list_item, null);
		item.setBackgroundResource(android.R.drawable.list_selector_background);
		TextView tv = (TextView) item.findViewById(android.R.id.text1);
		tv.setTextColor(0xFF000000);
		tv.setText(text);    

		item.setFocusable(true);
		item.setFocusableInTouchMode(false);

		addView(item);

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
		return true;
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
				contentController.getNavigator().setVariable(bindingID, data.toString());
			} else if (bindingType == BIND_TO_SETTING) {
				UserDBHelper.instance(contentController.getNavigator()).setSetting(bindingID, data.toString());
			}
		}
	}
	
	public void load() {
		if (bindingType != 0) {
			String data = null;
			if (bindingType == BIND_TO_VARIABLE) {
				data = contentController.getNavigator().getVariable(bindingID);
			} else if (bindingType == BIND_TO_SETTING) {
				data = UserDBHelper.instance(contentController.getNavigator()).getSetting(bindingID);
			}
			
			loadState(data);
		}
	}

	public void clearChecks() {
		for (CheckBox cb : checkList) {
			cb.setChecked(false);
		}
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

	public void addItem(final T item) {
		LayoutInflater li = LayoutInflater.from(getContext());
		final View itemView = li.inflate(getItemResource(), null);
		itemView.setBackgroundResource(android.R.drawable.list_selector_background);
		ImageView iv = (ImageView) itemView.findViewById(android.R.id.icon);
		if (iv != null) {
			Uri imageURI = imageForItem(item);
			if (imageURI != null) {
				try {
					contentController.getNavigator().getContentResolver().openInputStream(imageURI).close();
					iv.setImageURI(imageURI);
				} catch (IOException e) {
					// ignore
				}
			}
		}

		TextView tv = (TextView) itemView.findViewById(android.R.id.text1);
		if (tv != null) {
			tv.setTextColor(0xFF000000);
			tv.setText(item.toString());    
			list.add(item);
		}

		final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
		checkList.add(cb);
		itemView.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				if (itemClickListener != null) {
					itemClickListener.onItemClick(list.indexOf(item), v, item);
				}
				if (cb != null) {
					if (cb.isChecked()) {
						cb.setChecked(false);
						v.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED);
					} else {
						cb.setChecked(true);
						v.sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_FOCUSED);
					}
					if (checkStateListener != null) {
						checkStateListener.onCheckStateChanged(list.indexOf(item), v, item);
					}
				}
			}
		});

		itemView.setFocusable(true);
		itemView.setFocusableInTouchMode(false);
		
		addView(itemView,list.size()-1);
	
		itemView.setTag(new ViewExtensions() {
			public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
				if (!editable) return;
				menu.setHeaderTitle(item.toString());
				MenuItem menuItem = menu.add(0, MENU_ITEM_DELETE, 0, "Remove");
				menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(MenuItem menuItem) {
						list.remove(item);
						InlineList.this.removeView(itemView);
						return true;
					}
				});
			}
		});
		contentController.getNavigator().registerForContextMenu(itemView);
		save();
	}
	
	@Override
	public void draw(Canvas canvas) {
		RectF r = new RectF(0.5f,0.5f,getWidth()-0.5f,getHeight()-0.5f);
		Path path = new Path();
		path.addRoundRect(r, 5, 5, Direction.CW);

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
		p.setColor(0xFF000000);
		p.setStrokeWidth(1);
		canvas.drawPath(path, p);
		
		for (int i=0;i<getChildCount()-1;i++) {
			View v = getChildAt(i);
			canvas.drawLine(0.5f, v.getBottom()+0.5f, getWidth()-0.5f, v.getBottom()+0.5f, p);
		}
	}
}
