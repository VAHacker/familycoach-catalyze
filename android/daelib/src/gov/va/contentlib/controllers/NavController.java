package gov.va.contentlib.controllers;

import gov.va.contentlib.animation.DisplayNextView;
import gov.va.contentlib.animation.Flip3DAnimation;
import gov.va.contentlib.content.Content;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.animation.AccelerateDecelerateInterpolator;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.animation.DecelerateInterpolator;
import android.view.animation.TranslateAnimation;
import android.widget.FrameLayout;
import android.widget.ViewAnimator;

import com.openmhealth.ohmage.campaigns.va.ptsd_explorer.ContentObjectSelectedEvent;
import com.openmhealth.ohmage.core.EventLog;

public class NavController extends ContentViewControllerBase {

	protected FrameLayout topView;
	protected Content root;
	protected ContentViewControllerBase currentView;
	protected ContentViewControllerBase oldView;
	protected ArrayList<ContentViewControllerBase> stack = new ArrayList<ContentViewControllerBase>();

	public NavController(Context ctx) {
		super(ctx);
	}

	public void setRoot(Content c) {
		root = c;
		build();
	}
	
	@Override
	public void build() {
		topView = new FrameLayout(getContext());
		topView.setBackgroundColor(0);
		topView.setBackgroundDrawable(null);
		topView.setId(allocDynamicViewID());
		rootView.addView(topView);

		if (stack.size() == 0) {
			if (root == null) {
				if (getContent() != null) {
					root = getContent().getChildren().get(0);
				}
			}

			if ((root != null) && shouldUseFirstChildAsRoot()) {
				ContentViewControllerBase cv = root.createRealContentView(this,getContext());
				cv.setNavigator(this);
				stack.add(cv);
				addChildControllerView(topView, cv);
				addChildController(cv);
			}
		} else {
			addChildControllerView(topView, stack.get(0));
			addChildController(stack.get(0));
		}
	}

	public boolean performActionFromChild(String action, Content source, ContentViewControllerBase fromChild) {
		int index = stack.indexOf(fromChild);
		while (index >= 1) {
			index--;
			ContentViewControllerBase child = stack.get(index);
			if (child.tryPerformAction(action, source)) {
				return true;
			}
		}
		
		if (tryPerformAction(action, source)) return true;
		
		if (getNavigator() != null) {
			return getNavigator().performActionFromChild(action, source, this);
		}
		
		return false;
	}
	
	public boolean shouldUseFirstChildAsRoot() {
		return true;
	}
	
