package gov.va.contentlib.controllers;

import gov.va.contentlib.views.LoggingButton;
import android.content.Context;
import android.os.Debug;
import android.view.View;
import android.widget.LinearLayout;

public class CrisisIntroController extends ContentViewController {

	static final int ACCEPT_EULA = 1001;
	static final int REJECT_EULA = 1002;
	
	public CrisisIntroController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void build() {
		super.build();
		
		LinearLayout.LayoutParams params;

		params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT);
		params.setMargins(20, 20, 20, 20);
		LoggingButton gimmeTool = new LoggingButton(getContext());
		gimmeTool.setText("No, give me a tool");
		gimmeTool.setLayoutParams(params);
		gimmeTool.setTextSize(18);
		gimmeTool.setPadding(20, 30, 20, 30);
		gimmeTool.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				navigateToContentName("exercise");
			}
		});
		clientView.addView(gimmeTool);

		params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT,LinearLayout.LayoutParams.WRAP_CONTENT);
		params.setMargins(20, 20, 20, 20);
		LoggingButton yesTalk = new LoggingButton(getContext());
		yesTalk.setText("Yes, talk to someone now");
		yesTalk.setLayoutParams(params);
		yesTalk.setTextSize(18);
		yesTalk.setPadding(20, 30, 20, 30);
		yesTalk.setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View v) {
				navigateToNext();
			}
		});

		clientView.addView(yesTalk);
	}
	
}
