package gov.va.contentlib;

import gov.va.contentlib.content.Audio;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Goal;
import gov.va.contentlib.content.Image;
import gov.va.contentlib.content.PCLScore;
import gov.va.contentlib.content.Reminder;

import java.io.File;
import java.io.IOException;
import java.io.OptionalDataException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.net.Uri;
import android.text.format.DateFormat;

public class UserDBHelper extends SQLiteOpenHelper {

	Context context;
	HashMap<String, String> settings = null;
	
	static final String NO_VALUE = "NO_VALUE";
	
	private static final int DATABASE_VERSION = 1;
	private static String DB_NAME = "user.db";

    private static String DROP_TIMESERIES_TABLE = "drop table if exists timeseries;";
    private static String TIMESERIES_TABLE_CREATE = "create table timeseries (_id INTEGER PRIMARY KEY ASC, series TEXT, score INT, time INT);";

    private static String SETTING_TABLE_CREATE = "create table settings (_id INTEGER PRIMARY KEY ASC, name TEXT, value TEXT);";
    private static String REMINDER_TABLE_CREATE = "create table reminder (_id INTEGER PRIMARY KEY ASC, time INT, type TEXT, reference TEXT, displayName TEXT );";
    private static String IMAGE_TABLE_CREATE = "create table image (_id INTEGER PRIMARY KEY ASC, uri TEXT );";
    private static String AUDIO_TABLE_CREATE = "create table audio (_id INTEGER PRIMARY KEY ASC, uri TEXT);";
    private static String CONTACTS_TABLE_CREATE = "create table contact (_id INTEGER PRIMARY KEY ASC, uri TEXT, preferred INT );";
    
    private static String DROP_EXERCISE_SCORE_TABLE = "drop table if exists exerciseref;";
    private static String EXERCISE_SCORE_TABLE_CREATE = "create table exerciseref (_id INTEGER PRIMARY KEY ASC, name TEXT, score INT, positiveScore INT, negativeScore INT, childCount INT, weight REAL, addressable INT, refID INT, parentRefID INT, isCategory INT, exerciseUniqueID TEXT, categoryID INT);";
    private static String EXERCISE_SCORE_INDEX1_CREATE = "create index exerciseref_score_idx on exerciseref (score);";
    private static String EXERCISE_SCORE_INDEX2_CREATE = "create index exerciseref_addressable_idx on exerciseref (addressable);";
    private static String EXERCISE_SCORE_INDEX3_CREATE = "create index exerciseref_uniqueID_idx on exerciseref (exerciseUniqueID);";

    private static String DROP_EXERCISE_SYMPTOMS_TABLE = "drop table if exists exercisesymptom;";
    private static String EXERCISE_SYMPTOMS_TABLE_CREATE = "create table exercisesymptom (_id INTEGER PRIMARY KEY ASC, exerciseID INT, symptomID INT);";
    private static String EXERCISE_SYMPTOMS_INDEX1_CREATE = "create index exercisesymptom_exerciseid_idx on exercisesymptom (exerciseID);";
    private static String EXERCISE_SYMPTOMS_INDEX2_CREATE = "create index exercisesymptom_symptomid_idx on exercisesymptom (symptomID);";

    private static String DROP_JOURNALENTRY_TABLE = "drop table if exists journalentry;";
    private static String JOURNALENTRY_TABLE_CREATE = "create table journalentry (_id INTEGER PRIMARY KEY ASC, displayName TEXT, experience TEXT, consequences TEXT, notes TEXT, symptom INT, occurred INT, severity INT, duration INT, sleepDuration INT, bedDuration INT, triggers TEXT, copingTechniques TEXT);";
    private static String JOURNALENTRY_INDEX1_CREATE = "create index journalentry_symptom_idx on journalentry (symptom);";

