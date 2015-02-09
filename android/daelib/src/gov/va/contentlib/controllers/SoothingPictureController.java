package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Image;
import gov.va.daelib.R;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class SoothingPictureController extends SimpleExerciseController {

	public SoothingPictureController(Context ctx) {
		super(ctx);
	}
	
	public String checkPrerequisites() {
		if (userDb.getAllImages().size() > 0) return null;
		return "You haven't chosen any soothing pictures from your photo library.  Go to Setup and choose some pictures before you can use this tool.";
	}

	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();
		
		ChosenImagesViewController chooseImages = new ChosenImagesViewController(getContext());
		chooseImages.setContent(new Content());
		clientView.addView(chooseImages.getView());
	}
}
