package gov.va.contentlib.views;

import java.util.List;

import android.graphics.drawable.Drawable;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.controllers.ContentViewControllerBase;

public class ContentList extends InlineList<Content> {

	public ContentList(ContentViewControllerBase cv, List<Content> list) {
		super(cv,list);
	}
	
	@Override
	public String labelForItem(Content item) {
		return item.getDisplayName();
	}
	
	@Override
	public Drawable iconForItem(Content item) {
		return item.getIcon();
	}
	
}