    private static String DROP_SYMPTOMTRIGGERLINK_TABLE = "drop table if exists symptomtriggerlink;";
    private static String SYMPTOMTRIGGERLINK_TABLE_CREATE = "create table symptomtriggerlink (_id INTEGER PRIMARY KEY ASC, symptomID INT, triggerID INT);";
    private static String SYMPTOMTRIGGERLINK_INDEX1_CREATE = "create index symptomtriggerlink_symptomid_idx on symptomtriggerlink (symptomID);";

    private static String DROP_SYMPTOMTRIGGER_TABLE = "drop table if exists symptomtrigger;";
    private static String SYMPTOMTRIGGER_TABLE_CREATE = "create table symptomtrigger (_id INTEGER PRIMARY KEY ASC, displayName TEXT, userAdded INT);";

    private static String DROP_COPINGTECHNIQUELINK_TABLE = "drop table if exists copingtechniquelink;";
    private static String COPINGTECHNIQUELINK_TABLE_CREATE = "create table copingtechniquelink (_id INTEGER PRIMARY KEY ASC, symptomID INT, techniqueID INT);";
    private static String COPINGTECHNIQUELINK_INDEX1_CREATE = "create index copingtechniquelink_techniqueid_idx on copingtechniquelink (techniqueID);";

    private static String DROP_COPINGTECHNIQUE_TABLE = "drop table if exists copingtechnique;";
    private static String COPINGTECHNIQUE_TABLE_CREATE = "create table copingtechnique (_id INTEGER PRIMARY KEY ASC, displayName TEXT, userAdded INT);";

    private static String DROP_SYMPTOMREF_TABLE = "drop table if exists symptomref;";
    private static String SYMPTOMREF_TABLE_CREATE = "create table symptomref (_id INTEGER PRIMARY KEY ASC, displayName TEXT, uniqueID TEXT);";
    private static String SYMPTOMREF_INDEX1_CREATE = "create index symptomref_uniqueid_idx on symptomref (uniqueID);";

    private static String DROP_GOAL_TABLE = "drop table if exists goal;";
    private static String GOAL_TABLE_CREATE = "create table goal (_id INTEGER PRIMARY KEY ASC, parentID INT, displayName TEXT, doneState INT, treeLevel INT, dueDate INT, ordering REAL, isExpanded INT, notes TEXT, alarmID TEXT);";
    private static String GOAL_INDEX1_CREATE = "create index goal_parent_idx on goal (parentID);";

    private ContentDBHelper contentDB;
    private static UserDBHelper instance;
    
    public static UserDBHelper instance(Context ctx) {
    	if (instance == null) {
    		instance = new UserDBHelper(ctx);
    	}
    	
    	return instance;
    }
    
    public Context getContext() {
		return context;
	}

	public UserDBHelper(Context ctx) {
		super(ctx, DB_NAME, null, DATABASE_VERSION);
		context = ctx;
		contentDB = ContentDBHelper.instance(ctx);
//		createDemoData(getWritableDatabase());
	}
	
	public long getModTime() {
		File f = new File(context.getApplicationInfo().dataDir + "/databases/"+DB_NAME);
		long lastMod = f.lastModified();
		return lastMod;
	}
	
	@Override
	public void onOpen(SQLiteDatabase db) {
		super.onOpen(db);
    	if (getModTime() < contentDB.getModTime()) {
    		createRefs(db,true);
    	}
	}
	
	private String[] demoFavorites = {
		"progressiveRelaxation",	
		"deepBreathing",
		"soothWithMyPictures",
		"soothWithMyAudio",
		"takeWalk",
		"rid",
		"positiveImagery1"
	};
	
