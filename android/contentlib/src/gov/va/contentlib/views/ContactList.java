package gov.va.contentlib.views;

import org.xml.sax.ContentHandler;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.view.ContextMenu;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import gov.va.contentlib.activities.NavigationController;
import android.view.ContextMenu.ContextMenuInfo;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.controllers.ContentViewControllerBase;

public class ContactList extends InlineList<Contact> {
	private final static int MENU_ITEM_ADD_NEW = Menu.FIRST;
	private final static int MENU_ITEM_ADD_EXISTING = Menu.FIRST+1;
	final static int PICK_CONTACT=12;

	class ResultListener implements ContentViewControllerBase.ActivityResultListener {
		public void onActivityResult(int requestCode, int resultCode, Intent contactReturnedIntent) {
			if (requestCode == PICK_CONTACT) {
				if (resultCode == Activity.RESULT_OK){  
					Uri selectedcontact= contactReturnedIntent.getData();
					Cursor info = getContext().getContentResolver().query(selectedcontact, null, null, null, null);
					if (info.moveToNext()) {
						Contact contact = new Contact(contentController.getNavigator(), info);
						addItem(contact);
					}
					info.close();
				}
				
				contentController.removeActivityResultListener(this);
			}
		}
	}
	
	public ContactList(ContentViewControllerBase context, boolean editable) {
		super(context);
		
		setEditable(editable);
		
		ViewExtensions extensions = null;
		if (editable) {
			extensions = new ViewExtensions() {
				public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
					menu.setHeaderTitle("Add Contact...");
					MenuItem menuItem1 = menu.add(0, MENU_ITEM_ADD_NEW, 0, "Add from contact list");
					menuItem1.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							Intent contactPickerIntent = new Intent(Intent.ACTION_PICK, Contacts.CONTENT_URI);  
							contactPickerIntent.setType(android.provider.ContactsContract.Contacts.CONTENT_TYPE);
							contentController.addActivityResultListener(new ResultListener());
							((Activity)getContext()).startActivityForResult(contactPickerIntent, PICK_CONTACT);  
							return true;
						}
					});

					MenuItem menuItem2 = menu.add(0, MENU_ITEM_ADD_EXISTING, 0, "Create new contact");
					menuItem2.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							Intent intent = new Intent(Intent.ACTION_INSERT);
							intent.setType(ContactsContract.Contacts.CONTENT_TYPE);
							contentController.addActivityResultListener(new ResultListener());
							((Activity)getContext()).startActivityForResult(intent, PICK_CONTACT);  
							return true;
						}
					});
				}
			};
		}

		setOnItemClickListener(new InlineList.OnItemClickListener<Contact>() {
			@Override
			public void onItemClick(int i, View v, Contact item) {
				Intent in=new Intent(Intent.ACTION_VIEW, item.getUri());
				getContext().startActivity(in);
			}
		});

		if (editable) {
			View addItem = setOnAddListener("Add Contact...", new InlineList.OnAddListener() {
				@Override
				public void onAdd(View v) {
					contentController.getNavigator().openContextMenu(v);
				}
			}, extensions);
			contentController.getNavigator().registerForContextMenu(addItem);
		}
	}
	
	@Override
	public Contact idToItem(String id) {
		return new Contact(contentController.getNavigator(), id);
	}
	
	@Override
	public String itemToID(Contact item) {
		return item.getLookupID();
	}
	
	public Uri imageForItem(Contact item) {
		return item.getPhotoURI();
	}
	
}
