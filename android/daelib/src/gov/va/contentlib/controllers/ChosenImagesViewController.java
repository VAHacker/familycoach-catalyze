package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Audio;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.contentlib.content.Image;
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
import android.database.DataSetObserver;
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
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ContextMenu.ContextMenuInfo;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.AdapterView.AdapterContextMenuInfo;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.ImageView.ScaleType;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ScrollView;

public class ChosenImagesViewController extends ContentViewController {

	boolean editable = false;
	List<Image> imageList;
	GridView grid;
	BaseAdapter adapter;
	
	public ChosenImagesViewController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public boolean shouldUseScroller() {
		return false;
	}
	
	public void addImage() {
		Intent photoPickerIntent = new Intent(Intent.ACTION_PICK);
		photoPickerIntent.setType("image/*");
		startActivityForResult(photoPickerIntent, new ContentActivity.ActivityResultListener() {
			public void onActivityResult(int requestCode, int resultCode, Intent data) {
				if (data != null) {
					Image image = new Image(userDb, data.getData());
					userDb.addImage(image);
					imageList.add(image);
					adapter.notifyDataSetChanged();
				}
			}
		});
	}


	@Override
	public void buildClientViewFromContent() {
		editable = (content != null) && content.getBoolean("editing");

		super.buildClientViewFromContent();

		imageList = userDb.getAllImages();
		
		grid = new GridView(getContext());
		adapter = new BaseAdapter() {
			
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				FrameLayout frame = new FrameLayout(getContext());
				int padding = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 2, getContentResources().getDisplayMetrics());
				if (padding < 1) padding = 1;
				frame.setPadding(padding, padding, padding, padding);
				ImageView iv = new ImageView(getContext());
				final Image item = imageList.get(position);
				iv.setImageBitmap(item.getBitmap());
				iv.setScaleType(ScaleType.CENTER_CROP);
				frame.addView(iv);
				int size = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 92, getContentResources().getDisplayMetrics());
				AbsListView.LayoutParams lp = new AbsListView.LayoutParams(size,size, Gravity.CENTER);
				frame.setLayoutParams(lp);
//				registerForContextMenu(frame);
				frame.setTag(new ViewExtensions() {
					@Override
					public void onCreateContextMenu(ContextMenu menu, ContextMenuInfo menuInfo) {
						super.onCreateContextMenu(menu, menuInfo);
						if (!editable) return;
						menu.setHeaderTitle(item.getName());
						MenuItem menuItem = menu.add(0, 100, 0, "Remove");
						menuItem.setIcon(new BitmapDrawable(item.getBitmap()));
						menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
							public boolean onMenuItemClick(MenuItem menuItem) {
								userDb.deleteImage(item);
								imageList.remove(item);
								adapter.notifyDataSetChanged();
								return true;
							}
						});

					}
				});
				return frame;
			}
			
			@Override
			public long getItemId(int position) {
				return position;
			}
			
			@Override
			public Object getItem(int position) {
				return imageList.get(position);
			}
			
			@Override
			public int getCount() {
				return imageList.size();
			}
		};
		
		grid.setAdapter(adapter);
		grid.setNumColumns(-1);
		grid.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
		grid.setColumnWidth((int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 100, getContentResources().getDisplayMetrics()));
		grid.setGravity(Gravity.TOP | Gravity.CENTER);
		
		clientView.addView(grid, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT, Gravity.CENTER));
		
		if (editable) {
			View addButton = addButton("Add Image");
			addButton.setOnClickListener(new View.OnClickListener() {
				public void onClick(View v) {
					addImage();
				}
			});
		}
		
		grid.setOnItemClickListener(new AdapterView.OnItemClickListener() {
	        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
	    		Intent intent = new Intent();  
	    		intent.setAction(android.content.Intent.ACTION_VIEW);  
	    		intent.setDataAndType(imageList.get(position).getimageUril(), "image/*");  
	    		startActivity(intent);
	        }
		});
		
		grid.setOnCreateContextMenuListener(new View.OnCreateContextMenuListener() {
			public void onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo _menuInfo) {
				AdapterContextMenuInfo menuInfo = (AdapterContextMenuInfo) _menuInfo;
				
				if (!editable) return;
				final Image item = imageList.get(menuInfo.position);
				menu.setHeaderTitle(item.getName());
				MenuItem menuItem = menu.add(0, 100, 0, "Remove");
				menuItem.setIcon(new BitmapDrawable(item.getBitmap()));
				menuItem.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
					public boolean onMenuItemClick(MenuItem menuItem) {
						userDb.deleteImage(item);
						imageList.remove(item);
						adapter.notifyDataSetChanged();
						return true;
					}
				});
			}
		});

	}
}
