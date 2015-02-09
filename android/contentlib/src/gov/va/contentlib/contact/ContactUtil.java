package gov.va.contentlib.contact;

import java.util.ArrayList;
import java.util.List;

import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.util.Log;

public class ContactUtil {
	

	public static Contact UriToContact(String uri, Context con) {

		// get the contact id from the Uri  
		String id = uri;
		Cursor phoneCursor = null;  
		String phoneNum = ""; 
		Contact contact = null;
		// query for everything email  
		phoneCursor = con.getContentResolver().query(Phone.CONTENT_URI, null, "lookup=?", new String[] { id }, null);  
		if (phoneCursor.moveToFirst()) {
			contact = new Contact(con, phoneCursor);
		}
		phoneCursor.close();
		return contact;                 
	}

	public static ArrayList<Contact> UriListToContactList(List<String> uris,
			Context con) {
		ArrayList<Contact> contacts = new ArrayList<Contact>();
		for (String each : uris) {
			Contact a = UriToContact(each, con);
			if(a!=null)
				contacts.add(a);
		}
		return contacts;
	}
}