	public void createDemoData(SQLiteDatabase db) {
		db.execSQL(DROP_TIMESERIES_TABLE);
		db.execSQL(TIMESERIES_TABLE_CREATE);

		int i;
		float fy = (float)38.0f;
		long startingTime = -120L * 24*60*60*1000;
		Date now = new Date();
		for ( i = 0; i < 15; i++ ) {
			long fx = i*8;
			int score = (int)(fy + (8 * Math.random() - 4));
			if (score < 0) score = 0;
			if (score > 40) score = 40;

			long ts = (long)(now.getTime() + startingTime+(fx*24*60*60*1000));
			long delta = (long)(now.getTime() - ts);
			long deltaDays = delta / (24*60*60*1000);

			Calendar cal = Calendar.getInstance();
			cal.setTimeInMillis(ts);
			DateFormat df = new DateFormat();
			CharSequence s = df.format("MMMM dd, yyyy h:mmaa",cal);
			
	    	ContentValues values = new ContentValues(2);
	    	values.put("series", "pssTotal");
	    	values.put("score", score);
	    	values.put("time", ts);
	    	db.insert("timeseries", null, values);
			
			fy = (float)(fy * 0.9);
		}
		
		db.execSQL(DROP_EXERCISE_SCORE_TABLE);
		db.execSQL(EXERCISE_SCORE_TABLE_CREATE);
		db.execSQL(EXERCISE_SCORE_INDEX1_CREATE);
		db.execSQL(EXERCISE_SCORE_INDEX2_CREATE);
		db.execSQL(EXERCISE_SCORE_INDEX3_CREATE);
		for (String fave : demoFavorites) {
			Content c = contentDB.getContentForName(fave);
			if (c != null) {
				ContentValues values = new ContentValues(2);
				values.put("score", 1);
				values.put("name", c.getDisplayName());
				values.put("exerciseUniqueID", c.getUniqueID());
				db.insert("exerciseref", null, values);
			}
		}
	}

	public void resetAppData() {
		File f = new File(context.getApplicationInfo().dataDir + "/databases/"+DB_NAME);
		f.delete();
		System.exit(0);
	}

	public void resetTools() {
		createRefs(sql(), false);
	}

