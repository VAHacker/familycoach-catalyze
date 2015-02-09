
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class PclAssessmentStartedEvent extends EventRecord {
	public long pclAssessmentStarted;
	
	public PclAssessmentStartedEvent() {
		super(4);
	}
	
	public String ohmageSurveyID() {
	    return "pclAssessmentStartedProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("pclAssessmentStarted",pclAssessmentStarted);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","pclAssessmentStarted");
			cal.setTimeInMillis(pclAssessmentStarted);
			obj.put("value", timestampFormat.format(cal.getTime()));
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
