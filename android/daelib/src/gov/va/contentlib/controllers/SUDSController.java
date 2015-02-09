package gov.va.contentlib.controllers;

import java.util.TreeMap;

import com.flurry.android.FlurryAgent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PostExerciseSudsEvent;
import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.PreExerciseSudsEvent;
import com.openmhealth.ohmage.core.EventLog;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.SUDSMeter;
import android.app.AlertDialog;
import android.content.Context;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebView;
import android.widget.LinearLayout;

public class SUDSController extends ContentViewController {

	SUDSMeter meter;
	
	public SUDSController(Context ctx) {
		super(ctx);
	}
	
	public void addText(String text) {
		View tv = makeTextView(text);
		meter = new SUDSMeter(getContext());
		meter.setId(100);

		LinearLayout.LayoutParams layout = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT,LayoutParams.WRAP_CONTENT);
		layout.leftMargin = 20;
		
		LinearLayout leftRightClientView = new LinearLayout(getContext());
		leftRightClientView.setOrientation(LinearLayout.HORIZONTAL);
		leftRightClientView.setBackgroundColor(0);
		leftRightClientView.addView(meter,layout);
		leftRightClientView.addView(tv);
		
		clientView.addView(leftRightClientView);
		tv.setNextFocusLeftId(meter.getId());
	}

    public void journalIt(Content c) {
        Long when = System.currentTimeMillis();
        Integer sudsScore = (Integer)getVariable("suds");
        Content symptom = (Content)getVariable("symptom");

        TreeMap<String,Object> map = new TreeMap<String, Object>();
        if (when != null) map.put("when",when);
        if (sudsScore != null) map.put("severity",sudsScore);
        if (symptom != null) map.put("symptom",symptom.getID());
        navigateToContentNameWithData("journal",map);
    }
	
	public void recordSUDS() {
		Integer sudsScore = getScore();

		TreeMap<String,String> map = new TreeMap<String, String>();
		map.put("suds",""+sudsScore);
		FlurryAgent.logEvent("SUDS_READING",map);
		
		PreExerciseSudsEvent e = new PreExerciseSudsEvent();
		e.preExerciseSudsScore = sudsScore == null ? -1 : sudsScore;
		EventLog.log(e);
		
		setVariable("suds", sudsScore);
	}

	public void recordReSUDS() {
		Integer sudsScore = (Integer)getVariable("suds");
		Integer resudsScore = getScore();

		TreeMap<String,String> map = new TreeMap<String, String>();
		map.put("suds",""+sudsScore);
		map.put("resuds",""+resudsScore);
		FlurryAgent.logEvent("RESUDS_READING",map);

		PostExerciseSudsEvent e = new PostExerciseSudsEvent();
		e.initialSudsScore = sudsScore == null ? -1 : sudsScore;
		e.postExerciseSudsScore = resudsScore == null ? -1 : resudsScore;
		EventLog.log(e);

		setVariable("resuds", resudsScore);
	}

	public boolean shouldUseScroller() {
		return false;
	}

	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();

        registerAction("journalIt");

		if ("true".equals(content.getStringAttribute("resuds"))) {
			Integer sudsScore = (Integer)getVariable("suds");
			if (sudsScore == null) {
				String label = "Try Another Tool";
				Content preselectedExercise = (Content)getVariable("preselectedExercise");
				if (preselectedExercise != null) {
					if (!preselectedExercise.getType().equals("ExerciseCategory")) {
						label = "Try This Tool Again";
					}
				}

				addButton(label).setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						clearVariable("resuds");
						clearVariable("selectedExercise");
						navigateToContentName("exercise");
					}
				});
				addButton("Done").setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						clearVariable("resuds");
						navigateToContentName("manage");
					}
				});
			} else {
				meter.setScore(sudsScore);
				addButton("Next").setOnClickListener(new OnClickListener() {
					public void onClick(View v) {
						recordReSUDS();
						navigateToNext();
					}
				});
			}
		} else {
			addButton("Skip").setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					clearVariable("suds");
					navigateToNext();
				}
			});
			addButton("Next").setOnClickListener(new OnClickListener() {
				public void onClick(View v) {
					Integer distress = meter.getScore();
					if (distress == null) {
						AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
						builder.setTitle("Rate Your Distress");
						builder.setMessage("Please either rate your distress using the meter or tap 'Skip'.");
						builder.setPositiveButton("Ok", null);
						builder.show();
						return;
					}
					recordSUDS();
					Integer sudsScore = meter.getScore();
					if ((sudsScore != null) && (sudsScore.intValue() >= 9)) {
						navigateToNextContent(db.getContentForName("crisis"));
						return;
					}
					navigateToNext();
				}
			});
		}
	}

	public Integer getScore() {
		return meter.getScore();
	}
	
}
