package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.questionnaire.Choice;
import android.content.Context;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.LinearLayout.LayoutParams;

public class RadioController extends ContentViewController {

	String selectionVariable;
	
	public RadioController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		selectionVariable = content.getStringAttribute("selectionVariable");
		
		final RadioGroup choicesView = new RadioGroup(getContext());
		choicesView.setOrientation(LinearLayout.VERTICAL);

		boolean first = true;
		for (Content c : content.getChildren()) {
			RadioButton radio = new RadioButton(getContext());
			radio.setText(c.getDisplayName());
			radio.setTag(c.getStringAttribute("value"));
			RadioGroup.LayoutParams layout = new RadioGroup.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
			layout.setMargins(0, first ? 0 : 10, 0, 10);
			first = false;
			choicesView.addView(radio,layout);
		}

		choicesView.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
			@Override
			public void onCheckedChanged(RadioGroup group, int checkedId) {
				RadioButton radio = (RadioButton)group.findViewById(checkedId);
				String value = (String)radio.getTag();
				setVariable(selectionVariable, value);
				updateEnablements();
			}
		});
		
		clientView.addView(choicesView);
	}
}
