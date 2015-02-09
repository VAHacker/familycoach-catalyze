
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class TotalTimeOnAppEvent extends EventRecord {
	public long totalTimeOnApp;
	
	public TotalTimeOnAppEvent() {
		super(16);
	}
	
	public String ohmageSurveyID() {
	    return "totalTimeOnAppProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("totalTimeOnApp",totalTimeOnApp);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","totalTimeOnApp");
			obj.put("value",totalTimeOnApp==-1 ? "NOT_DISPLAYED" : totalTimeOnApp);
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
