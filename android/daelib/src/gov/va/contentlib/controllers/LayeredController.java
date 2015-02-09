package gov.va.contentlib.controllers;

import java.util.List;

import gov.va.contentlib.Util;
import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.ContentActivity;
import gov.va.daelib.R;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.v4.app.FragmentTransaction;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TabHost;
import android.widget.TabHost.TabSpec;

public class LayeredController extends ContentViewControllerBase {

	ContentViewControllerBase topController = null;
	
	public LayeredController(Context ctx) {
		super(ctx);
	}

	public boolean dispatchContentEvent(ContentEvent event) {
		if (event.eventType == ContentEvent.Type.GATHER_OPTIONS) {
			gatherOptions(event);
		}
		if (topController != null) return topController.dispatchContentEvent(event);
		return false;
	}

	public boolean navigateToChildControllerWithData(ContentViewControllerBase cvc, Object data) {
		topController = cvc;
		swapInChildController(rootView, cvc);
		updateChildContentVisibility();
		return true;
	}
		
	public boolean navigateToContentAtPathWithData(List<Content> path, int startingFrom, Object data) {
		Content target = path.get(startingFrom);

		if (topController != null) {
			if (target.equals(topController.getContent())) {
				if (path.size() > startingFrom+1) {
					return topController.navigateToContentAtPathWithData(path, startingFrom+1, data);
				}
				return true;
			}
		}

		for (ContentViewControllerBase cvc : getChildControllers()) {
			if (target.equals(cvc.getContent())) {
				boolean r = navigateToChildControllerWithData(cvc,data);
				if (!r) return r;
				if (path.size() > startingFrom+1) {
					return cvc.navigateToContentAtPathWithData(path, startingFrom+1, data);
				}
				return r;
			}
		}
		
		for (Content child : content.getChildren()) {
			if (child.equals(target)) {
				String style = child.getStringAttribute("layerStyle");
				if ((style != null) && style.equals("modal")) {
					startContentActivity(child);
					return true;
				}
/*
				ContentViewControllerBase cvc = child.createContentView(getContext());
				childControllers.remove(topController);
				childControllers.add(cvc);
				cvc.setNavigator(this);
				navigateToChildController(childControllers.get(0));
				return true;
*/
				return false;
			}
		}
		
		return false;
	}

	public void updateContentVisibilityForChild(ContentViewControllerBase child) {
		child.setContentVisible(isContentVisible() && (child == topController));
	}

	@Override
	public void build() {
		for (Content child : content.getChildren()) {
			String style = child.getStringAttribute("layerStyle");
			String predicate = child.getStringAttribute("predicate");
			if (predicate != null) {
				boolean result = evalJavascriptPredicate(predicate);
				if (!result) continue;
			}
			if ((style != null) && style.equals("modal")) continue;
			ContentViewControllerBase cvc = child.createContentView(this,getContext());
			addChildController(cvc);
		}
		
		navigateToChildController(getChildControllers().get(0));
	}

}