	private Animation inFromRightAnimation() {
		Animation inFromRight = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT,  +1.0f, Animation.RELATIVE_TO_PARENT,  0.0f,
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,   0.0f
		);
		inFromRight.setDuration(300);
		inFromRight.setInterpolator(new AccelerateDecelerateInterpolator());
		return inFromRight;
	}
	
	private Animation outToLeftAnimation() {
		Animation outtoLeft = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,  -1.0f,
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,   0.0f
		);
		outtoLeft.setDuration(300);
		outtoLeft.setInterpolator(new AccelerateDecelerateInterpolator());
		return outtoLeft;
	}
	
	private Animation inFromLeftAnimation() {
		Animation inFromLeft = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT,  -1.0f, Animation.RELATIVE_TO_PARENT,  0.0f,
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,   0.0f
		);
		inFromLeft.setDuration(300);
		inFromLeft.setInterpolator(new AccelerateDecelerateInterpolator());
		return inFromLeft;
	}

	private Animation outToRightAnimation() {
		Animation outtoRight = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,  +1.0f,
				Animation.RELATIVE_TO_PARENT,  0.0f, Animation.RELATIVE_TO_PARENT,   0.0f
		);
		outtoRight.setDuration(300);
		outtoRight.setInterpolator(new AccelerateDecelerateInterpolator());
		return outtoRight;
	}

	public void flipReplaceViewForContent(Content c) {
		flipReplaceViewForContent(c,stack.size()-1);
	}

	public void flipReplaceViewForContent(Content c, int toKeep) {
		ContentViewControllerBase cv = c.createRealContentView(this,getContext());
		flipReplaceView(cv,toKeep);
	}

	public void flipReplaceView(ContentViewControllerBase cv) {
		flipReplaceView(cv,stack.size()-1);
	}

    @Override
    public void setVariable(String name, Object value) {
        setLocalVariable(name, value);
    }

    public void flipReplaceView(ContentViewControllerBase cv, int toKeep) {
		cv.setNavigator(this);
		oldView = removeChildController(stack.remove(stack.size()-1));
		if (oldView instanceof ContentViewControllerBase) {
			ContentViewControllerBase cvcb = (ContentViewControllerBase)oldView;
			cvcb.blockInput();
		}
		while (stack.size() > toKeep) {
			removeChildController(stack.remove(stack.size()-1));
		}
		stack.add(cv);
//		topView.addView(cv.getView());
		addChildControllerView(topView, cv);
		addChildController(cv);
		currentView = cv;
		currentView.unblockInput();
		
		if (true) {
			oldView.getView().setVisibility(View.VISIBLE);
			currentView.getView().setVisibility(View.VISIBLE);
		} else {
			oldView.getView().setVisibility(View.INVISIBLE);
			currentView.getView().setVisibility(View.VISIBLE);
		}
		
		updateChildContentVisibility();
		
		ContentViewControllerBase.OnViewReadyListener listener = new ContentViewControllerBase.OnViewReadyListener() {
			@Override
			public void onViewReady() {
				final float centerX = oldView.getView().getWidth() / 2.0f;
				final float centerY = oldView.getView().getHeight() / 2.0f;
/*
				Animation keepItOffscreen = new TranslateAnimation(
						Animation.RELATIVE_TO_PARENT,  +1.0f, Animation.RELATIVE_TO_PARENT,  1.0f,
						Animation.RELATIVE_TO_PARENT,  +1.0f, Animation.RELATIVE_TO_PARENT,  1.0f
				);
				keepItOffscreen.setDuration(0);
				keepItOffscreen.setFillAfter(true);
				keepItOffscreen.setFillBefore(true);
				keepItOffscreen.setFillEnabled(true);
				currentView.getView().setVisibility(View.VISIBLE);
				currentView.getView().startAnimation(keepItOffscreen);
*/				
				Flip3DAnimation rotation = new Flip3DAnimation(0, 90, centerX, centerY);
				rotation.setDuration(250);
				rotation.setFillAfter(true);
				rotation.setInterpolator(new AccelerateInterpolator());
				oldView.getView().startAnimation(rotation);

				rotation = new Flip3DAnimation(-90, 0, centerX, centerY);
				rotation.setDuration(250);
				rotation.setStartOffset(250);
				rotation.setFillBefore(true);
				rotation.setFillAfter(true);
				rotation.setInterpolator(new DecelerateInterpolator());
				rotation.setAnimationListener(new Animation.AnimationListener() {
					public void onAnimationStart(Animation animation) {}
					public void onAnimationRepeat(Animation animation) {}
					public void onAnimationEnd(Animation animation) {
						topView.removeView(oldView.getView());
						currentView.getView().requestFocus();
					}
				});
				currentView.getView().startAnimation(rotation);
			}
		};
		
		if (currentView instanceof ContentViewControllerBase) {
			ContentViewControllerBase cvc = (ContentViewControllerBase)currentView;
			cvc.setOnViewReadyListener(listener);
		} else {
			listener.onViewReady();
		}
	}

	public void pushReplaceViewForContent(Content c) {
		ContentViewControllerBase cv = c.createRealContentView(this,getContext());
		pushView(cv,true);
	}

	public void pushViewForContent(Content c) {
		ContentViewControllerBase cv = c.createRealContentView(this,getContext());
		pushView(cv,false);
	}

	public void pushReplaceView(ContentViewControllerBase cv) {
		pushView(cv, true);
	}

	public void pushView(ContentViewControllerBase cv) {
		pushView(cv, false);
	}

	public void pushView(ContentViewControllerBase cv, boolean removeOld) {
		pushView(cv, removeOld ? stack.size()-1 : stack.size(), true, null);
	}

	public void pushView(ContentViewControllerBase cv, int toRemain, final boolean animated, final Runnable onCompletion) {
		cv.setNavigator(this);

		if (cv.isHeadless()) {
			cv.exec();
			return;
		}
		
		if (stack.size() == 0) {
			stack.add(cv);
			addChildControllerView(topView, cv);
			addChildController(cv);
			currentView = cv;
			if (onCompletion != null) onCompletion.run();
			return;
		}
		oldView = stack.get(stack.size()-1);
		if (oldView instanceof ContentViewControllerBase) {
			ContentViewControllerBase cvcb = (ContentViewControllerBase)oldView;
			cvcb.blockInput();
		}
		while (stack.size() > toRemain) {
			removeChildController(stack.remove(stack.size()-1));
		}
		stack.add(cv);
		addChildControllerView(topView, cv);
//		topView.addView(cv.getView());
		addChildController(cv);
		currentView = cv;
		currentView.unblockInput();
				
		if (animated) {
			oldView.getView().setVisibility(View.VISIBLE);
			
			Animation keepItOffscreen = new TranslateAnimation(
					Animation.RELATIVE_TO_PARENT,  +1.0f, Animation.RELATIVE_TO_PARENT,  0.0f,
					Animation.RELATIVE_TO_PARENT,  +1.0f, Animation.RELATIVE_TO_PARENT,   0.0f
			);
			keepItOffscreen.setDuration(0);
			keepItOffscreen.setFillAfter(true);
			keepItOffscreen.setFillBefore(true);
			keepItOffscreen.setFillEnabled(true);
			currentView.getView().startAnimation(keepItOffscreen);
			currentView.getView().setVisibility(View.VISIBLE);
		} else {
			oldView.getView().setVisibility(View.INVISIBLE);
			currentView.getView().setVisibility(View.VISIBLE);
		}
//		oldView.setDrawingCacheEnabled(true);
//		currentView.setDrawingCacheEnabled(true);
		
		incrementContentLoadingCount();

		updateChildContentVisibility();

		ContentViewControllerBase.OnViewReadyListener listener = new ContentViewControllerBase.OnViewReadyListener() {
			@Override
			public void onViewReady() {				
				if (animated) {
					Animation in = inFromRightAnimation();
					Animation out = outToLeftAnimation();
					out.setAnimationListener(new Animation.AnimationListener() {
						public void onAnimationStart(Animation animation) {}
						public void onAnimationRepeat(Animation animation) {}
						public void onAnimationEnd(Animation animation) {
							topView.post(new Runnable() {
								@Override
								public void run() {
									//								oldView.setDrawingCacheEnabled(false);
									//								currentView.setDrawingCacheEnabled(false);
									removeChildControllerView(oldView);
//									topView.removeView(oldView.getView());
									oldView = null;
									currentView.getView().setAnimation(null);
									viewLoaded();
									if (onCompletion != null) onCompletion.run();
								}
							});
						}
					});

					in.setFillAfter(true);
					in.setFillBefore(true);
					in.setFillEnabled(true);
					out.setFillAfter(true);
					out.setFillBefore(true);
					out.setFillEnabled(true);

					if (oldView != null) {
						oldView.getView().invalidate();
						//					oldView.buildDrawingCache();
					}
					currentView.getView().invalidate();
					//				currentView.buildDrawingCache();

					long time = AnimationUtils.currentAnimationTimeMillis();

					in.setStartTime(Animation.START_ON_FIRST_FRAME);
					out.setStartTime(Animation.START_ON_FIRST_FRAME);

					if (oldView != null) {
						oldView.getView().setAnimation(out);
					}
					currentView.getView().setAnimation(in);
					topView.invalidate();
				} else {
					viewLoaded();
				}
			}
		};
		
		if (!animated) {
			removeChildControllerView(oldView);
		}
		currentView.setOnViewReadyListener(listener);
		
	}
	
	/*		
	public void goBack() {
		TopContentActivity a = (TopContentActivity)getParent();
		if (a != null) {
			a.getTabHost().setCurrentTab(0);
		} else {
			super.onBackPressed();
		}
	}
	
	@Override
	public void onBackPressed() {
		if (stack.size() < 2) {
			goBack();
			return;
		}

		popView();
	}
	*/

	public boolean popToContent(Content c, boolean immediate) {
		int i;
		for (i=0;i<stack.size();i++) {
			if (stack.get(i).getContent().equals(c)) break;
		}
		
		if (i == stack.size()) return false;

		oldView = getCurrentContentView();

		if (immediate) {
			while (stack.size()-1 > i) {
				removeChildController(stack.remove(stack.size()-1));
			}
			currentView = stack.get(stack.size()-1);
			topView.removeView(oldView.getView());
			topView.addView(currentView.getView());
			updateChildContentVisibility();
		} else {
			while (stack.size()-2 > i) {
				stack.remove(i+1);
			}
			popView();
		}

		return true;
	}

	public void popToRoot() {
		while (stack.size() > 2) {
			removeChildController(stack.remove(1));
		}
		popView();
	}

	public void popToRootImmediate() {
		while (stack.size() > 2) {
			removeChildController(stack.remove(1));
		}
		if (stack.size() <= 1) return;
		oldView = removeChildController(stack.remove(stack.size()-1));
		currentView = stack.get(stack.size()-1);
		topView.removeView(oldView.getView());
		topView.addView(currentView.getView());
		updateChildContentVisibility();
	}

	public void popView() {
		popView(null);
	}

	public void popView(final Runnable onCompletion) {
		popView(onCompletion,false);
	}

	public void popView(final Runnable onCompletion, boolean immediate) {
		if (stack.size() <= 1) return;
		oldView = removeChildController(stack.remove(stack.size()-1));
		currentView = stack.get(stack.size()-1);
		
		if (immediate) {
			topView.removeView(oldView.getView());
			topView.addView(currentView.getView());
			updateChildContentVisibility();
			return;
		}

		oldView.blockInput();
		addChildControllerView(topView, currentView);
		currentView.unblockInput();
		
		Animation keepItOffscreen = new TranslateAnimation(
				Animation.RELATIVE_TO_PARENT,  -1.0f, Animation.RELATIVE_TO_PARENT,  0.0f,
				Animation.RELATIVE_TO_PARENT,  -1.0f, Animation.RELATIVE_TO_PARENT,   0.0f
		);
		keepItOffscreen.setDuration(0);
		keepItOffscreen.setFillAfter(true);
		keepItOffscreen.setFillBefore(true);
		keepItOffscreen.setFillEnabled(true);
		currentView.getView().startAnimation(keepItOffscreen);
		currentView.getView().setVisibility(View.VISIBLE);
		
		incrementContentLoadingCount();

		updateChildContentVisibility();

		ContentViewControllerBase.OnViewReadyListener listener = new ContentViewControllerBase.OnViewReadyListener() {
			public void onViewReady() {
				Animation in = inFromLeftAnimation();
				Animation out = outToRightAnimation();
				out.setAnimationListener(new Animation.AnimationListener() {
					public void onAnimationStart(Animation animation) {}
					public void onAnimationRepeat(Animation animation) {}
					public void onAnimationEnd(Animation animation) {
						topView.post(new Runnable() {
							@Override
							public void run() {
								if (oldView != null) {
									removeChildControllerView(oldView);
									oldView = null;
								}
								currentView.getView().setAnimation(null);
								viewLoaded();
								if (onCompletion != null) onCompletion.run();
							}
						});
					}
				});

				long time = AnimationUtils.currentAnimationTimeMillis();
				in.setStartTime(time);
				out.setStartTime(time);

				in.setFillAfter(true);
				in.setFillBefore(true);
				in.setFillEnabled(true);
				out.setFillAfter(true);
				out.setFillBefore(true);
				out.setFillEnabled(true);

				oldView.getView().setAnimation(out);
				currentView.getView().setAnimation(in);
				oldView.getView().invalidate();
				currentView.getView().invalidate();
				topView.invalidate();
			}
		};
		
		currentView.setOnViewReadyListener(listener);
	}
	
	public ContentViewControllerBase getCurrentContentView() {
		if (stack.size() == 0) return null;
		return stack.get(stack.size()-1);
	}

	public Content getCurrentContent() {
		if (stack.size() == 0) return null;
		return stack.get(stack.size()-1).getContent();
	}

	public void buttonTapped(int id) {
		getCurrentContentView().handleButtonTap(id);
	}
