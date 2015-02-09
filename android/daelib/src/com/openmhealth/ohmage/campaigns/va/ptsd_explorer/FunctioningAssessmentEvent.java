
package com.openmhealth.ohmage.campaigns.va.ptsd_explorer;

import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.openmhealth.ohmage.core.EventRecord;

public class FunctioningAssessmentEvent extends EventRecord {
	public int howDifficult;
	
	public FunctioningAssessmentEvent() {
		super(1);
	}
	
	public String ohmageSurveyID() {
	    return "functioningAssessment";
	}

	public void toMap(Map<String,Object> into) {
		into.put("howDifficult",howDifficult);
	}
	
	public void addAttributesToOhmageJSON(JSONArray into) {
		try {
			JSONObject obj = new JSONObject();
			obj.put("prompt_id","howDifficult");
			obj.put("value",howDifficult==-1 ? "NOT_DISPLAYED" : howDifficult);
			into.put(obj);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
}
