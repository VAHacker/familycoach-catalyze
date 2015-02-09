package gov.va.contentlib.controllers;

import gov.va.contentlib.UserDBHelper;
import gov.va.contentlib.content.Contact;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.PCLScore;
import gov.va.daelib.R;

import java.io.File;
import java.io.FileOutputStream;
import java.text.FieldPosition;
import java.text.Format;
import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.achartengine.ChartFactory;
import org.achartengine.chart.PointStyle;
import org.achartengine.model.XYMultipleSeriesDataset;
import org.achartengine.model.XYSeries;
import org.achartengine.renderer.BasicStroke;
import org.achartengine.renderer.XYMultipleSeriesRenderer;
import org.achartengine.renderer.XYSeriesRenderer;

import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Paint.Cap;
import android.graphics.Paint.Join;
import android.graphics.Paint.Style;
import android.net.Uri;
import android.os.Environment;
import android.os.Parcelable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.format.DateFormat;
import android.text.style.TextAppearanceSpan;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.accessibility.AccessibilityManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

public class PCLHistoryViewController extends ContentViewController {

    ArrayList<String> titleList = new ArrayList<String>();
    ArrayList<View> graphs = new ArrayList<View>();

	public PCLHistoryViewController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public void onContentBecameVisibleForFirstTime() {
		// TODO Auto-generated method stub
		super.onContentBecameVisibleForFirstTime();
        /*
		AccessibilityManager mgr = (AccessibilityManager)getContext().getSystemService(Context.ACCESSIBILITY_SERVICE);
		if (mgr.isEnabled()) {
			speakSpokenText();		
		}
		*/
	}
	
	@Override
	public boolean shouldAddButtonsInScroller() {
		return false;
	}
	/*
	public void sendEmail(Content source) {
		navigateToHere();
		
		try {
			List<Contact> preferred = userDb.getAllContacts("preferred=1");
			StringBuilder sb = new StringBuilder();
			sb.append("\"Time\",\"Score\"\n");
			java.text.DateFormat df = java.text.DateFormat.getDateTimeInstance(java.text.DateFormat.LONG, java.text.DateFormat.LONG);
			for (PCLScore score : scores) {
				sb.append("\"");
				sb.append(df.format(new Date(score.time)));
				sb.append("\",\"");
				sb.append(score.score);
				sb.append("\"\n");
			}

			String filename = "PCL Scores.csv";
			FileOutputStream fos = getContentActivity().openFileOutput(filename, Context.MODE_WORLD_READABLE | Context.MODE_WORLD_WRITEABLE);
			fos.write(sb.toString().getBytes());
			fos.close();

			String address = preferred.get(0).getEMail();
			if (address == null) {
				Builder builder = new AlertDialog.Builder(getContext());
	            builder.setTitle("Error sending e-mail");
	            builder.setMessage("Sorry, but you don't have an e-mail address entered for your preferred health care provider.");
	            builder.setNegativeButton("Ok", null);
	            builder.show();
				return;
			}
			Uri uri = Uri.parse("mailto:"+address);
			Intent intent = new Intent(android.content.Intent.ACTION_SEND,uri);
			intent.setType("text/plain");

			String sdCard = Environment.getExternalStorageDirectory().getAbsolutePath();
			Uri attachment = Uri.fromFile(new File(sdCard + 
					new String(new char[sdCard.replaceAll("[^/]", "").length()])
							.replace("\0", "/..") + getContext().getFilesDir() + "/" + filename));

			intent.putExtra(Intent.EXTRA_EMAIL, new String[] {address});
			intent.putExtra(Intent.EXTRA_SUBJECT, "PCL Scores");
			intent.putExtra(Intent.EXTRA_TEXT, "Here is my latest PCL score history.");
			intent.putExtra(android.content.Intent.EXTRA_STREAM, attachment);
//			startActivity(Intent.createChooser(intent, "Send e-mail..."));
			startActivity(intent);
		} catch (Exception e) {
			Builder builder = new AlertDialog.Builder(getContext());
            builder.setTitle("Error sending e-mail");
            builder.setMessage("Sorry, but I had a problem sending the e-mail.");
            builder.setNegativeButton("Ok", null);
            builder.show();
			return;
		}
		
	}
	*/
	
