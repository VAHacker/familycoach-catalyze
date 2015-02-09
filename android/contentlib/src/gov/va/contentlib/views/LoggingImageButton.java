package gov.va.contentlib.views;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ButtonPressedEvent;
import com.openmhealth.ohmage.core.EventLog;

import android.content.Context;
import android.widget.Button;
import android.widget.ImageButton;

public class LoggingImageButton extends ImageButton {
	public LoggingImageButton(Context ctx) {
		super(ctx);
	}
	
	@Override
	public boolean performClick() {
		ButtonPressedEvent e = new ButtonPressedEvent();
		e.buttonPressedButtonId = ""+this.getId();
		CharSequence seq = getContentDescription();
		e.buttonPressedButtonTitle = (seq==null) ? null : ""+seq;
		EventLog.log(e);
		
		return super.performClick();
	}
}
