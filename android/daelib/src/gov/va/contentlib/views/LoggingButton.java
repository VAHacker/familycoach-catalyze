package gov.va.contentlib.views;

import gov.va.contentlib.controllers.ContentViewController;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import android.R;
import android.content.Context;
import android.widget.Button;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ButtonPressedEvent;
import com.openmhealth.ohmage.core.EventLog;

public class LoggingButton extends Button {
	OnClickListener listener = null;
	String enablement = null;
	
	public LoggingButton(Context ctx) {
		super(ctx/*,null,ContentViewControllerBase.getResourceAttr(ctx, R.attr.buttonStyleSmall)*/);
	}
	
	@Override
	public boolean performClick() {
		ButtonPressedEvent e = new ButtonPressedEvent();
		e.buttonPressedButtonId = ""+this.getId();
		CharSequence seq = getText();
		if (seq == null) seq = getContentDescription();
		e.buttonPressedButtonTitle = (seq==null) ? null : ""+seq;
		EventLog.log(e);
		
		return super.performClick();
	}
	
	public void setEnablement(String enablement, ContentViewControllerBase cvc) {
		this.enablement = enablement;
		updateEnablement(cvc);
	}
	
	@Override
	public void setOnClickListener(OnClickListener l) {
		listener = l;
		super.setOnClickListener(l);
	}
	
	public void fakeClick() {
		if (listener != null) {
			listener.onClick(this);
		}
	}
	
	public void updateEnablement(ContentViewControllerBase cvc) {
		if (enablement != null) {
			String s = enablement.substring(3);
			setEnabled(cvc.evalJavascriptPredicate(s));
		}
	}
}
