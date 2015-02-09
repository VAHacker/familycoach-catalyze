
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class ToolAbortedEvent extends EventRecord {
	public String toolId;
	public String toolName;
	
	public ToolAbortedEvent() {
		super(20);
	}
	
	public String ohmageSurveyID() {
	    return "toolAbortedProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("toolId",toolId);
		into.put("toolName",toolName);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","toolId");
			obj.put("value",(toolId!=null) ? toolId : "NONE");
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","toolName");
			obj.put("value",(toolName!=null) ? toolName : "NONE");
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
