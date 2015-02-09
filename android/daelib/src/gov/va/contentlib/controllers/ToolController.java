package gov.va.contentlib.controllers;

import java.util.List;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ToolAbortedEvent;
import com.openmhealth.ohmage.core.EventLog;

import gov.va.contentlib.content.Content;
import android.app.AlertDialog;
import android.content.Context;
import android.database.Cursor;
import android.view.View;

public class ToolController extends NavController {
	
	Long lastCategoryIntro = null;
	Long lastRandomExercise = null;
	Long lastRandomExerciseCategory = null;
	
	boolean firstTime = false;
	boolean goingAway = false;
	static final private int MAX_TRIES = 10;

	public ToolController(Context ctx) {
		super(ctx);
	}
	
	public ContentViewControllerBase selectExerciseController() {
		Content symptom = (Content)getVariable("symptom");
		Content preselectedExercise = (Content)getVariable("preselectedExercise");

		if ((symptom == null) && (preselectedExercise == null)) {
			return null;
		}
		
		Content exercise = null;
		ContentViewControllerBase cv = null;

		while (true) {
			int randPos = -1;
			exercise = null;
			Cursor c = null;
			
			if (preselectedExercise != null) {
				if (preselectedExercise.getType().equals("ExerciseCategory")) {
					Object userData = preselectedExercise.getUserData("scoreSign");
					if (userData != null) {
						Integer sign = (Integer)userData;
						int signValue = sign.intValue();
						c = userDb.sql().rawQuery("select exerciseref.refID, exerciseref.weight, exerciseref.parentRefID from exerciseref where exerciseref.parentRefID=? AND exerciseref.score=?", new String[] {""+preselectedExercise.getID(),""+signValue});
					} else {
						c = userDb.sql().rawQuery("select exerciseref.refID, exerciseref.weight, exerciseref.parentRefID from exerciseref where exerciseref.parentRefID=? AND exerciseref.score>=0", new String[] {""+preselectedExercise.getID()});
					}
					//c = db.sql().rawQuery("select content._id,content.weight,content.parent from content where content.parent=?", new String[] {""+preselectedExercise.getID()});
				} else {
					exercise = preselectedExercise;
				}
			} else {
				c = userDb.sql().rawQuery("select exerciseref.refID, exerciseref.weight, exerciseref.parentRefID from exerciseref left join exercisesymptom on exerciseref.refID=exercisesymptom.exerciseID where exercisesymptom.symptomID=? AND exerciseref.score>=0", new String[] {""+symptom.getID()});
				//c = db.sql().rawQuery("select content._id,content.weight,content.parent from content left join content_link on content._id=content_link.referrer where content_link.field='helpsWithSymptoms' and content_link.referree=?", new String[] {""+symptom.getID()});
			}
			
			if (c != null) {
				if (c.moveToFirst()) {
					boolean otherCategoryAvailable = false;
					float totalWeight = 0;

					while (true) {
						totalWeight += c.getFloat(1);
						if ((lastRandomExerciseCategory != null) && (c.getLong(2) != lastRandomExerciseCategory)) {
							otherCategoryAvailable = true;
						}
						if (!c.moveToNext()) break;
					}

					int tryCount = 0;
					do {
						do {
							float chosen = (float)(totalWeight * Math.random());

							float iterWeight = 0;
							c.moveToFirst();
							while (true) {
								float thisWeight = c.getFloat(1);
								if (iterWeight+thisWeight >= chosen) break;
								iterWeight += thisWeight;
								if (!c.moveToNext()) break;
							}

							randPos = c.getPosition();
							tryCount++;
						} while ((lastRandomExercise != null) && (randPos == lastRandomExercise) && (tryCount < MAX_TRIES));

						exercise = db.getContentForID(c.getLong(0));
					} while ((lastRandomExerciseCategory != null) && (exercise.getParentID() == lastRandomExerciseCategory) && otherCategoryAvailable && (tryCount < MAX_TRIES));

					c.close();
				}
			}

			if (exercise == null) break;
			
			cv = exercise.createContentView(this,getContext());
			cv.setSelectedContent(exercise);

			String prereq = cv.checkPrerequisites();
			if (prereq != null) {
				if (preselectedExercise != null) {
					AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
					builder.setTitle("Can't use this tool");
					builder.setMessage(prereq);
					builder.setPositiveButton("Ok", null);
					builder.show();
					goingAway = true;
					getHandler().post(new Runnable() {
						public void run() {
							goBack();
						}
					});
					return null;
				}
				
				continue;
			}
			
			lastRandomExercise = (long)randPos;
			lastRandomExerciseCategory = exercise.getParentID();
			break;
		}
	
		if (exercise == null) {
			AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
			builder.setTitle("Problem finding exercise");
			builder.setMessage("Sorry, I couldn't find an exercise right now.");
			builder.setPositiveButton("Ok", null);
			builder.show();
			goingAway = true;
			getHandler().post(new Runnable() {
				public void run() {
					goBack();
				}
			});
			return null;
		}

		Content parent = exercise.getParent();
		if (parent != null) {
			String parentUI = parent.getUIDescriptor();
			if (parentUI != null) {
				if ((lastCategoryIntro == null) || (lastCategoryIntro.longValue() != exercise.getParentID())) {
					cv = parent.createContentView(this,getContext());
					cv.setSelectedContent(exercise);
					lastCategoryIntro = exercise.getParentID();
				} else {
					lastCategoryIntro = null;
				}
			} else {
				lastCategoryIntro = null;
			}
		} else {
			lastCategoryIntro = null;
		}
		
		setVariable("selectedExercise", exercise);
		return cv;
	}

	public void augmentExercise(final ContentViewControllerBase cv) {
		Content preselectedExercise = (Content)getVariable("preselectedExercise");
		if ((preselectedExercise == null) || (preselectedExercise.getType().equals("ExerciseCategory"))) {
			cv.addButton(0,"New Tool",-1).setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					ToolAbortedEvent e = new ToolAbortedEvent();
					e.toolId = cv.getContent().getUniqueID();
					e.toolName = cv.getContent().getName();
					EventLog.log(e);

					ContentViewControllerBase newTool = selectExerciseController();
					augmentExercise(newTool);
					flipReplaceView(newTool);
				}
			});
		}
	}
	
	@Override
	public void pushView(ContentViewControllerBase cv, int toRemain, boolean animated, Runnable onCompletion) {
		augmentExercise(cv);
		super.pushView(cv, toRemain, animated, onCompletion);
	}
	
	@Override
	public boolean navigateToContentAtPathWithData(List<Content> path, int startingAt, Object data) {
		Content next = path.get(path.size()-1);
		setVariable("preselectedExercise", next);
		refreshContent();
		return true;
	}
	
	@Override
	public void refreshContent() {
		super.refreshContent();
		if (!goingAway) {
			Content selectedExercise = (Content)getVariable("selectedExercise");
			if (selectedExercise != null) return;
			ContentViewControllerBase cv = selectExerciseController();
			if (cv != null) {
				pushView(cv, 1, false, null);
			}
		}
	}
	
	public boolean shouldUseFirstChildAsRoot() {
		return false;
	}

	@Override
	public void build() {
		super.build();
		
		ContentViewControllerBase cv = selectExerciseController();
		if (cv != null) {
			pushView(cv, 1, false, null);
		}
	}

}