	public void createRefs(SQLiteDatabase db, boolean moveFromOld) {
		db.beginTransaction();
		
		db.execSQL(DROP_EXERCISE_SYMPTOMS_TABLE);
		db.execSQL(EXERCISE_SYMPTOMS_TABLE_CREATE);
		
		if (moveFromOld) {
			try {
				db.execSQL("drop table if exists exerciseref_old;");
				db.execSQL("ALTER TABLE exerciseref RENAME TO exerciseref_old");
			} catch (SQLException e) {
				db.execSQL("drop table if exists exerciseref_old;");
				moveFromOld = false;
			}
		}
		
		db.execSQL(DROP_EXERCISE_SCORE_TABLE);
		db.execSQL(EXERCISE_SCORE_TABLE_CREATE);
		
		ContentValues values = new ContentValues(3);
		List<Content> categories = contentDB.getContentByType("ExerciseCategory");
		for (Content cat : categories) {
			Cursor c = contentDB.sql().query("content", new String[] {"_id","weight","displayName","uniqueID"}, "parent=?", new String[] {""+cat.getID()}, null, null, null);
			int childCount = c.getCount();
			
			boolean addressableAtCategoryLevel = "yes".equalsIgnoreCase(cat.getStringAttribute("categoryLevelFavorite"));
			values.clear();
			values.put("name", cat.getDisplayName());
			values.put("refID", cat.getID());
			values.put("parentRefID", -1);
			values.put("isCategory", 1);
			values.put("childCount", childCount);
			values.put("exerciseUniqueID", cat.getUniqueID());
			values.put("addressable", addressableAtCategoryLevel);
			values.put("weight", 0f);
			values.putNull("categoryID");
			values.put("score", 0);
			values.put("positiveScore", 0);
			values.put("negativeScore", 0);
			long rowID = db.insert("exerciseref", null, values);
			
			int catScore=0, catPositiveScore=0, catNegativeScore=0;
			while (c.moveToNext()) {
				values.clear();
				values.put("name", c.getString(2));
				values.put("refID", c.getInt(0));
				values.put("parentRefID", cat.getID());
				values.put("isCategory", 0);
				values.put("weight", c.getFloat(1));
				values.put("exerciseUniqueID", c.getString(3));
				values.put("addressable", !addressableAtCategoryLevel);
				values.put("categoryID", rowID);
				values.put("childCount", 1);
				int score=0, positiveScore=0, negativeScore=0;
				if (moveFromOld) {
					try {
						Cursor oldc = db.query("exerciseref_old", new String[] {"_id","exerciseUniqueID","score","positiveScore","negativeScore"}, "exerciseUniqueID=?", new String[] {c.getString(3)}, null, null, null);
						if (oldc.moveToFirst()) {
							score = oldc.getInt(2);
							positiveScore = oldc.getInt(3);
							negativeScore = oldc.getInt(4);
						}
						oldc.close();
					} catch (SQLException e) {
					}
					catScore += score;
					catPositiveScore += positiveScore;
					catNegativeScore += negativeScore;
				}
				values.put("score", score);
				values.put("positiveScore", positiveScore);
				values.put("negativeScore", negativeScore);
				db.insert("exerciseref", null, values);
			}

			if ((catScore != 0) || (catPositiveScore != 0) || (catNegativeScore != 0)) {
				values.clear();
				values.put("score", catScore);
				values.put("positiveScore", catPositiveScore);
				values.put("negativeScore", catNegativeScore);
				db.update("exerciseref", values, "_id=?", new String[]{""+rowID});
			}

			c.close();
		}
		db.execSQL("drop table if exists exerciseref_old;");

		db.execSQL(EXERCISE_SCORE_INDEX1_CREATE);
		db.execSQL(EXERCISE_SCORE_INDEX2_CREATE);
		db.execSQL(EXERCISE_SCORE_INDEX3_CREATE);

        TreeMap<Long,String[]> symptomsByID = new TreeMap<Long, String[]>();

//		left join content_link on content._id=content_link.referree where content_link.referrer=? and content_link.field=?
		Cursor c = contentDB.sql().rawQuery("select referrer, referree from content_link where field='helpsWithSymptoms'", null);
		while (c.moveToNext()) {
			values.clear();
			values.put("exerciseID", c.getLong(0));
            long symptomID = c.getLong(1);
			values.put("symptomID", symptomID);
			db.insert("exercisesymptom", null, values);
            if (!symptomsByID.containsKey(symptomID)) {
                Cursor subc = contentDB.sql().query("content", new String[] {"name","displayName","uniqueID"}, "_id=?", new String[] {""+symptomID}, null, null, null);
                if (subc.moveToFirst()) {
                    String name = subc.getString(subc.getColumnIndex("name"));
                    String displayName = subc.getString(subc.getColumnIndex("displayName"));
                    String uniqueID = subc.getString(subc.getColumnIndex("uniqueID"));
                    symptomsByID.put(symptomID,new String[] {name,displayName,uniqueID});
                }
                subc.close();
            }
		}
		db.execSQL(EXERCISE_SYMPTOMS_INDEX1_CREATE);
		db.execSQL(EXERCISE_SYMPTOMS_INDEX2_CREATE);

        db.execSQL(DROP_SYMPTOMREF_TABLE);
        db.execSQL(SYMPTOMREF_TABLE_CREATE);
        db.execSQL(SYMPTOMREF_INDEX1_CREATE);

        db.execSQL(DROP_JOURNALENTRY_TABLE);
        db.execSQL(JOURNALENTRY_TABLE_CREATE);
        db.execSQL(JOURNALENTRY_INDEX1_CREATE);

        db.execSQL(DROP_SYMPTOMTRIGGERLINK_TABLE);
        db.execSQL(SYMPTOMTRIGGERLINK_TABLE_CREATE);
        db.execSQL(SYMPTOMTRIGGERLINK_INDEX1_CREATE);

        db.execSQL(DROP_SYMPTOMTRIGGER_TABLE);
        db.execSQL(SYMPTOMTRIGGER_TABLE_CREATE);

        db.execSQL(DROP_COPINGTECHNIQUELINK_TABLE);
        db.execSQL(COPINGTECHNIQUELINK_TABLE_CREATE);
        db.execSQL(COPINGTECHNIQUELINK_INDEX1_CREATE);

        db.execSQL(DROP_COPINGTECHNIQUE_TABLE);
        db.execSQL(COPINGTECHNIQUE_TABLE_CREATE);

        TreeMap<String,Long> symptomsByName = new TreeMap<String, Long>();
        for (Map.Entry<Long,String[]> e : symptomsByID.entrySet()) {
            String[] v = e.getValue();
            symptomsByName.put(v[0], e.getKey());
            values.clear();
            values.put("_id", e.getKey());
            values.put("displayName", v[1]);
            values.put("uniqueID", v[2]); // XXX
            db.insert("symptomref", null, values);
        }

        Content defaultSymptomTriggers = contentDB.getContentForName("defaultSymptomTriggers");
        if (defaultSymptomTriggers != null) {
            for (Content s : defaultSymptomTriggers.getChildren()) {
                values.clear();
                values.put("displayName", s.getDisplayName());
                long id = db.insert("symptomtrigger", null, values);
                String appliesTo = s.getStringAttribute("appliesTo");
                String[] appliesToList = appliesTo.split(" ");
                for (String name :appliesToList) {
                    Long symptomID = symptomsByName.get(name);
                    if (symptomID != null) {
                        values.clear();
                        values.put("triggerID", id);
                        values.put("symptomID", symptomID);
                        db.insert("symptomtriggerlink", null, values);
                    }
                }
            }
        }

        Content defaultCopingTechniques = contentDB.getContentForName("defaultCopingTechniques");
        if (defaultCopingTechniques != null) {
            for (Content t : defaultCopingTechniques.getChildren()) {
                values.clear();
                values.put("displayName", t.getDisplayName());
                long id = db.insert("copingtechnique", null, values);
                String appliesTo = t.getStringAttribute("appliesTo");
                String[] appliesToList = appliesTo.split(" ");
                for (String name :appliesToList) {
                    Long symptomID = symptomsByName.get(name);
                    if (symptomID != null) {
                        values.clear();
                        values.put("techniqueID", id);
                        values.put("symptomID", symptomID);
                        db.insert("copingtechniquelink", null, values);
                    }
                }
            }
        }

        db.setTransactionSuccessful();
        db.endTransaction();
    }

