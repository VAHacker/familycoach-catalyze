package gov.va.contentlib.activities;

import java.util.List;

import gov.va.contentlib.ContentDBHelper;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.audio.Audio;
import gov.va.contentlib.audio.AudioUtil;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.contact.ContactUtil;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.image.Image;
import gov.va.contentlib.image.ImageUtil;
import gov.va.contentlib.R;
import android.app.ListActivity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Contacts.People;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;

public class SetupActivity2 extends NavigationController {

	ContentDBHelper db;
	UserDBHelper userDb;
	final static int SELECT_PHOTO=10;
	final static int SELECT_AUDIO=11;
	final static int PICK_CONTACT=12;
	final static int SETUP_FINISH=13;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	    db = ContentDBHelper.instance(this);
	    userDb = UserDBHelper.instance(this);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent returnedIntent) { 
	    super.onActivityResult(requestCode, resultCode, returnedIntent); 
	    
	    switch(requestCode) { 
	    case SETUP_FINISH:
	    	return;
	    case SELECT_PHOTO:
	        if(resultCode == RESULT_OK){  
	            Uri selectedImage = returnedIntent.getData();
	            userDb.addImage(selectedImage.toString());
	            Intent intent = new Intent("gov.va.contentlib.activities.ImageEditListActivity");
	            startActivityForResult(intent, SETUP_FINISH);
	        }
	   
	    break;
	    case SELECT_AUDIO:
	    	 if(resultCode == RESULT_OK){  
		            Uri selectedAudio= returnedIntent.getData();
		            Log.e("PTSD",selectedAudio.toString());
		            userDb.addAudio(selectedAudio.toString());
		            Intent intent = new Intent("gov.va.contentlib.activities.AudioEditListActivity");
		            startActivityForResult(intent, SETUP_FINISH);
		            
		            
			 }
	    	  
	    break;
	    case PICK_CONTACT:
	    	 if(resultCode == RESULT_OK){  
		            Uri selectedAudio= returnedIntent.getData();
		            Log.e("PTSD",selectedAudio.toString());
		            userDb.addContact(selectedAudio.toString());
		            Intent intent = new Intent("gov.va.contentlib.activities.ContactsEditListActivity");
		            startActivityForResult(intent, SETUP_FINISH);
			 }
	    }
	}
	
	@Override
	public void contentSelected(Content c) {
		if (c.getName().equals("pictures")) {
			List<Image> images=ImageUtil.UriListToImageList(userDb.getAllImages(),this);

            Intent intent = new Intent("gov.va.contentlib.activities.ImageEditListActivity");
            startActivityForResult(intent, SETUP_FINISH);
		} else if (c.getName().equals("audio")) {
			List<Audio> audios=AudioUtil.UriListToAudioList(userDb.getAllAudio(),this);

			Intent intent = new Intent("gov.va.contentlib.activities.AudioEditListActivity");
			startActivityForResult(intent, SETUP_FINISH);
/*
		} else if (position == 2) {
			userDb.getAllContacts();
			List<Contact> contacts=ContactUtil.UriListToContactList(userDb.getAllContacts(),this);
			
			Intent intent = new Intent("gov.va.contentlib.activities.ContactsEditListActivity");
			startActivityForResult(intent, SETUP_FINISH);
*/			
		}
//		super.onListItemClick(l, v, position, id);
	}
/*	
	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		if (position == 0) {
			List<Image> images=ImageUtil.UriListToImageList(userDb.getAllImages(),this);

            Intent intent = new Intent("gov.va.contentlib.activities.ImageEditListActivity");
            startActivityForResult(intent, SETUP_FINISH);
		} else if (position == 1) {
			List<Audio> audios=AudioUtil.UriListToAudioList(userDb.getAllAudio(),this);

			Intent intent = new Intent("gov.va.contentlib.activities.AudioEditListActivity");
			startActivityForResult(intent, SETUP_FINISH);
		} else if (position == 2) {
			userDb.getAllContacts();
			List<Contact> contacts=ContactUtil.UriListToContactList(userDb.getAllContacts(),this);
			
			Intent intent = new Intent("gov.va.contentlib.activities.ContactsEditListActivity");
			startActivityForResult(intent, SETUP_FINISH);
		}
		super.onListItemClick(l, v, position, id);
	}
*/	
}
