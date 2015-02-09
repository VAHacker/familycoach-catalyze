package gov.va.contentlib.activities;



import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.R;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;


public class EULA extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
//		requestWindowFeature(Window.FEATURE_NO_TITLE);
//		getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
		Content c = ContentDBHelper.instance(this).getContentForName("EULA");
		setContentView(c.createContentView(this));
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		finish();
	}	
	
}
	
	