	@Override
	public void onCreate(SQLiteDatabase db) {
		db.execSQL(SETTING_TABLE_CREATE);
		db.execSQL(REMINDER_TABLE_CREATE);
		db.execSQL(AUDIO_TABLE_CREATE);
		db.execSQL(IMAGE_TABLE_CREATE);
		db.execSQL(CONTACTS_TABLE_CREATE);
		db.execSQL(TIMESERIES_TABLE_CREATE);

        db.execSQL(DROP_GOAL_TABLE);
        db.execSQL(GOAL_TABLE_CREATE);
        db.execSQL(GOAL_INDEX1_CREATE);

        createRefs(db,false);
//		createDemoData(db);
	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		//createRefs(db,true);
	}

    public SQLiteDatabase sql() {
    	return getWritableDatabase();
    }

    public void addReminder(Reminder reminder){
    	ContentValues values = new ContentValues(4);
    	values.put("time", reminder.time);
    	values.put("type", reminder.type);
    	values.put("displayName", reminder.displayName);
    	values.put("reference", reminder.reference);
    	reminder.id = sql().insert("reminder", null, values);
    }

    public void deleteReminder(Reminder reminder){
    	sql().delete("reminder", "_id=?", new String[] {""+reminder.id});
    }
    
    public void addImage(Image image){
    	ContentValues values = new ContentValues(1);
    	values.put("uri", image.getimageUril().toString());
    	sql().insert("image", null, values);
    }

