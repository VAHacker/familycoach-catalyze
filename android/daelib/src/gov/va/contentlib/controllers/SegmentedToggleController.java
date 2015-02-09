package gov.va.contentlib.controllers;

import java.util.ArrayList;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.views.SegmentedRadioGroup;
import android.R;
import android.content.Context;
import android.graphics.Color;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.PagerTabStrip;
import android.support.v4.view.ViewPager;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.StyleSpan;
import android.text.style.TextAppearanceSpan;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.ViewSwitcher;
import android.widget.FrameLayout.LayoutParams;

public class SegmentedToggleController extends ContentViewControllerBase {

	public SegmentedToggleController(Context ctx) {
		super(ctx);
	}

	@Override
	public void build() {
		topView = new LinearLayout(getContext());
		topView.setOrientation(LinearLayout.VERTICAL);
		topView.setBackgroundColor(0);
		FrameLayout.LayoutParams topLayout = new FrameLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.FILL_PARENT);
		topView.setLayoutParams(topLayout);

		getView().setBackgroundResource(getResourceAttr(gov.va.daelib.R.attr.contentViewBackground));
		getView().addView(topView);
		
		final ArrayList<ContentViewControllerBase> controllerList = new ArrayList<ContentViewControllerBase>();
		final ArrayList<View> viewList = new ArrayList<View>();
		for (Content child : content.getChildren()) {
			ContentViewControllerBase cv = child.createInlineContentView(this,getContext());
			cv.setNavigator(this);
			addChildController(cv);
			controllerList.add(cv);
			
			ScrollView scroller = new ScrollView(getContext());
			scroller.setFillViewport(true);
			scroller.setBackgroundColor(0);
			scroller.setHorizontalScrollBarEnabled(false);
			scroller.setVerticalScrollBarEnabled(true);
			LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
			p.weight = 1;
			scroller.addView(cv.getView(),p);
			
			viewList.add(scroller);
		}

		ViewPager pager = new ViewPager(getContext());
		PagerTabStrip tabs = new PagerTabStrip(getContext());
		ViewPager.LayoutParams pagerLayout = new ViewPager.LayoutParams();
		pagerLayout.height = LayoutParams.WRAP_CONTENT;
		pagerLayout.width = LayoutParams.MATCH_PARENT;
		pagerLayout.gravity = Gravity.TOP;
		tabs.setLayoutParams(pagerLayout);
		PagerAdapter adapter = new PagerAdapter() {
			
			@Override
			public int getCount() {
				// TODO Auto-generated method stub
				return getChildControllers().size();
			}

			public Object instantiateItem(View collection, int position) {
				View view = viewList.get(position);
				view.setLayoutParams(new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));
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
				ContentViewControllerBase cvc = controllerList.get(position);
				String title = cvc.getContent().getDisplayName().toUpperCase();
				SpannableStringBuilder sb = new SpannableStringBuilder(title); // space added before text for convenience
			    sb.setSpan(new TextAppearanceSpan(getContext(),getResourceAttr(gov.va.daelib.R.attr.actionBarTabTextStyle)), 0, title.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE); 
			    return sb;
			}
		};
		pager.addView(tabs);
		pager.setAdapter(adapter);
		pager.setCurrentItem(0);
		
		clientView = pager;
		LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		p.weight = 1;
		LinearLayout.LayoutParams scrollerLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
		scrollerLayout.weight = 1;
		clientView.setLayoutParams(scrollerLayout);
		topView.addView(clientView,p);
		
		tabs.setDrawFullUnderline(false);
		tabs.setTabIndicatorColor(Color.argb(255, 100, 100, 255));
		tabs.setBackgroundColor(Color.LTGRAY);
		tabs.setNonPrimaryAlpha(0.5f);
		tabs.setTextSpacing(1);
		tabs.setPadding(80, 10, 80, 10);
		tabs.setTextSize(TypedValue.COMPLEX_UNIT_DIP, 16);

/*
		SegmentedRadioGroup selector = new SegmentedRadioGroup(getContext());
		selector.setOrientation(LinearLayout.HORIZONTAL);
		
		LinearLayout.LayoutParams p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		int margin = (int)TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 16, getContentResources().getDisplayMetrics());
		p.setMargins(margin, margin, margin, margin);
		p.gravity = Gravity.CENTER_HORIZONTAL;
		topView.addView(selector, p);
		clientView = new ViewSwitcher(getContext());
		p = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.FILL_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
		p.weight = 1;
//		topView.addView(clientView,p);

		LinearLayout.LayoutParams scrollerLayout = new LinearLayout.LayoutParams(LayoutParams.FILL_PARENT,LayoutParams.WRAP_CONTENT);
		scrollerLayout.weight = 1;
		clientView.setLayoutParams(scrollerLayout);
		topView.addView(clientView);
		
		int i = 0;
		for (Content child : content.getChildren()) {
			selector.addOption(child.getDisplayName(), child, i++);
			ContentViewControllerBase cv = child.createInlineContentView(this,getContext());
			cv.setNavigator(this);
			addChildController(cv);

			ScrollView scroller = new ScrollView(getContext());
			scroller.setFillViewport(true);
			scroller.setBackgroundColor(0);
			scroller.setHorizontalScrollBarEnabled(false);
			scroller.setVerticalScrollBarEnabled(true);
			scroller.addView(cv.getView(),p);
			
			clientView.addView(scroller);
		}
		selector.setup();
		selector.check(0);
		
		selector.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
			public void onCheckedChanged(RadioGroup group, int checkedId) {
				((ViewSwitcher)clientView).setDisplayedChild(checkedId);
			}
		});
		*/
	}
}
