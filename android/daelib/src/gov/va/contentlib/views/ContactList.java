package gov.va.contentlib.views;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.daelib.R;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

import android.app.AlertDialog;
import android.content.ContentUris;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.provider.ContactsContract.Contacts;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

public class ContactList extends InlineList<Contact> {
	private final static int MENU_ITEM_ADD_NEW = Menu.FIRST;
	private final static int MENU_ITEM_ADD_EXISTING = Menu.FIRST+1;

	public ContactList(ContentViewControllerBase context, boolean editable, boolean showInlineAddItem) {
		super(context);
		
		setEditable(editable);
		setPickMode(true);
		setOnItemClickListener(new InlineList.OnItemClickListener<Contact>() {
			@Override
			public void onItemClick(int i, View v, Contact item) {
				Contact contact = (Contact)item;
				Intent intent = new Intent(Intent.ACTION_VIEW, contact.getUri());
				contentController.startActivity(intent);
			}
		});

		if (showInlineAddItem) {
/*
			ViewExtensions extensions = new ViewExtensions() {
				public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
					menu.setHeaderTitle("Add Contact...");
					MenuItem menuItem1 = menu.add(0, MENU_ITEM_ADD_NEW, 0, "Add from contact list");
					menuItem1.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							addContact(Intent.ACTION_PICK);
							return true;
						}
					});

					MenuItem menuItem2 = menu.add(0, MENU_ITEM_ADD_EXISTING, 0, "Create new contact");
					menuItem2.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							addContact(Intent.ACTION_INSERT);
							return true;
						}
					});
				}
			};
*/			
			View addItem = setOnAddListener("Add Contact...", new InlineList.OnAddListener() {
				@Override
				public void onAdd(View v) {
					addContact(Intent.ACTION_PICK);
//					v.showContextMenu();
				}
			}, null);//extensions);
		}
	}
	
	@Override
	public void onDuplicateAddAttempted(Contact item) {
		super.onDuplicateAddAttempted(item);
		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
		builder.setTitle("Duplicate Contact");
		builder.setMessage("'"+item.getName()+"' is already in the list.");
		builder.setPositiveButton("Ok", null);
		builder.show();
	}
	
	public void addContact(String action) {
		Intent contactPickerIntent = new Intent(action, Contacts.CONTENT_URI);
		contactPickerIntent.setType(android.provider.ContactsContract.Contacts.CONTENT_TYPE);
		
		contentController.startActivityForResult(contactPickerIntent, new ContentActivity.ActivityResultListener() {
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
				if (data != null) {
					Uri selectedcontact= data.getData();
					String toStore = selectedcontact.toString();
					Cursor info = getContext().getContentResolver().query(selectedcontact, null, null, null, null);
					while(info.moveToNext()) {
						int nameFieldColumnIndex = info.getColumnIndex(Contacts.LOOKUP_KEY);
						toStore = info.getString(nameFieldColumnIndex);
						Contact contact = new Contact(UserDBHelper.instance(getContext()), toStore, false);
						addItem(contact);
						break;
					}
				}
			}
		});
		
	}
	
	@Override
	public Contact idToItem(String id) {
		return new Contact(UserDBHelper.instance(getContext()), id, false);
	}
	
	@Override
	public String itemToID(Contact item) {
		return item.getLookupID();
	}

	public Drawable iconForItem(Contact item) {
		Drawable d = null;
		d = Drawable.createFromStream(item.openPhoto(getContext()),null);
		
		if (d == null) {
			d = getResources().getDrawable(R.drawable.icon_contact);
		}
		return d;
	}
	
	public String labelForItem(Contact item) {
		String name = "(no name)";
		if (item.getName()!=null){
			name = item.getName();
		}
		return name;
	}

	public String sublabelForItem(Contact item) {
		String sublabel = item.getNumber();
		if (sublabel == null) sublabel = "";
		return sublabel;
	}
	
}
