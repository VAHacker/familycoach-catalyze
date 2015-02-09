package gov.va.contentlib.controllers;

import java.util.List;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContentList;
import gov.va.contentlib.views.InlineList;
import gov.va.daelib.R;
import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.view.LayoutInflater;
import android.view.View;
import android.webkit.WebView;
import android.widget.TextView;

public class ToolListController extends ContentListViewController {

	public ToolListController(Context ctx) {
		super(ctx);
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		forceSoftwareLayer(null);
	}
	
	public InlineList createList() {
		ContentList list = new ContentList(this, getContentList()) {
			@Override
			public View viewForItem(Content item) {
				if (item.getID() == -1) {
					LayoutInflater inflater = LayoutInflater.from(getContext());
					TextView titleView = (TextView)inflater.inflate(gov.va.daelib.R.layout.list_header_view, clientView, false);
					titleView.setText(item.getDisplayName());
					return titleView;
				}
				return super.viewForItem(item);
			}
		};
		list.setOnItemClickListener(new InlineList.OnItemClickListener() {
			public void onItemClick(int i, View v, Object item) {
				contentSelected((Content)item);
			}
		});

		return list;
	}
	
	@Override
	public void contentSelected(Content c) {
		if (getBooleanAttr(R.attr.contentToolUseScoringEnabled)) {
			userDb.setExerciseScore(c,true,1);
			list.setItems(userDb.getAddressableExercisesInSections());
		}
		super.contentSelected(c);
	}
	
	@Override
	public void onContentBecameVisible() {
		super.onContentBecameVisible();
		list.setItems(userDb.getAddressableExercisesInSections());
	}
	
	public List<Content> getContentList() {
		return userDb.getAddressableExercisesInSections();
	}

}
