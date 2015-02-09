package gov.va.contentlib.controllers;

import java.util.ArrayList;

import gov.va.contentlib.views.PackingList;
import android.content.Context;
import android.widget.LinearLayout;

public class ViewPackingListController extends SubsequentExerciseController {

	PackingList packingList;
	
	public ViewPackingListController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		String storeAs = getContent().getStringAttribute("storeAs");
		String data = getUserDB().getSetting(storeAs);
		ArrayList<String> items = new ArrayList<String>();
		if ((data != null) && !data.equals("")) {
			String[] ids = data.split("\\|");
			for (String id : ids) {
				items.add(id);
			}
		}

		packingList = new PackingList(this, items);
		packingList.setRadioBehavior(false);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		//lp.setMargins(10, 0, 10, 0);
		clientView.addView(packingList,lp);
	}
}
