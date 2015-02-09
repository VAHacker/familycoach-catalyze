package gov.va.contentlib.controllers;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import gov.va.contentlib.TopContentActivity;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.audio.Audio;
import gov.va.contentlib.audio.AudioUtil;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.contact.ContactUtil;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.image.Image;
import gov.va.contentlib.image.ImageUtil;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;
import gov.va.contentlib.R;


import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;
import android.widget.Toast;

public class CrisisController extends SimpleExerciseController {

	ContactToStringAdapter adapter ;
	UserDBHelper userDb;
	Context con;
	Spinner contactList;
	public CrisisController(Context ctx) {
		super(ctx);
		con = ctx;
		userDb = UserDBHelper.instance(ctx);
	}

	class JSInterface {
		public void listen() {
			playAudio();
		}
	}

	public String checkPrerequisites() {
		if (userDb.getAllContacts().size() > 0) return null;
		return "You haven't chosen any support contacts.  Go to Setup and choose some contacts before you can use this tool.";
	}

	@Override
	public void build() {
		if ("seekSupport".equals(getContent().getName())) {
			super.build();
		} else {
			nonExerciseBuild();
		}

		final List<Contact> contacts = ContactUtil.UriListToContactList(userDb.getAllContacts(),con);
		for (Content child : getContent().getChildren()) {
			String name = child.getName();
			if ((name == null) || name.startsWith("@")) {
				String special = child.getStringAttribute("special");
				Content headerContent = getContent().getChildByName("@"+special);
				if (special.equals("contacts"))  {
					if (contacts.size() == 0) {
						addMainTextContent(getContent().getChildByName("@contacts.none").getMainText());
					} else {
						addMainTextContent(headerContent.getMainText());
						if(contacts.size()>0) {
							ContactList list = new ContactList(this, false);
							LinearLayout.LayoutParams listLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
							listLayout.setMargins(10, 0, 10, 10);
							list.setLayoutParams(listLayout);
							for (Contact c : contacts) {
								list.addItem(c);
							}
							clientView.addView(list);

							list.setOnItemClickListener(new InlineList.OnItemClickListener<Contact>() {
								@Override
								public void onItemClick(int i, View v, Contact item) {
									Intent in=new Intent(Intent.ACTION_VIEW, item.getUri());
									con.startActivity(in);
								}
							});
						}
					}
				} else {
					addMainTextContent(headerContent.getMainText());

					final String title = child.getDisplayName();
					InlineList<String> list = new InlineList<String>(this, title) {
						public int getItemResource() {
							return R.layout.emergency_list_item;
						}
					};
         			LinearLayout.LayoutParams listLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
         			listLayout.setMargins(10, 0, 10, 10);
         			list.setLayoutParams(listLayout);
        			clientView.addView(list);
        			
        			list.requestFocus();
        			
        			list.setOnItemClickListener(new InlineList.OnItemClickListener<String>() {
						@Override
						public void onItemClick(int i, View v, String item) {
							Intent in=new Intent(Intent. ACTION_DIAL,Uri.parse("tel:"+title.split(" ")[1]));
							con.startActivity(in);
						}
					});

				}

			}

		}


	}
	List<String> contactArrayToStringArray(List<Contact> contacts){
		List<String> audioNames=new ArrayList<String>();
		for(Contact c : contacts){
			String name = "(no name)";
			if(c==null) continue;

			if (c.getName()!=null){
				name = c.getName();
			}

			if (c.getNumber()!=null){
				name = name +" - "+c.getNumber();
			}

			audioNames.add(name);
		}
		return audioNames;
	}

	private class ContactToStringAdapter extends ArrayAdapter<String> {

		private LayoutInflater li;
		private List<String> Strings;

		public ContactToStringAdapter(Context context, int textViewResourceId,
				List<String> items) {
			super(context, textViewResourceId, items);

			this.Strings = items;
			li = LayoutInflater.from(context);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			//ViewHolder holder;
			final String s = this.Strings.get(position);

			if (convertView == null) {

				convertView = li.inflate(android.R.layout.select_dialog_item, null);
				//holder = new ViewHolder();
				if(s==null){
					return convertView;
				}
				TextView tv = (TextView) convertView.findViewById(android.R.id.text1);
				//				tv.setTextColor(Color.BLACK);
				//				if(s.length()>25){
				//				tv.setText(s.substring(0, 25));
				//		}else {
				tv.setText(s);
				//		}
				convertView.setTag(tv);
			}else{

			}



			return convertView;
		}


	}

	@Override
	public void parentActivityPaused()
	{
		TopContentActivity a =(TopContentActivity)getNavigator().getParent();

		if(a.fromBackground)
		{
			//we are going into the background,go back
			getNavigator().popToRoot();
			getNavigator().goBack();
		}
	}
}
