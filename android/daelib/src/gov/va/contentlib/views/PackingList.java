package gov.va.contentlib.views;

import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.daelib.R;

import java.util.List;

import android.net.Uri;
import android.view.View;

public class PackingList extends InlineList<String> {

	public PackingList(ContentViewControllerBase context, List<Content> items, String bindingID) {
		super(context);
		
		setOnItemCheckStateListener(new OnItemCheckStateListener<String>() {
			@Override
			public void onCheckStateChanged(int i, View v, String item) {
				save();
			}
		});
		
		for (Content item : items) {
			addItem(item.getDisplayName());
		}
		
		bindToSetting(bindingID, true);
	}

	public PackingList(ContentViewControllerBase context, List<String> items) {
		super(context);
		
		for (String item : items) {
			addItem(item);
		}
	}

	public int getItemResource() {
		return R.layout.check_list_item;
	}

	public void loadState(String data) {
		if ((data != null) && !data.equals("")) {
			String[] ids = data.split("\\|");
			for (String id : ids) {
				String item = idToItem(id);
				setCheckStateForItem(item, true);
			}
		}
	}

	@Override
	public boolean shouldSaveItem(int index, String item) {
		return getCheckStateForIndex(index);
	}
	
	@Override
	public String idToItem(String id) {
		return id;
	}
	
	@Override
	public String itemToID(String item) {
		return item;
	}
	
	public Uri imageForItem(Contact item) {
		return null;
	}
	
}