	public void addSeries(Content c) {
		String seriesName = c.getStringAttribute("series");
        String title = c.getStringAttribute("title");
		List<PCLScore> scores = userDb.getTimeseriesScores(seriesName);
		String[] hilo = c.getStringAttribute("range").split("\\s");
		final double lowValue = Double.parseDouble(hilo[0]);
		final double highValue = Double.parseDouble(hilo[1]);

        StringBuilder sb = new StringBuilder();
        sb.append(title+" history chart. ");
		SimpleDateFormat df = new SimpleDateFormat("MMM dd");
		SimpleDateFormat tf = new SimpleDateFormat("hh:mma");
		if (scores != null) {
			for (PCLScore s : scores) {
				Date d = new Date(s.time);
				String text = "Score of "+s.score+" on "+df.format(d) + " at " + tf.format(d)+". ";
                sb.append(text);
			}
		}

		Date now = new Date();
//		clientView.addView(makeTitleView("Symptom History"));
		
		DisplayMetrics dm = clientView.getResources().getDisplayMetrics();
	    String[] titles = new String[] { "Low", "Med", "High" };
	    
	    double times[] = new double[scores.size()];
	    double values[] = new double[scores.size()];
	    
	    for (int i=0;i<scores.size();i++) {
	    	times[i] = scores.get(i).time;
	    	values[i] = scores.get(i).score;
	    }

	    XYMultipleSeriesRenderer renderer = new XYMultipleSeriesRenderer();
/*	    	public String getXTextLabel(Double x) {
				Calendar cal = Calendar.getInstance(); 
				cal.setTimeInMillis(x.longValue());
				DateFormat df = new DateFormat();
				return df.format("MMM dd", cal).toString();
	    		
	    	}
	    };
	    */
	    
	    renderer.setAxisTitleTextSize(16);
	    renderer.setChartTitleTextSize(20);
	    renderer.setLabelsTextSize(15);
	    renderer.setLegendTextSize(15);
	    renderer.setPointSize(5f);
	    renderer.setMargins(new int[] { 20, 30, 15, 20 });

	    XYSeriesRenderer r = new XYSeriesRenderer();
	    r.setStroke(new BasicStroke(Cap.ROUND, Join.ROUND, 10, null, 0));
	    r.setLineWidth(5);
	    r.setColor(Color.BLUE);
	    r.setPointStyle(PointStyle.CIRCLE);
	    r.setFillPoints(true);
	    renderer.addSeriesRenderer(r);
	    	    
	    renderer.setChartTitle(title);
        renderer.setChartTitleTextSize(48);
	    renderer.setXTitle("");
	    renderer.setYTitle("");
	    
        long bufferTime = (3*24*60*60*1000L);
        long maxTime = (120*24*60*60*1000L);
        
        PCLScore score = scores.get(0);
        long earliest = score.time - bufferTime;
        score = scores.get(scores.size()-1);
        long latest = score.time + bufferTime;
        if (latest < (earliest+maxTime)) {
        	latest = earliest+maxTime;
        } else if (earliest < (latest-maxTime)) {
        	earliest = latest-maxTime;
        }
        
        setVariable(seriesName,scores.get(scores.size()-1).score);
        
	    renderer.setXAxisMin(earliest);
	    renderer.setXAxisMax(latest);
	    
	    Calendar cal = Calendar.getInstance();
	    cal.setTimeInMillis(earliest);
//    	cal.set(Calendar.DATE, 1);
	    
		for (int i=0;i<10;i++) {
	    	renderer.addXTextLabel(cal.getTimeInMillis(), DateFormat.format("MMM dd", cal).toString());
	    	cal.add(Calendar.DATE, 20);
	    }
	    
    	renderer.addYTextLabel(lowValue,"Low");
    	renderer.addYTextLabel((highValue-lowValue)/2,"Med");
    	renderer.addYTextLabel(highValue,"High");

    	renderer.setYLabelsAlign(Align.CENTER);
    	renderer.setXLabelsAlign(Align.LEFT);
    	
    	double realLowValue = lowValue - (highValue-lowValue)*0.1;
    	double realHighValue = highValue + (highValue-lowValue)*0.1;
		renderer.setYAxisMin(realLowValue);
	    renderer.setYAxisMax(realHighValue);
	    
	    renderer.setAxesColor(Color.DKGRAY);
	    renderer.setLabelsColor(Color.DKGRAY);
	    renderer.setXLabelsColor(Color.DKGRAY);
	    renderer.setYLabelsColor(0, Color.DKGRAY);
	    renderer.setYLabels(0);
	    renderer.setShowAxes(true);
	    renderer.setShowLegend(false);
	    renderer.setXLabels(0);
	    renderer.setShowGrid(true);
	    renderer.setAntialiasing(true);
	    renderer.setPointSize(16);
	    renderer.setAxisTitleTextSize(64);
	    renderer.setGridColor(Color.DKGRAY);
	    renderer.setApplyBackgroundColor(true);
	    renderer.setBackgroundColor(Color.argb(255, 255, 255, 255));
	    renderer.setShowGridX(false);
	    renderer.setXLabelsAngle(45);
	    renderer.setYLabelsAngle(-90);

	    renderer.setLabelsTextSize(24);
	    renderer.setBackgroundColor(0xFFFFFFFF);
	    renderer.setZoomButtonsVisible(false);
	    renderer.setPanEnabled(false);
	    renderer.setExternalZoomEnabled(false);
	    renderer.setZoomEnabled(false);
	    renderer.setZoomLimits(new double[] {1,1,1,1});
	    renderer.setPanLimits(new double[] {score.time,latest,realLowValue,realHighValue});
	    renderer.setMarginsColor(Color.WHITE);

   	    XYMultipleSeriesDataset dataset = new XYMultipleSeriesDataset();

   	    XYSeries series = new XYSeries("series", 0);
   	    double[] xV = times;
   	    double[] yV = values;
   	    int seriesLength = xV.length;
   	    for (int k = 0; k < seriesLength; k++) {
   	    	series.add(xV[k], yV[k]);
   	    }
   	    dataset.addSeries(series);

   	    View v = ChartFactory.getLineChartView(getContext(), dataset, renderer);
   	    v.setBackgroundColor(Color.WHITE);
   	    v.setPadding(10, 10, 10, 10);
   	    //v.setBackgroundDrawable(null);
   	    FrameLayout fl = new FrameLayout(getContext()) {
   	    	public boolean onInterceptTouchEvent(android.view.MotionEvent ev) { return true; };
   	    };
   	    fl.addView(v);

   	    LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,500);
   	    lp.setMargins(40, 20, 40, 20);
        fl.setContentDescription(sb);
        fl.setLayoutParams(lp);