    public void addAudio(Audio audio){
    	ContentValues values = new ContentValues(1);
    	values.put("uri", audio.getAudioUri().toString());
    	sql().insert("audio", null, values);
    }
    
    public void deleteAudio(Audio audio){
    	String uriToDelete[]=new String[] {audio.getAudioUri().toString()};
    	sql().delete("audio", "uri=?", uriToDelete);
    }
    
    public void deleteContact(Contact contact){
    	String uriToDelete[]=new String[] {contact.getLookupID()};
    	sql().delete("contact", "uri=?", uriToDelete);
    }
    
    public void deleteImage(Image image){
    	String uriToDelete[]=new String[] {image.getimageUril().toString()};
    	sql().delete("image", "uri=?", uriToDelete);
    }

    public int countRefs(String type) {
		ArrayList<Image> faves = new ArrayList<Image>();
		Cursor c = sql().query(type, null, null, null, null, null, null);
		int count = c.getCount();
		c.close();
		return count;
	}

    public List<Image> getAllImages() {
        ArrayList<Image> faves = new ArrayList<Image>();
        Cursor c = sql().query("image", null, null, null, null, null, null);
        int index = c.getColumnIndex("uri");
        if (c.moveToFirst()) {
            while (true) {
                String uri_string = c.getString(index);
                Uri uri=Uri.parse(uri_string);
                faves.add(new Image(this,uri));
                if (!c.moveToNext()) break;
            }
        }
        c.close();
        return faves;
    }


    public List<Contact> getAllContacts() {
    	return getAllContacts(null);
    }

    public List<Contact> getAllContacts(String selection) {
		ArrayList<Contact> faves = new ArrayList<Contact>();
		Cursor c = sql().query("contact", null, selection, null, null, null, null);
		int index = c.getColumnIndex("uri");
		int preferredIndex = c.getColumnIndex("preferred");
		if (c.moveToFirst()) {
			while (true) {
				String lookupKey = c.getString(index);
				Integer preferred = c.getInt(preferredIndex);
				faves.add(new Contact(this,lookupKey,Integer.valueOf(1).equals(preferred)));
				if (!c.moveToNext()) break;
			}
		}
		c.close();
		return faves;
	}

    public List<Reminder> getDueReminders() {
    	return getReminders("time<?", new String[] { ""+ (System.currentTimeMillis() + 30*60*1000) });
    }

    public List<Reminder> getAllReminders() {
    	return getReminders(null,null);
    }

    public List<Reminder> getReminders(String selection, String[] selectionArgs) {
		ArrayList<Reminder> faves = new ArrayList<Reminder>();
		Cursor c = sql().query("reminder", null, selection, selectionArgs, null, null, "time ASC");
		while (c.moveToNext()) {
			faves.add(new Reminder(c));
		}
		c.close();
		return faves;
	}

    public List<Audio> getAllAudio() {
		ArrayList<Audio> faves = new ArrayList<Audio>();
		Cursor c = sql().query("audio", null, null, null, null, null, null);
		int index = c.getColumnIndex("uri");
		if (c.moveToFirst()) {
			while (true) {
				String uri_string = c.getString(index);
				Uri uri=Uri.parse(uri_string);
				faves.add(new Audio(this,uri));
				if (!c.moveToNext()) break;
			}
		}
		c.close();
		return faves;
	}
    
    public void addContact(Contact contact){
    	ContentValues values = new ContentValues(2);
    	values.put("uri", contact.getLookupID());
    	values.put("preferred", contact.isPreferred() ? 1 : 0);
    	sql().insert("contact", null, values);
    }

    public void updateContact(Contact contact) {
    	ContentValues values = new ContentValues(2);
    	values.put("preferred", contact.isPreferred() ? 1 : 0);
    	sql().update("contact", values, "uri=?", new String[]{contact.getLookupID()});
    }

