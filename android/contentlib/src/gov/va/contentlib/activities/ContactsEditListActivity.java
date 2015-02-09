package gov.va.contentlib.activities;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.contact.ContactUtil;
import gov.va.contentlib.R;


import java.util.ArrayList;
import java.util.List;




import android.app.Dialog;
import android.app.ListActivity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
//import android.provider.Contacts.People;
import android.provider.ContactsContract.Contacts;  
import android.util.Log;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;



public class ContactsEditListActivity extends ListActivity {

	UserDBHelper userDb ;
	ContactUriAdapter adapter;
	private final int MENU_ITEM_DELETE= Menu.FIRST;
	Button add,delete;
	final static int PICK_CONTACT=12;
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		//requestWindowFeature(Window.FEATURE_NO_TITLE);
		setTitle("Support Contacts");

		//R.layout.
		setContentView(R.layout.contactsedit_list);
		

		userDb = UserDBHelper.instance(this);
		// Inform the list that we provide context menus for items
		getListView().setOnCreateContextMenuListener(this);
		
		
		// Add click listener to Header's Add button
		findViewById(R.id.add_btn).setOnClickListener(clickHandler);

		
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
				LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		lp.gravity = Gravity.AXIS_SPECIFIED;

		fillData();
		

	}
	
	@Override
	public void onCreateContextMenu(ContextMenu menu, View view,
			ContextMenuInfo menuInfo) {

		menu.add(0, MENU_ITEM_DELETE, 0, R.string.menu_delete);
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent contactReturnedIntent) { 
	    super.onActivityResult(requestCode, resultCode, contactReturnedIntent); 
	    
	   
	    switch(requestCode) { 
	  
	    case PICK_CONTACT:
	    	 if(resultCode == RESULT_OK){  
		            Uri selectedcontact= contactReturnedIntent.getData();
		            String toStore = selectedcontact.toString();

		            Cursor info = getContentResolver().query(selectedcontact, null, null, null, null);

		    		while(info.moveToNext()) {
		    			int nameFieldColumnIndex = info.getColumnIndex(Contacts.LOOKUP_KEY);
		    			toStore = info.getString(nameFieldColumnIndex);
		    			Log.e("PTSD","--NAME-"+selectedcontact);
		    			userDb.addContact(toStore);
		    			break;
		    		}
		            
		            Log.e("PTSD",toStore);
		            fillData();
		            
			 }
	    	  
	    }
	  
	    
	}
	

	@Override
	public void onResume() {
		super.onResume();
		
		fillData();
	}

	@Override
	public void onPause() {
		super.onPause();
	}

	@Override
	public void onDestroy() {
		super.onDestroy();
	}

	private void fillData() {
		
		userDb.getAllContacts();
		List<Contact> contacts=ContactUtil.UriListToContactList(userDb.getAllContacts(),this);
		adapter = new ContactUriAdapter(this, android.R.layout.simple_list_item_1,contacts);

		setListAdapter(adapter);
		adapter.notifyDataSetChanged();
	}

	

	

	private final Runnable listUpdater = new Runnable() {
		public void run() {
			fillData();

		}
	};
	
	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		
		List<Contact> contacts=ContactUtil.UriListToContactList(userDb.getAllContacts(),this);

		final Contact contact = contacts.get(position);
		String contactUri= contact.getLookupID();
		
		Intent intent = new Intent();
/*		
		 if (Build.DEVICE.equals("GT-I9000") || Build.DEVICE.equals("crespo4g")) {
			 intent = new Intent();
			 intent.setAction(Intent.ACTION_MAIN);
			 intent.addCategory(Intent.CATEGORY_LAUNCHER);
			 ComponentName componentName = new ComponentName("com.android.contacts", "com.sec.android.app.contacts.PhoneBookTopMenuActivity");
			 intent.setComponent(componentName);
			 intent.setData(contactUri);
		 } else {
*/			intent = new Intent(Intent.ACTION_VIEW, Uri.parse("content://com.android.contacts/contacts/lookup/"+contactUri));
//		 }
	
		this.startActivity(intent);
	}

	
	
	/*
	 * Dialog(s)
	 */
	@Override
	protected Dialog onCreateDialog(int id) {
		switch (id) {
		
		}
		return null;
	}

	

	/*
	 * Options Menu
	 */
	
	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		super.onPrepareOptionsMenu(menu);
		return true;
	}

	
	

	/*
	 * Event handler(s)
	 */
	View.OnClickListener clickHandler = new View.OnClickListener() {
		public void onClick(View v) {
			int id = v.getId();
			if (id == R.id.add_btn) {
				Intent contactPickerIntent = new Intent(Intent.ACTION_PICK, Contacts.CONTENT_URI);
				contactPickerIntent.setType(android.provider.ContactsContract.Contacts.CONTENT_TYPE);
				startActivityForResult(contactPickerIntent, PICK_CONTACT);
			} else {
				return;
			}
		}
	};

	

	

	

	
	class ViewHolder {
		
		TextView name;
		//TextView delete;
	}

	/**
	 * Customized Adapter Class
	 * ####################################################################
	 */
	private class ContactUriAdapter extends ArrayAdapter<Contact> {

		private LayoutInflater li;
		private List<Contact> Contacts;

		public ContactUriAdapter(Context context, int textViewResourceId,
				List<Contact> items) {
			super(context, textViewResourceId, items);

			this.Contacts = items;
			li = LayoutInflater.from(context);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			//ViewHolder holder;
			final Contact a = this.Contacts.get(position);

			if (convertView == null) {
				convertView = li.inflate(android.R.layout.simple_list_item_1, null);
				//holder = new ViewHolder();
				TextView tv = (TextView) convertView.findViewById(android.R.id.text1);
				Log.e("PTSD","--->"+a.getName());
				
				String name = "(no name)";
				if (a.getName()!=null){
					name = a.getName();
				}

				if (a.getNumber()!=null){
					name = name +" - "+a.getNumber();
				}
				
				tv.setText(name);
				convertView.setTag(tv);
			}else{
				//holder = (ViewHolder) convertView.getTag();
			}
			
			

			return convertView;
		}


	}
	
	@Override
	public boolean onContextItemSelected(MenuItem item) {
		AdapterView.AdapterContextMenuInfo itemInfo;
		try {
			itemInfo = (AdapterView.AdapterContextMenuInfo) item.getMenuInfo();
		} catch (ClassCastException e) {
			return false;
		}

		String uri=userDb.getAllContacts().get(itemInfo.position);
		if (uri == null) {
			return false;
		}

		switch (item.getItemId()) {
		
		case MENU_ITEM_DELETE:
			try {
				userDb.deleteContact(uri.toString());
			} catch (Exception e) {
				
			}
			fillData();
			return true;
		}
		return false;
	}
}
