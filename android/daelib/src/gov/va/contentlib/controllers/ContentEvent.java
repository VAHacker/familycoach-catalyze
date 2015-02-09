package gov.va.contentlib.controllers;

import android.content.Intent;
import com.actionbarsherlock.view.Menu; 

public class ContentEvent {
	
	static final public ContentEvent BACK_BUTTON_EVENT = new ContentEvent(Type.BACK_BUTTON);
	
	public enum Type {
		BACK_BUTTON,
		GATHER_OPTIONS,
		ACTIVTY_RESULT
	}
	
	public Type eventType;
	public android.view.Menu menu;
	public Menu sherlockMenu;

	public Intent intentData;
	public int requestCode;
	public int resultCode;

	public boolean booleanResult = false;
	
	public ContentEvent(Type eventType) {
		this.eventType = eventType;
	}

	static public ContentEvent createGatherOptionsEvent(Menu menu) {
		ContentEvent evt = new ContentEvent(Type.GATHER_OPTIONS);
		evt.sherlockMenu = menu;
		return evt;
	}

	static public ContentEvent createGatherOptionsEvent(android.view.Menu menu) {
		ContentEvent evt = new ContentEvent(Type.GATHER_OPTIONS);
		evt.menu = menu;
		return evt;
	}
}
