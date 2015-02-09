package gov.va.contentlib.controllers;

import java.util.ArrayList;
import java.util.List;

import gov.va.contentlib.R;
import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.Util;
import gov.va.contentlib.activities.ManageNavigationController;
import gov.va.contentlib.contact.Contact;
import gov.va.contentlib.contact.ContactUtil;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.DataSetObserver;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.provider.ContactsContract.Contacts;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.FrameLayout.LayoutParams;

public class PlanController extends BaseExerciseController {

	ContactList contactList;
	Spinner contactSpinner;
	Spinner activitySpinner;
	final static int PICK_CONTACT=12;
	
	public PlanController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		super.build();
		Content contacts = getContent().getChildByName("@contacts");
		Content activities = getContent().getChildByName("@activities");

		LinearLayout.LayoutParams lp;
		ArrayAdapter a;

		addMainTextContent(contacts.getMainText());
		
		contactList = new ContactList(this, true);
		lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(contactList,lp);
		contactList.setOnItemClickListener(new InlineList.OnItemClickListener<Contact>() {
			@Override
			public void onItemClick(int i, View v, Contact item) {
				Intent in=new Intent(Intent.ACTION_VIEW, item.getUri());
				getContext().startActivity(in);
			}
		});

		contactList.bindToVariable("socialActivitySummaryContactList", true);

		/*		
		contactSpinner = new Spinner(getContext());
		List<Contact> contactList = ContactUtil.UriListToContactList(UserDBHelper.instance(getContext()).getAllContacts(), getContext());
		List<String> contactNames = new ArrayList<String>();
		for (Contact c : contactList) {
			String name = c.getName();
			if (name == null) name = c.getNumber();
			contactNames.add(name);
		}
		ArrayAdapter a = new ArrayAdapter<String>(getContext(), android.R.layout.simple_spinner_item, contactNames);
		a.setDropDownViewResource(android.R.layout.select_dialog_item);
		contactSpinner.setAdapter(a);
		lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(contactSpinner,lp);
*/		
		addMainTextContent(activities.getMainText());
		activitySpinner = new Spinner(getContext());
		List<Content> activityList = activities.getChildren();
		List<String> activityNames = new ArrayList<String>();
		for (Content c : activityList) {
			String name = c.getDisplayName();
			activityNames.add(name);
		}
		a = new ArrayAdapter<String>(getContext(), android.R.layout.simple_spinner_item, activityNames);
		a.setDropDownViewResource(android.R.layout.select_dialog_item);
		activitySpinner.setAdapter(a);
		lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, 80);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(activitySpinner,lp);
		
		addThumbs();
		addButton("Next", ManageNavigationController.BUTTON_NEXT);
	}

	public String makeContactsSummary() {
		List<Contact> list = contactList.getItems();
		StringBuilder sb = new StringBuilder();
		sb.append(list.get(0).getName());
		if (list.size() > 1) {
			for (int i=1; i<list.size()-1;i++) {
				sb.append(", ");
				sb.append(list.get(i).getName());
			}
			sb.append(" and ");
			sb.append(list.get(list.size()-1).getName());
		}
		
		return sb.toString();
	}

	public String makeSummary() {
		return ((String)activitySpinner.getSelectedItem()) + " with " + makeContactsSummary();
	}

	@Override
	public void buttonTapped(int id) {
		if (id == ManageNavigationController.BUTTON_NEXT) {
			if (contactList.getItems().size() == 0) {
				AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
				builder.setTitle("No Contacts Selected");
				builder.setMessage("First add some contacts to the list before continuing.");
				builder.setPositiveButton("Ok", null);
				builder.show();
				return;
			}

			getNavigator().setVariable("socialActivitySummary", makeSummary());
			getNavigator().bgrunner.post(new Runnable() {
				@Override
				public void run() {
					Content scheduleIt = getContent().getChildByName("@scheduleIt");
					ContentViewControllerBase cvc = scheduleIt.createContentView(getNavigator());
					getNavigator().pushView(cvc);
				}
			});
		}
	}
}
