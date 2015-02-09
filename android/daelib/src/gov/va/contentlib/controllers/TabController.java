package gov.va.contentlib.controllers;

import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;

import com.actionbarsherlock.app.ActionBar;
import com.actionbarsherlock.app.ActionBar.Tab;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.util.CalendarEventScheduler;
import gov.va.contentlib.util.EventScheduler;
import gov.va.daelib.R;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

public class TabController extends ContentViewControllerBase {

	static final private int TAB_STYLE_ACTIONBAR = 1;
	static final private int TAB_STYLE_TABHOST = 2;

	TabHost tabHost;
	ContentViewControllerBase currentController;
	TreeMap<String,ContentViewControllerBase> tabControllers = new TreeMap<String, ContentViewControllerBase>();
	
	List<Content> pendingNavigationPath = null;
    Object pendingNavigationData = null;
	int pendingNavigationStartingAt = -1;

	List<Content> children;
	ContentViewControllerBase[] controllers;
	ActionBarTabsImpl actionBarImpl = null;
	
	public TabController(Context ctx) {
		super(ctx);
	}
	
	@Override
	public boolean dispatchContentEvent(ContentEvent event) {
		if (event.eventType == ContentEvent.Type.GATHER_OPTIONS) {
			gatherOptions(event);
		}
		if (currentController == null) return false;
		boolean r = currentController.dispatchContentEvent(event);
		if (!r) r = super.dispatchContentEvent(event);
		return r;
	}
	
	@Override
	public boolean navigateToContentAtPathWithData(List<Content> path, int startingAt, Object data) {
		Content content = path.get(startingAt);
		long id = content.getID();
		if (tabHost != null) {
			tabHost.setCurrentTabByTag(""+id);
			if (startingAt+1 < path.size()) {
				return currentController.navigateToContentAtPathWithData(path, startingAt+1, data);
			}
		} else {
			return actionBarImpl.navigate(path,startingAt,data);
		}
//		if (startingAt+1 < path.size()) {
//			return currentController.navigateToContentAtPath(path, startingAt+1);
//		}
		return true;
	}

	@Override
	public void updateContentVisibilityForChild(ContentViewControllerBase child) {
		child.setContentVisible(isContentVisible() && (child == currentController));
	}
	
	class ActionBarTabsImpl {
		public boolean navigate(List<Content> path, int startingAt, Object data) {
			Content content = path.get(startingAt);
			long id = content.getID();
			ActionBar actionBar = getSherlockActivity().getSupportActionBar();
			for (int i=0;i<actionBar.getTabCount();i++) {
				Tab tab = actionBar.getTabAt(i);
				if (Long.valueOf(id).equals(tab.getTag())) {
					if (actionBar.getSelectedTab() == tab) {
						if (startingAt+1 < path.size()) {
							return currentController.navigateToContentAtPathWithData(path, startingAt+1, data);
						}
					} else {
						if (startingAt+1 < path.size()) {
							pendingNavigationPath = path;
                            pendingNavigationData = data;
							pendingNavigationStartingAt = startingAt+1;
						}
						actionBar.selectTab(tab);
					}
					break;
				}
			}
			
			return true;
		}
		
		public void addTabsToActionBar() {
			children = content.getChildren();
			controllers = new ContentViewControllerBase[children.size()];
			ArrayList<String> names = new ArrayList<String>();
			ActionBar actionBar = getSherlockActivity().getSupportActionBar();
			int i=0;
			for (final Content child : children) {
				names.add(child.getDisplayName());
				final int index = i;
				Tab tab = actionBar.newTab()
						.setText(child.getDisplayName())
						.setTag(child.getID())
						.setTabListener(new ActionBar.TabListener() {

							@Override
							public void onTabUnselected(Tab tab, FragmentTransaction ft) {
								ContentViewControllerBase fragment = controllers[index];
                                tab.setContentDescription(child.getDisplayName());
								//ft.detach(fragment);
							}

							@Override
							public void onTabSelected(Tab tab, FragmentTransaction ft) {
								ContentViewControllerBase fragment = controllers[index];
								if (fragment == null) {
									fragment = child.createContentView(TabController.this,getContext());
									addChildController(fragment);
									controllers[index] = fragment;
									//								ft.add(getView().getId(), fragment, ""+child.getID());
								} else {
									//								ft.attach(fragment);
								}
								swapInChildController(rootView, fragment);
                                tab.setContentDescription(child.getDisplayName()+" selected");
								currentController = fragment;
								updateChildContentVisibility();
								if (pendingNavigationPath != null) { 
									currentController.navigateToContentAtPathWithData(pendingNavigationPath, pendingNavigationStartingAt, pendingNavigationData);
									pendingNavigationPath = null;
                                    pendingNavigationData = null;
									pendingNavigationStartingAt = -1;
								}								
							}

							@Override
							public void onTabReselected(Tab tab, FragmentTransaction ft) {
								List<Content> path = new ArrayList<Content>();
                                tab.setContentDescription(child.getDisplayName()+" selected");
								if (currentController instanceof NavController) {
									NavController nc = (NavController)currentController;
									path.add(nc.root);
									currentController.navigateToContentAtPath(path, 0);
								}
							}
						});
				actionBar.addTab(tab);
				i++;
			}
			ArrayAdapter<String> adapter = new ArrayAdapter<String>(actionBar.getThemedContext(), R.layout.sherlock_spinner_item, names);
			adapter.setDropDownViewResource(R.layout.sherlock_spinner_dropdown_item);

			controllers[0] = children.get(0).createContentView(TabController.this,getContext());
			addChildController(controllers[0]);
			swapInChildController(rootView, controllers[0]);
			
			actionBar.setListNavigationCallbacks(adapter, new ActionBar.OnNavigationListener() {
				@Override
				public boolean onNavigationItemSelected(int itemPosition, long itemId) {
					ContentViewControllerBase fragment = controllers[itemPosition];
					if (fragment == null) {
						fragment = children.get(itemPosition).createContentView(TabController.this,getContext());
						addChildController(fragment);
						controllers[itemPosition] = fragment;
						//					ft.add(getView().getId(), fragment, ""+child.getID());
					} else {
						//					ft.attach(fragment);
					}
					swapInChildController(rootView, fragment);
					return true;
				}
			});
			actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
			//actionBar.selectTab(actionBar.getTabAt(0));
		}
		
