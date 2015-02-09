package gov.va.contentlib.controllers;

import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.ContactList;
import gov.va.contentlib.views.InlineList;

import java.util.ArrayList;
import java.util.List;

import android.app.AlertDialog;
import android.content.Context;
import android.content.Intent;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.Spinner;

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
/*
		contactList = new ContactList(this, true, true);
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
*/
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
        int h = (int)getDimAttr(android.R.attr.listPreferredItemHeight);
        lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, h);
		lp.setMargins(10, 0, 10, 0);
		clientView.addView(activitySpinner,lp);
		
		addThumbs();
		addButton("Next").setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				String var = (String)getVariable("socialActivitySummaryContactList");
				if ((var == null) || (var.length() == 0)) {
					AlertDialog.Builder builder = new AlertDialog.Builder(getContext());
					builder.setTitle("No Contacts Selected");
					builder.setMessage("First add some contacts to the list before continuing.");
					builder.setPositiveButton("Ok", null);
					builder.show();
					return;
				}

				setVariable("socialActivitySummary", makeSummary());
				navigateToNext();
			}
		});		
	}

	public String makeContactsSummary() {
		String var = (String)getVariable("socialActivitySummaryContactList");
		List<Contact> list = Contact.inflateContacts(userDb, var);
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

}