/*
	public void contentSelected(Content c) {
		ContentObjectSelectedEvent e = new ContentObjectSelectedEvent();
		e.contentObjectId = c.getUniqueID();
		e.contentObjectName = c.getName();
		e.contentObjectDisplayName = c.getDisplayName();
		EventLog.log(e);
		
		pushViewForContent(c);
	}
*/	
	public boolean goBackFrom(ContentViewControllerBase cv, boolean immediate) {
		if (cv == stack.get(stack.size()-1)) {
            if (stack.size() == 1) {
                return super.goBackFrom(cv,immediate);
            }
			popView(null,immediate);
			return true;
		}

		return false;
	}
	
	@Override
	public void onContentBecameInvisible() {
		super.onContentBecameInvisible();
	}

	@Override
	public void onContentBecameVisible() {
		super.onContentBecameVisible();
	}

	@Override
	public void updateContentVisibilityForChild(ContentViewControllerBase child) {
		child.setContentVisible(isContentVisible() && (child == getCurrentContentView()));
	}
	
	public boolean navigateToNextFrom(ContentViewControllerBase next, ContentViewControllerBase from, boolean removeOriginal) {
		Content c = from.getContent();
		Content nextContent = null;
		if (next == null) {
			List<Content> children = getContent().getChildren();
			int index = children.indexOf(c);
			if (index > -1) {
				if (index == children.size()-1) {
					// last one?
					Log.d("dae","next from last child?");
				} else {
	                while (index < children.size()-1) {
	                	nextContent = children.get(index+1);
	                	String predicate =  nextContent.getStringAttribute("predicate");
	                	if (predicate != null) {
	                		if (!evalJavascriptPredicate(predicate)) {
	                			index++;
	                			nextContent = null;
	                			continue;
	                		}
	                	}
	                	break;
	                }
				}
			}
		} else {
			nextContent = next.getContent();
		}

		if (nextContent == null) {
	        if (content.getBoolean("rollover")) {
	        	popToRoot();
	            return true;
	        }
			if (getNavigator() != null) {
				getNavigator().navigateToNextFrom(next, this, false);
			} else {
				Log.d("dae","no next option");
			}
		} else {
			if (nextContent.getRef() != null) {
				contentSelected(nextContent);
				return true;
			}
			
			boolean removeOld = removeOriginal;
		    if (!removeOld) {
		    	Content topContent = getCurrentContent();
	            if (topContent.getBoolean("disableBackTo")) removeOld = true;
		    }
		    if (!removeOld) {
	            if (nextContent.getBoolean("disableBackFrom")) removeOld = true;
		    }

			if (next == null) next = nextContent.createRealContentView(this,getContext());
			next.setNavigator(this);
			if (next.isHeadless()) {
				next.exec();
			} else {
				popToContent(c,true);
				pushView(next, removeOld);
			}
		}
		return true;
	}

	@Override
	public boolean navigateToContentAtPathWithData(final List<Content> path, int startingAt, final Object data) {
		Content next = path.get(startingAt);
		int i = 0;
		int newStartingAt = startingAt;

		// See if it is already on the stack
		while ((i < stack.size()) && !next.equals(stack.get(i).getContent())) i++;

		if (i == stack.size()) {
			// We couldn't find it on the stack.
			List<Content> children = content.getChildren();
			if (children.contains(next)) {
				int stackSize=1;
				outer: for (Content child : children) {
					for (ContentViewControllerBase stacked : stack) {
						if (stacked.getContent().equals(child)) {
							stackSize = stack.indexOf(stacked)+2;
							continue outer;
						}
					}
					ContentViewControllerBase cv = child.createRealContentView(this, getContext());
					pushView(cv, stackSize++, false, null);
					if (child.equals(next)) break;
				}
				
				if (startingAt < path.size()-1) {
					getCurrentContentView().navigateToContentAtPathWithData(path, startingAt + 1, data);
				}
				return true;
			}
			
			return false;
		}

		while ((i < stack.size()) && next.equals(stack.get(i).getContent())) {
			i++;
			if (newStartingAt >= path.size()-1) {
				next = null;
				break;
			}
			newStartingAt++;
			next = path.get(newStartingAt);
		}
		
		if (newStartingAt >= path.size()-1) {
			newStartingAt = -1;
		} else {
			newStartingAt++;
		}

		final Content nextContent = next;
		final int nextIndex = newStartingAt;
		Runnable runnable = new Runnable() {
			public void run() {
				if (nextContent != null) {
					final ContentViewControllerBase cv = nextContent.createRealContentView(NavController.this,getContext());
					pushView(cv, stack.size(), true, new Runnable() {
						public void run() {
							if (nextIndex != -1) {
								cv.navigateToContentAtPathWithData(path, nextIndex, data);
							} else if (data != null) {
                                cv.navigationDataReceived(data);
                            }
						}
					});
				} else {
                    ContentViewControllerBase cv = stack.get(stack.size()-1);
					if (nextIndex != -1) {
						cv.navigateToContentAtPathWithData(path, nextIndex, data);
					} else if (data != null) {
                        cv.navigationDataReceived(data);
                    }
				}
			}
		};
		
		int targetStackSize = i;
		while (stack.size() > targetStackSize+1) {
			removeChildController(stack.remove(i));
		}
		if (stack.size() > targetStackSize) {
			popView(runnable);
		} else {
			runnable.run();
		}
		
		return true;
	}
	
	public boolean dispatchContentEvent(ContentEvent event) {
		if (event.eventType == ContentEvent.Type.BACK_BUTTON) {
			ContentViewControllerBase cv = getCurrentContentView();
			if (cv != null) {
				boolean r = cv.dispatchContentEvent(event);
				if (r) return true;
			}
			
			if (stack.size() <= 1) return false;
			popView();
			return true;
		}
		
		ContentViewControllerBase cv = getCurrentContentView();
		if (cv == null) return false;
		return cv.dispatchContentEvent(event);
	}

	public Object getVariableForChild(String name, ContentViewControllerBase from) {
		Object value = null;
		
		if (localVariables != null) {
			value = localVariables.get(name);
		}

        if (value != null) return value;
		
		int i = 0;
		if (from != null) i = stack.indexOf(from)-1;
		for (;i>=0;i--) {
			ContentViewControllerBase v = stack.get(i);
			Map<String,Object> locals = v.getLocalVariables();
			if (locals != null) {
				value = locals.get(name);
				if (value != null) break;
			}
		}
		
		if (value == null) {
			if (getNavigator() != null) {
				value = getNavigator().getVariable(name);
			} else {
				value = userDb.getSetting(name);
			}
		}

		return value;
	}

	public void getVariablesForChild(Map<String,Object> vars, ContentViewControllerBase from) {
		if (getNavigator() != null) {
			getNavigator().getVariables(vars);
		} else {
			userDb.getSettings(vars);
		}

		if (localVariables != null) vars.putAll(localVariables);

		for (ContentViewControllerBase v : stack) {
			if (v == from) break;
			Map<String,Object> locals = v.getLocalVariables();
			if (locals != null) vars.putAll(locals);
		}
	}

}
