
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class TimeElapsedBetweenPCLAssessmentsEvent extends EventRecord {
	public long timeElapsedBetweenPCLAssessments;
	
	public TimeElapsedBetweenPCLAssessmentsEvent() {
		super(19);
	}
	
	public String ohmageSurveyID() {
	    return "timeElapsedBetweenPCLAssessmentsProbe";
	}

	public void toMap(Map<String,Object> into) {
		into.put("timeElapsedBetweenPCLAssessments",timeElapsedBetweenPCLAssessments);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","timeElapsedBetweenPCLAssessments");
			obj.put("value",timeElapsedBetweenPCLAssessments==-1 ? "NOT_DISPLAYED" : timeElapsedBetweenPCLAssessments);
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
