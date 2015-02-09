package gov.va.contentlib;

import gov.va.contentlib.content.Content;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.database.sqlite.SQLiteOpenHelper;
import android.net.Uri;

public class ContentDBHelper extends SQLiteOpenHelper {
	 
    //The Android's default system path of your application database.
    private static String DB_NAME = "content.db";
 
    private SQLiteDatabase myDataBase; 
 
    private final Context myContext;
 
    private static ContentDBHelper instance;
    
    public static ContentDBHelper instance(Context ctx) {
    	if (instance == null) {
    		instance = new ContentDBHelper(ctx);
    		
    		try {
    			instance.createDataBase();
    		} catch (IOException ioe) {
    			throw new Error("Unable to create database");
    		}

    		try {
    			instance.openDataBase();
    		} catch(SQLException sqle){
    			throw sqle;
    		}
    	}
    	
    	return instance;
    }
    
    public Context getContext() {
		return myContext;
	}

    public Activity getMainActivity() {
		return (Activity)myContext;
	}
    
    
    
    /**
     * Constructor
     * Takes and keeps a reference of the passed context in order to access to the application assets and resources.
     * @param context
     */
    public ContentDBHelper(Context context) {
 
    	super(context, DB_NAME, null, 1);
        this.myContext = context;
    }	
 
    public long getModTime() {
    	PackageManager pm = getContext().getPackageManager();
    	ApplicationInfo appInfo;
		try {
			appInfo = pm.getApplicationInfo(getContext().getApplicationContext().getPackageName(), 0);
	    	String appFile = appInfo.sourceDir;
	    	long installed = new File(appFile).lastModified();
	    	return installed;
		} catch (NameNotFoundException e) {}
		return -1;
    }
    
    public SQLiteDatabase sql() {
    	return myDataBase;
    }

    public Content getContentForName(String name) {
    	Content content = null;
    	Cursor c = sql().query("content", null, "name=?", new String[] {name}, null, null, null);
    	if (c.moveToFirst()) {
    		try {
    			content = new Content(this,c.getLong(0),c);
    		} catch (Exception e) {
    			e.printStackTrace();
    		}
    	}
    	
    	c.close();
    	return content;
    }

    public List<Content> getContentByType(String type) {
    	ArrayList<Content> contents = new ArrayList<Content>();
    	Cursor c = sql().query("content", null, "type=?", new String[] {type}, null, null, null);
    	while (c.moveToNext()) {
    		try {
    			contents.add(new Content(this,c.getLong(0),c));
    		} catch (Exception e) {
    			e.printStackTrace();
    		}
    	}
    	
    	c.close();
    	return contents;
    }

    public Content getContentForID(long id) {
    	Content content = null;
    	Cursor c = sql().query("content", null, "_id=?", new String[] {""+id}, null, null, null);
    	if (c.moveToFirst()) {
    		try {
    			content = new Content(this,c.getLong(0),c);
    		} catch (Exception e) {
    			e.printStackTrace();
    		}
    	}
    	
    	c.close();
    	return content;
    }

    public Content getContentForUniqueID(String uniqueID) {
    	Content content = null;
    	Cursor c = sql().query("content", null, "uniqueID=?", new String[] {uniqueID}, null, null, null);
    	if (c.moveToFirst()) {
    		try {
    			content = new Content(this,c.getLong(0),c);
    		} catch (Exception e) {
    			e.printStackTrace();
    		}
    	}
    	
    	c.close();
    	return content;
    }

	public Content getContentForUri(Uri data) {
		String scheme = data.getScheme();
		if (scheme.equals("contentUniqueID")) {
			return getContentForUniqueID(data.getSchemeSpecificPart());
		} else if (scheme.equals("contentName:")) {
			return getContentForName(data.getSchemeSpecificPart());
		} else if (scheme.equals("contentID:")) {
			return getContentForID(Long.parseLong(data.getSchemeSpecificPart()));
		}
		return null;
	}
    
    public void createDataBase() throws IOException {
    	copyDataBase();
    	/*
    	boolean dbExist = checkDataBase();
 
    	if (dbExist){
			copyDataBase();
    	} else{
        	this.getReadableDatabase();
 
        	try {
 
    			copyDataBase();
 
    		} catch (IOException e) {
 
        		throw new Error("Error copying database");
 
        	}
    	}
 */
    }
 
    /**
     * Check if the database already exist to avoid re-copying the file each time you open the application.
     * @return true if it exists, false if it doesn't
     */
    private boolean checkDataBase(){
 
    	SQLiteDatabase checkDB = null;
 
    	try{
        	String dataDir = myContext.getApplicationContext().getApplicationInfo().dataDir;
        	String myPath = dataDir + "/databases/" + DB_NAME;
    		checkDB = SQLiteDatabase.openDatabase(myPath, null, SQLiteDatabase.OPEN_READONLY);
    	}catch(SQLiteException e){
    	}
 
    	if(checkDB != null){
    		checkDB.close();
    	}
 
    	return checkDB != null ? true : false;
    }
 
    /**
     * Copies your database from your local assets-folder to the just created empty database in the
     * system folder, from where it can be accessed and handled.
     * This is done by transfering bytestream.
     * */
    private void copyDataBase() throws IOException{
    	String dataDir = myContext.getApplicationContext().getApplicationInfo().dataDir;
    	String outFileName = dataDir + "/databases/" + DB_NAME;
    	File dbcopy = new File(outFileName);

    	if (!dbcopy.exists() || (getModTime() > dbcopy.lastModified())) {
    		//Open your local db as the input stream
    		InputStream myInput = myContext.getAssets().open(DB_NAME);

    		//Open the empty db as the output stream
    		dbcopy.getParentFile().mkdirs();
    		OutputStream myOutput = new FileOutputStream(outFileName);

    		//transfer bytes from the inputfile to the outputfile
    		byte[] buffer = new byte[1024];
    		int length;
    		while ((length = myInput.read(buffer))>0){
    			myOutput.write(buffer, 0, length);
    		}

    		//Close the streams
    		myOutput.flush();
    		myOutput.close();
    		myInput.close();
    	}
    }
 
    public void openDataBase() throws SQLException {
 
    	//Open the database
    	String dataDir = myContext.getApplicationContext().getApplicationInfo().dataDir;
    	String myPath = dataDir + "/databases/" + DB_NAME;
    	myDataBase = SQLiteDatabase.openDatabase(myPath, null, SQLiteDatabase.OPEN_READONLY);
    }
 
    @Override
	public synchronized void close() {
 
    	    if(myDataBase != null)
    		    myDataBase.close();
 
    	    super.close();
 
	}
 
	@Override
	public void onCreate(SQLiteDatabase db) {
 
	}
 
	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
 
	}

}
