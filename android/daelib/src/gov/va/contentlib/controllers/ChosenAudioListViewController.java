package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Audio;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.AudioList;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;
import gov.va.contentlib.views.ViewExtensions;
import gov.va.daelib.R;

import java.io.FileNotFoundException;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.net.Uri;
import android.provider.ContactsContract.Contacts;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.CheckBox;
import android.widget.LinearLayout;
import android.widget.ScrollView;

public class ChosenAudioListViewController extends ContentListViewController {

	boolean editable = false;
	
	public ChosenAudioListViewController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public InlineList createList() {
		AudioList list = new AudioList(this,editable,isInline() && editable) {
			public void onItemAdded(Audio item) {
				super.onItemAdded(item);
				UserDBHelper.instance(getContext()).addAudio(item);
				UserDBHelper.instance(getContext()).setSetting("audioCount", ""+getItems().size());
			}
			
			@Override
			public void onItemRemoved(Audio item) {
				super.onItemRemoved(item);
				UserDBHelper.instance(getContext()).deleteAudio(item);
				UserDBHelper.instance(getContext()).setSetting("audioCount", ""+getItems().size());
			}
		};
		
		List<Audio> audioList = UserDBHelper.instance(getContext()).getAllAudio();
		list.setItems(audioList);
		return list;
	}
	
	@Override
	public void buildClientViewFromContent() {
		editable = content.getBoolean("editing");

		super.buildClientViewFromContent();

		if (!isInline() && editable) {
			View addButton = addButton("Add Audio");
			addButton.setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					((AudioList)list).addAudio();
				}
			});
		}
	}
}
