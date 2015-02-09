package gov.va.contentlib.activities;

import android.R;
import android.annotation.TargetApi;
import android.app.ListActivity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.CalendarContract.Calendars;
import android.support.v4.widget.CursorAdapter;
import android.support.v4.widget.SimpleCursorAdapter;
import android.util.TypedValue;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;


@TargetApi(14)
public class CalendarChoiceActivity extends ListActivity {

	protected int getResourceAttr(int attr) {
		TypedValue typedvalueattr = new TypedValue();
		getTheme().resolveAttribute(attr, typedvalueattr, true);
		return typedvalueattr.resourceId;
	}

	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		ContentResolver cr = getContentResolver();
		Uri uri = Calendars.CONTENT_URI;   
		Cursor cur = cr.query(uri, null, null, null, null);
		SimpleCursorAdapter adapter = new SimpleCursorAdapter(this, android.R.layout.simple_list_item_1, cur, new String[] { Calendars.NAME }, new int[] {android.R.id.text1}, CursorAdapter.FLAG_REGISTER_CONTENT_OBSERVER);
		TextView tv = new TextView(this);

		PackageManager pm = getPackageManager();
		String appLabel = null;
		try {
			appLabel = pm.getApplicationLabel(pm.getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA)).toString() + " ";
		} catch (Exception e) {}

		tv.setText("Please choose a calendar to use for "+appLabel+"events.  Events will be set as private when they are created, but you may want to select a private calendar (for example, one that isn't synchronized with a work calendar.)");
//		tv.setTextAppearance(this, getResourceAttr(R.attr.textAppearanceLarge));
		tv.setPadding(tv.getPaddingLeft()+10, tv.getPaddingTop()+10, tv.getPaddingRight()+10, tv.getPaddingBottom()+10);
		getListView().addHeaderView(tv);
		setListAdapter(adapter);
	}

	@Override
	protected void onListItemClick(ListView l, View v, int position, long id) {
		Cursor c = (Cursor)getListAdapter().getItem(position-1);
		c.moveToPosition(position-1);
		long calID = c.getLong(c.getColumnIndex(Calendars._ID));
		setResult(RESULT_OK, new Intent().setData(ContentUris.withAppendedId(Calendars.CONTENT_URI, calID)));
		finish();
	}
}