		public void show() {
			ActionBar actionBar = getSherlockActivity().getSupportActionBar();
			actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
		}

		public void hide() {
			ActionBar actionBar = getSherlockActivity().getSupportActionBar();
			actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
		}
		
		public boolean shouldUse() {
			ActionBar actionBar = getSherlockActivity().getSupportActionBar();
			if ((actionBar != null) && (actionBar.getTabCount() == 0)) {
				return true;
			}
			return false;
		}
	}
	
	public void onContentBecameVisibleForFirstTime() {
		if (!isTopTabController()) {
			int count = tabHost.getTabWidget().getChildCount();
			for (int i=0;i<count;i++) {
				View v = tabHost.getTabWidget().getChildAt(i);
				v.getLayoutParams().height = v.getLayoutParams().height/2;
			}
			tabHost.getTabWidget().requestLayout();
			tabHost.requestLayout();
		}
	}
	
	public void onContentBecameVisible() {
		super.onContentBecameVisible();
		if (actionBarImpl != null) actionBarImpl.show();
	}

	public void onContentBecameInvisible() {
		super.onContentBecameInvisible();
		if (actionBarImpl != null) actionBarImpl.hide();
	}

	public boolean isTopTabController() {
		ContentViewControllerBase parent = this.getNavigator();
		while (parent != null) {
			if (parent instanceof TabController) {
				return false;
			}
			parent = parent.getNavigator();
		}
		
		return true;
	}
	
	@Override
	public void build() {
		final int sdkVersion = Build.VERSION.SDK_INT;
		
		int tabStyle = getIntAttr(R.attr.contentTabStyle);
		if ((tabStyle == TAB_STYLE_ACTIONBAR) && (sdkVersion >= Build.VERSION_CODES.HONEYCOMB)) {
			ActionBarTabsImpl a = new ActionBarTabsImpl();
			if (a.shouldUse()) {
				actionBarImpl = a;
				actionBarImpl.addTabsToActionBar();
				return;
			}
		}
		
		LayoutInflater inflator = LayoutInflater.from(getContext());
		tabHost = (TabHost)inflator.inflate(R.layout.tabhost, null);

		TabHost.TabContentFactory tabFactory = new TabHost.TabContentFactory() {
			@Override
			public View createTabContent(String tag) {
				Content child = db.getContentForID(Long.parseLong(tag));
				ContentViewControllerBase cvc = child.createContentView(TabController.this,getContext());
				tabControllers.put(tag,cvc);
				currentController = cvc;
				addChildController(cvc);
				return cvc.getView();
			}
		};

		tabHost.setup();
		
		for (Content child : content.getChildren()) {
			TabSpec tab = tabHost.newTabSpec(""+child.getID());
			tab.setContent(tabFactory);
			Drawable icon = child.getIcon();
			tab.setIndicator(child.getDisplayName(), icon);
			tabHost.addTab(tab);
		}

		tabHost.setOnTabChangedListener(new TabHost.OnTabChangeListener() {
			public void onTabChanged(String tabId) {
				currentController = tabControllers.get(tabId);
				updateChildContentVisibility();
				if (pendingNavigationPath != null) { 
					currentController.navigateToContentAtPathWithData(pendingNavigationPath, pendingNavigationStartingAt, pendingNavigationData);
					pendingNavigationPath = null;
                    pendingNavigationData = null;
					pendingNavigationStartingAt = -1;
				}								
			}
		});

		getView().addView(tabHost);
	}

}