    public void addTimeseriesScore(String series, long timestamp, int score) {
    	ContentValues values = new ContentValues(2);
    	values.put("series", series);
    	values.put("score", score);
    	values.put("time", timestamp);
    	sql().insert("timeseries", null, values);
		setSetting("pclHistoryExists", "true");
    }
    
	public PCLScore getLastTimeseriesScore(String series) {
		PCLScore score = null;
		Cursor c = sql().query("timeseries", null, "series=?", new String[] {series}, null, null, "time DESC");
		if (c.moveToFirst()) {
			score = new PCLScore(c);
		}
		c.close();
		return score;
	}

	public void clearTimeseriesScores(String series) {
		sql().delete("timeseries", "series=?", new String[] {series});
		setSetting("pclHistoryExists", null);
	}
	
	public List<PCLScore> getTimeseriesScores(String series) {
		ArrayList<PCLScore> scores = new ArrayList<PCLScore>();
		Cursor c = sql().query("timeseries", null, "series=?", new String[] {series}, null, null, "time ASC");
		if (c.moveToFirst()) {
			while (true) {
				PCLScore score = new PCLScore(c);
				scores.add(score);
				if (!c.moveToNext()) break;
			}
		}
		c.close();
		return scores;
	}

	public int getTimeseriesCount(String series) {
		ArrayList<PCLScore> scores = new ArrayList<PCLScore>();
		Cursor c = sql().query("timeseries", null, "series=?", new String[] {series}, null, null, "time ASC");
		int count = c.getCount();
		c.close();
		return count;
	}
	
	public void setExerciseScore(Content exercise, boolean delta, int value) {
		Cursor c = sql().query("exerciseref", null, "exerciseUniqueID=?", new String[]{""+exercise.getUniqueID()}, null, null, null);
		int score = 0;
		if (c.moveToFirst()) {
			int index = c.getColumnIndex("score");
			if (c.isNull(index)) {
				score = 0;
			} else {
				score = c.getInt(index);
			}
		}

		int catIDIdx = c.getColumnIndex("categoryID");
		Integer rowID = c.isNull(catIDIdx) ? null : c.getInt(catIDIdx);
		
		c.close();
		
		int oldScore = score;
		if (delta) {
			score += value;
		} else {
			score = value;
		}

		ContentValues values = new ContentValues(3);
    	values.put("score", score);
    	values.put("positiveScore", score > 0 ? score : 0);
    	values.put("negativeScore", score < 0 ? score : 0);
    	sql().update("exerciseref", values, "exerciseUniqueID=?", new String[]{""+exercise.getUniqueID()});
    	
    	if (rowID != null) {
    		c = sql().query("exerciseref", null, "_id=?", new String[]{""+rowID}, null, null, null);
    		int catScore = 0;
    		int catPositiveScore = 0;
    		int catNegativeScore = 0;
    		if (c.moveToFirst()) {
    			int index = c.getColumnIndex("score");
    			catScore = c.isNull(index) ? 0 : c.getInt(index);
    			index = c.getColumnIndex("positiveScore");
    			catPositiveScore = c.isNull(index) ? 0 : c.getInt(index);
    			index = c.getColumnIndex("negativeScore");
    			catNegativeScore = c.isNull(index) ? 0 : c.getInt(index);
    		}
    		
    		c.close();
    		
    		catScore -= oldScore;
    		if (oldScore > 0) {
    			catPositiveScore -= oldScore;
    		} else if (oldScore < 0) {
    			catNegativeScore -= oldScore;
    		}
    		
    		catScore += score;
    		if (score > 0) {
    			catPositiveScore += score;
    		} else if (score < 0) {
    			catNegativeScore += score;
    		}
    		
    		values = new ContentValues(3);
        	values.put("score", catScore);
        	values.put("positiveScore", catPositiveScore);
        	values.put("negativeScore", catNegativeScore);
        	sql().update("exerciseref", values, "_id=?", new String[]{""+rowID});
    	}
	}