        graphs.add(fl);
        titleList.add(title);
	}

	public void buildClientViewFromContent() {
        for (Content c : getContent().getChildren("@series", true, false)) {
        	addSeries(c);
        }

        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 500);
        ViewPager pager = new ViewPager(getContext());
        pager.setLayoutParams(lp);
        PagerAdapter adapter = new PagerAdapter() {

            @Override
            public int getCount() {
                // TODO Auto-generated method stub
                return graphs.size();
            }

            public Object instantiateItem(View collection, int position) {
                View view = graphs.get(position);
                ((ViewPager) collection).addView(view, 0);
                return view;
            }

            @Override
            public void destroyItem(View arg0, int arg1, Object arg2) {
                ((ViewPager) arg0).removeView((View) arg2);
            }

            @Override
            public boolean isViewFromObject(View arg0, Object arg1) {
                return arg0 == ((View) arg1);
            }

            @Override
            public Parcelable saveState() {
                return null;
            }


            @Override
            public CharSequence getPageTitle(int position) {
                return titleList.get(position);
                /*
                ContentViewControllerBase cvc = controllerList.get(position);
                String title = cvc.getContent().getDisplayName().toUpperCase();
                SpannableStringBuilder sb = new SpannableStringBuilder(title); // space added before text for convenience
                sb.setSpan(new TextAppearanceSpan(getContext(),getResourceAttr(gov.va.daelib.R.attr.actionBarTabTextStyle)), 0, title.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                return sb;
                */
            }
        };
        pager.setAdapter(adapter);
        pager.setCurrentItem(0);
        clientView.addView(pager);

        super.buildClientViewFromContent();

        addButton("Clear History").setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Builder builder = new AlertDialog.Builder(getContext());
	            builder.setTitle("Clear History");
	            builder.setIcon(R.drawable.icon);

	            builder.setMessage("Are you sure you want to clear your assessment history?  You will be unable to view any past assessment progress or compare with future results.");
	            builder.setPositiveButton("Yes, delete history", new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
				        for (Content c : getContent().getChildren("@series", true, false)) {
							UserDBHelper.instance(getContext()).clearTimeseriesScores(c.getStringAttribute("series"));
				        }
						goBack();
					}
				});
	            builder.setNegativeButton("Nevermind", null);
	            builder.show();
			}
		});

	}
	
	@SuppressWarnings("serial")
	@Override
	public void build() {
//        registerAction("sendEmail");
		super.build();
	}

}
