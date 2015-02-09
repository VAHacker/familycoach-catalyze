package gov.va.contentlib.controllers;

import java.util.List;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Reminder;
import gov.va.contentlib.views.ContentList;
import gov.va.contentlib.views.InlineList;
import android.content.Context;
import android.view.View;

public class ScheduleToolController extends ToolListController {

	public ScheduleToolController(Context ctx) {
		super(ctx);
	}

	@Override
	public void contentSelected(Content c) {
		ScheduleToolController2 stc = new ScheduleToolController2(getContext());
		stc.eventName = "Use "+c.getDisplayName()+" tool";
		stc.reference = c.getUniqueID();
		stc.createEvent = false;
		
		Content content = new Content();
		content.setTitle("Schedule Tool");
		content.setMainText("Choose a time to be reminded to use this tool.");
		stc.setContent(content);
		
		navigateToNext(stc,true);
	}
}
