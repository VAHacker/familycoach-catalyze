package gov.va.contentlib.views;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Audio;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.controllers.ContentViewControllerBase;
import gov.va.daelib.R;

import java.io.FileNotFoundException;

import android.app.AlertDialog;
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

public class AudioList extends InlineList<Audio> {
	private final static int MENU_ITEM_ADD_NEW = Menu.FIRST;
	private final static int MENU_ITEM_ADD_EXISTING = Menu.FIRST+1;

	public AudioList(ContentViewControllerBase context, boolean editable, boolean showInlineAddItem) {
		super(context);
		
		setEditable(editable);
		
		setOnItemClickListener(new InlineList.OnItemClickListener<Audio>() {
			@Override
			public void onItemClick(int i, View v, Audio audio) {
				Intent intent = new Intent(Intent.ACTION_VIEW, audio.getAudioUri());
				contentController.startActivity(intent);
			}
		});

		if (showInlineAddItem) {
			View addItem = setOnAddListener("Add Audio...", new InlineList.OnAddListener() {
				@Override
				public void onAdd(View v) {
					addAudio();
				}
			}, null);
		}
	}
	
	@Override
	public void onDuplicateAddAttempted(Audio item) {
		super.onDuplicateAddAttempted(item);
		AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
		builder.setTitle("Duplicate Song");
		builder.setMessage("'"+item.getName()+"' is already in the list.");
		builder.setPositiveButton("Ok", null);
		builder.show();
	}
	
	public void addAudio() {
		Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
		intent.setType("audio/*");
		intent = Intent.createChooser(intent, "Select soothing audio or music");
		contentController.startActivityForResult(intent, new ContentActivity.ActivityResultListener() {
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
				if (data != null) {
					Audio audio = new Audio(UserDBHelper.instance(getContext()), data.getData());
					addItem(audio);
				}
			}
		});
	}
	
	@Override
	public Audio idToItem(String id) {
		return new Audio(UserDBHelper.instance(getContext()), Uri.parse(id));
	}
	
	@Override
	public String itemToID(Audio item) {
		return item.getAudioUri().toString();
	}

	public String labelForItem(Audio item) {
		String name = "(no name)";
		if (item.getName()!=null){
			name = item.getName();
		}
		return name;
	}

	public String sublabelForItem(Audio item) {
		String sublabel = item.getArtist();
		if (sublabel == null) sublabel = "";
		return sublabel;
	}
	
}
