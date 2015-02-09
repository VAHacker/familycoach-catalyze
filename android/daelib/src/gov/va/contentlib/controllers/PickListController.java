package gov.va.contentlib.controllers;

import java.util.List;

import android.content.Context;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContentList;
import gov.va.contentlib.views.InlineList;
import gov.va.daelib.R;

public class PickListController extends ContentListViewController {

	List<Content> children;
	
	public PickListController(Context ctx) {
		super(ctx);
	}
	
	public InlineList<Content> createList() {
		children = content.getChildren();
		
		ContentList list = new ContentList(this, children) {
			@Override
			public int getItemResource() {
				return R.layout.check_list_item;
			}
			
			public String saveState() {
				Content checkedItem = getCheckedItem();
				return checkedItem == null ? null : checkedItem.getName();
			}
			
			public void loadState(String data) {
				for (Content c : children) {
					if ((c.getName() != null) && (c.getName().equals(data))) {
						setCheckStateForItem(c, true);
					}
				}
			}

		};
		
		return list;
	}

}
