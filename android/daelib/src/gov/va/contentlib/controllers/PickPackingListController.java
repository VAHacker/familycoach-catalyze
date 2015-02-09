package gov.va.contentlib.controllers;

import gov.va.contentlib.views.PackingList;
import android.content.Context;
import android.widget.LinearLayout;

public class PickPackingListController extends SubsequentExerciseController {

	PackingList packingList;
	
	public PickPackingListController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();

		packingList = new PackingList(this, getContent().getChildren(), getContent().getStringAttribute("storeAs"));
		packingList.setRadioBehavior(false);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(packingList,lp);
	}
}
