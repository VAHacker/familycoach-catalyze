package gov.va.contentlib.contact;

import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;

public class Contact {
	
	String name;
	String number;
	String lookupID;
	int id;
	Uri photoUri;

	public Contact(Context context, Cursor cursor) {
		super();
		lookupID = cursor.getString(cursor.getColumnIndex(Contacts.LOOKUP_KEY));
		Uri uri = Uri.parse("content://com.android.contacts/contacts/lookup/"+lookupID);
		name = cursor.getString(cursor.getColumnIndex(Contacts.DISPLAY_NAME));
		id = cursor.getInt(cursor.getColumnIndex(Contacts._ID));
		photoUri = Uri.withAppendedPath(uri, Contacts.Photo.CONTENT_DIRECTORY);
	}

	public Contact(Context context, String lookup) {
		super();
		this.lookupID = lookup;
		Uri uri = Uri.parse("content://com.android.contacts/contacts/lookup/"+lookupID);
		Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
	    photoUri = Uri.withAppendedPath(uri, Contacts.Photo.CONTENT_DIRECTORY);
		if (cursor.moveToNext()) {
			name = cursor.getString(cursor.getColumnIndex(Contacts.DISPLAY_NAME));
			id = cursor.getInt(cursor.getColumnIndex(Contacts._ID));
		}
	}

	public String toString() {
		return name;
	}
	
	public String getNumber() {
		return number;
	}

	public void setNumber(String number) {
		this.number = number;
	}

	public void setLookupID(String _lookupID) {
		this.lookupID = _lookupID;
	}
	
	public String getLookupID() {
		return lookupID;
	}
	
	public Uri getUri() {
		return Uri.parse("content://com.android.contacts/contacts/lookup/"+lookupID);
	}
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}

	public Uri getPhotoURI() {
		Uri person = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, id);
		return Uri.withAppendedPath(person, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY);
	}
	
}
