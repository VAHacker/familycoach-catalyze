package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
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

public class ChosenContactListViewController extends ContentListViewController {

	boolean editable = false;
	String selectionClause = null;
	
	public ChosenContactListViewController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public InlineList createList() {

		TypedValue value = new TypedValue();
		getContext().getTheme().resolveAttribute(android.R.attr.listPreferredItemHeight, value, true);
		DisplayMetrics metrics = getContentResources().getDisplayMetrics();

		final float height = (value.getDimension(metrics) - metrics.density * 10);

		ContactList list = new ContactList(this,editable || pick,isInline() && (editable || pick)) {
			public View createItemView() {
				LayoutInflater li = LayoutInflater.from(getContext());
				int res = getResourceAttr(R.attr.contentContactListItem);
				final View itemView = li.inflate(res, null);
				final CheckBox cb = (CheckBox) itemView.findViewById(android.R.id.checkbox);
				if (cb != null) {
					if (editable) {
						cb.setFocusable(true);
						Drawable normal = content.getImage("selectionIconEmpty_file", true);
						Drawable checked = content.getImage("selectionIcon_file", true);

						if ((normal != null) && (checked != null)) {
							Bitmap mutable = ((BitmapDrawable)normal).getBitmap().copy(Bitmap.Config.ARGB_8888, true);
							Canvas c = new Canvas(mutable);
							Paint p = new Paint();
							p.setColor(0xFF606060);
							p.setColorFilter(new PorterDuffColorFilter(0xFF606060, PorterDuff.Mode.MULTIPLY));
							c.drawBitmap(mutable, 0.f, 0.f, p);
							BitmapDrawable pressed = new BitmapDrawable(getResources(), mutable);

							StateListDrawable sld = new StateListDrawable() {
								public int getIntrinsicHeight() {
									return (int)height;
								};

								public int getIntrinsicWidth() {
									int w = super.getIntrinsicWidth();
									int h = super.getIntrinsicHeight();
									return (int)(height * w/h);
								};
							};
							sld.addState(new int[] {android.R.attr.state_pressed}, pressed);
							sld.addState(new int[] {android.R.attr.state_checked}, checked);
							sld.addState(new int[] {}, normal);
							cb.setButtonDrawable(sld);
							int w = sld.getIntrinsicWidth();
							int h = sld.getIntrinsicHeight();
							int width = (int)(height * w/h);
							cb.setMinimumWidth(width);
						}
					} else {
						cb.setVisibility(View.GONE);
					}
				}
				return itemView;
			}

			@Override
			public View viewForItem(Contact item) {
				View v = super.viewForItem(item);
				if (!pick) {
					final CheckBox cb = (CheckBox) v.findViewById(android.R.id.checkbox);
					if (cb != null) {
						cb.setChecked(item.isPreferred());
					}
				}
				return v;
			}
			
			@Override
			public void onCheckStateChanged(Contact item, android.widget.CompoundButton buttonView) {
				super.onCheckStateChanged(item, buttonView);
				if (!pick) {
					if (item.isPreferred() != buttonView.isChecked()) {
						item.setIsPreferred(buttonView.isChecked());
						item.save();
						UserDBHelper.instance(getContext()).setSetting("preferredContactSet", buttonView.isChecked() ? "true" : "false");
					}
				}
			}
			
			public void onItemAdded(Contact item) {
				super.onItemAdded(item);
				if (!pick) {
					UserDBHelper.instance(getContext()).addContact(item);
					UserDBHelper.instance(getContext()).setSetting("contactsCount", ""+getItems().size());
				}
			}
			
			@Override
			public void onItemRemoved(Contact item) {
				super.onItemRemoved(item);
				if (!pick) {
					UserDBHelper.instance(getContext()).deleteContact(item);
					UserDBHelper.instance(getContext()).setSetting("contactsCount", ""+getItems().size());
				}
			}
		};

		list.setRadioBehavior(true);

		if (!pick) {
			List<Contact> contacts = UserDBHelper.instance(getContext()).getAllContacts(selectionClause);
			list.setItems(contacts);
		}
		
		return list;
	}
	
	@Override
	public void buildClientViewFromContent() {
		
		editable = content.getBoolean("editing");
		String show = content.getStringAttribute("show");
		if ("nonPreferredOnly".equals(show)) {
			selectionClause = "preferred=0";
		} else if ("preferredOnly".equals(show)) {
			selectionClause = "preferred=1";
		}

		super.buildClientViewFromContent();

		if (!isInline()) {
/*			
			ViewExtensions extensions = new ViewExtensions() {
				public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
					menu.setHeaderTitle("Add Contact...");
					MenuItem menuItem1 = menu.add(0, 0, 0, "Add from contact list");
					menuItem1.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							((ContactList)list).addContact(Intent.ACTION_PICK);
							return true;
						}
					});

					MenuItem menuItem2 = menu.add(0, 1, 0, "Create new contact");
					menuItem2.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
						public boolean onMenuItemClick(MenuItem menuItem) {
							((ContactList)list).addContact(Intent.ACTION_INSERT);
							return true;
						}
					});
				}
			};
*/			
			if (editable) {
				View addButton = addButton("Add Contact");
//				addButton.setTag(extensions);
				addButton.setOnClickListener(new View.OnClickListener() {
					public void onClick(View v) {
						((ContactList)list).addContact(Intent.ACTION_PICK);
//						v.showContextMenu();
					}
				});
				registerForContextMenu(addButton);
			}
		}
	}
}
