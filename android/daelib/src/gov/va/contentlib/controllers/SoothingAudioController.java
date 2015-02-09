package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Audio;
import gov.va.contentlib.views.AudioList;
import gov.va.contentlib.views.LoggingButton;
import gov.va.daelib.R;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.util.Log;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;

public class SoothingAudioController extends SimpleExerciseController {

	public SoothingAudioController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void buildClientViewFromContent() {
		super.buildClientViewFromContent();

		AudioList audioList = new AudioList(this, false, false);
		List<Audio> songs = UserDBHelper.instance(getContext()).getAllAudio();
		audioList.setItems(songs);
		clientView.addView(audioList);
		clientView.setKeepScreenOn(true);
	}
	
	public String checkPrerequisites() {
		if (userDb.getAllAudio().size() > 0) return null;
		return "You haven't chosen any soothing songs or audio clips from your audio library.  Go to Setup and choose some audio before you can use this tool.";
	}
	
}
