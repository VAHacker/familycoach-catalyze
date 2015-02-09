
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class ButtonPressedEvent extends EventRecord {
	public String buttonPressedButtonId;
	public String buttonPressedButtonTitle;
	
	public ButtonPressedEvent() {
		super(6);
	}
	
	public String ohmageSurveyID() {
	    return "buttonPressedProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("buttonPressedButtonId",buttonPressedButtonId);
		into.put("buttonPressedButtonTitle",buttonPressedButtonTitle);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","buttonPressedButtonId");
			obj.put("value",(buttonPressedButtonId!=null) ? buttonPressedButtonId : "NONE");
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","buttonPressedButtonTitle");
			obj.put("value",(buttonPressedButtonTitle!=null) ? buttonPressedButtonTitle : "NONE");
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