	private void addExercises(List<Content> exercises, Cursor c, TreeMap<String,Object> userData) {
		while (c.moveToNext()) {
			try {
				Content content = new Content(contentDB,c.getLong(c.getColumnIndex("refID")),c.getString(c.getColumnIndex("name")));
				if (userData != null) content.setUserData(userData);
				exercises.add(content);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	public List<Content> getAddressableExercises() {
		ArrayList<Content> exercises = new ArrayList<Content>();
		Cursor c = sql().query("exerciseref", null, "addressable = 1", null, null, null, "score DESC, name ASC");
		addExercises(exercises, c, null);
		c.close();
		return exercises;
	}

	public List<Content> getAddressableExercisesInSections() {
		try {
			ArrayList<Content> exercises = new ArrayList<Content>();
			Cursor c = sql().query("exerciseref", null, "addressable = 1 AND positiveScore > 0", null, null, null, "positiveScore DESC, name ASC");
			TreeMap<String, Object> userData;
			if (c.getCount() > 0) {
				exercises.add(new Content(contentDB,-1,"Favorite Tools"));
				userData = new TreeMap<String, Object>();
				userData.put("scoreSign", 1);
				addExercises(exercises, c, userData);
			}
			c.close();
			c = sql().query("exerciseref", null, "addressable = 1 AND (childCount - positiveScore + negativeScore) > 0", null, null, null, "name ASC");
			if (c.getCount() > 0) {
				exercises.add(new Content(contentDB,-1,"Available Tools"));
				userData = new TreeMap<String, Object>();
				userData.put("scoreSign", 0);
				addExercises(exercises, c, userData);
			}
			c.close();
			c = sql().query("exerciseref", null, "addressable = 1 AND negativeScore < 0", null, null, null, "negativeScore DESC, name ASC");
			if (c.getCount() > 0) {
				exercises.add(new Content(contentDB,-1,"Rejected Tools"));
				userData = new TreeMap<String, Object>();
				userData.put("scoreSign", -1);
				addExercises(exercises, c, userData);
			}
			c.close();
			return exercises;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	public Cursor getFavorites() {
		return sql().query("exerciseref", null, "score > 0", null, null, null, null);
	}

	public List<String> getFavoriteIDs() {
		ArrayList<String> faves = new ArrayList<String>();
		Cursor c = getFavorites();
		int index = c.getColumnIndex("exerciseUniqueID");
		if (c.moveToFirst()) {
			while (true) {
				String id = c.getString(index);
				faves.add(id);
				if (!c.moveToNext()) break;
			}
		}
		c.close();
		return faves;
	}

	private synchronized Map<String,String> fetchSettings() {
		if (settings == null) {
			settings = new HashMap<String, String>();
    		Cursor c = sql().query("settings", null, null, null, null, null, null);
    		if (c.moveToFirst()) {
    			while (true) {
    				String name = c.getString(c.getColumnIndex("name"));
    				String value = c.getString(c.getColumnIndex("value"));
    				if (value != null) settings.put(name, value);
    				if (!c.moveToNext()) break;
    			}
    		}
    		c.close();
		}
		
		return settings;
	}
	
    public void setSetting(String name, String value) {
    	if (value == null) {
    		fetchSettings().remove(name);
    	} else {
    		fetchSettings().put(name, value);
    	}
    	
    	ContentValues values = new ContentValues(2);
    	values.put("value", value);
    	if (sql().update("settings", values, "name=?", new String[] {name}) == 0) {
        	values.put("name", name);
        	sql().insert("settings", null, values);
    	}
    }
    
    public String getSetting(String name) {
    	String value = fetchSettings().get(name);
		return value;
    }

    public void getSettings(Map<String,Object> map) {
    	map.putAll(fetchSettings());
    }

}
