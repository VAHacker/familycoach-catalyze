
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class AppLaunchedEvent extends EventRecord {
	public int accessibilityFeaturesActiveOnLaunch;
	
	public AppLaunchedEvent() {
		super(11);
	}
	
	public String ohmageSurveyID() {
	    return "appLaunchedProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("accessibilityFeaturesActiveOnLaunch",accessibilityFeaturesActiveOnLaunch);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","accessibilityFeaturesActiveOnLaunch");
			obj.put("value",accessibilityFeaturesActiveOnLaunch==-1 ? "NOT_DISPLAYED" : accessibilityFeaturesActiveOnLaunch);
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
