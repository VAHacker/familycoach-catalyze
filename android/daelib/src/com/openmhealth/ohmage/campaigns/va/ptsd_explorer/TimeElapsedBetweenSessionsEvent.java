
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class TimeElapsedBetweenSessionsEvent extends EventRecord {
	public long timeElapsedBetweenSessions;
	
	public TimeElapsedBetweenSessionsEvent() {
		super(18);
	}
	
	public String ohmageSurveyID() {
	    return "timeElapsedBetweenSessionsProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("timeElapsedBetweenSessions",timeElapsedBetweenSessions);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","timeElapsedBetweenSessions");
			obj.put("value",timeElapsedBetweenSessions==-1 ? "NOT_DISPLAYED" : timeElapsedBetweenSessions);
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
