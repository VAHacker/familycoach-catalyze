package gov.va.contentlib.util;

import android.app.Service;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.accessibility.AccessibilityNodeProvider;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by geh on 2/10/14.
 */
public class VirtualSubtree extends View {

    /** Temporary rectangle to minimize object creation. */
    private final Rect mTempRect = new Rect();

    /** Handle to the system accessibility service. */
    private final AccessibilityManager mAccessibilityManager;

    /** The virtual children of this View. */
    private final List<VirtualView> mChildren = new ArrayList<VirtualView>();

    /** The instance of the node provider for the virtual tree - lazily instantiated. */
    private AccessibilityNodeProvider mAccessibilityNodeProvider;

    /** The last hovered child used for event dispatching. */
    private VirtualView mLastHoveredChild;

    public VirtualSubtree(Context context, AttributeSet attrs) {
        super(context, attrs);
        mAccessibilityManager = (AccessibilityManager) context.getSystemService(
                Service.ACCESSIBILITY_SERVICE);
        createVirtualChildren();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public AccessibilityNodeProvider getAccessibilityNodeProvider() {
        // Instantiate the provide only when requested. Since the system
        // will call this method multiple times it is a good practice to
        // cache the provider instance.
        if (mAccessibilityNodeProvider == null) {
            mAccessibilityNodeProvider = new VirtualDescendantsProvider();
        }
        return mAccessibilityNodeProvider;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean dispatchHoverEvent(MotionEvent event) {
        // This implementation assumes that the virtual children
        // cannot overlap and are always visible. Do NOT use this
        // code as a reference of how to implement hover event
        // dispatch. Instead, refer to ViewGroup#dispatchHoverEvent.
        boolean handled = false;
        List<VirtualView> children = mChildren;
        final int childCount = children.size();
        for (int i = 0; i < childCount; i++) {
            VirtualView child = children.get(i);
            Rect childBounds = child.mBounds;
            final int childCoordsX = (int) event.getX() + getScrollX();
            final int childCoordsY = (int) event.getY() + getScrollY();
            if (!childBounds.contains(childCoordsX, childCoordsY)) {
                continue;
            }
            final int action = event.getAction();
            switch (action) {
                case MotionEvent.ACTION_HOVER_ENTER: {
                    mLastHoveredChild = child;
                    handled |= onHoverVirtualView(child, event);
                    event.setAction(action);
                } break;
                case MotionEvent.ACTION_HOVER_MOVE: {
                    if (child == mLastHoveredChild) {
                        handled |= onHoverVirtualView(child, event);
                        event.setAction(action);
                    } else {
                        MotionEvent eventNoHistory = event.getHistorySize() > 0
                                ? MotionEvent.obtainNoHistory(event) : event;
                        eventNoHistory.setAction(MotionEvent.ACTION_HOVER_EXIT);
                        onHoverVirtualView(mLastHoveredChild, eventNoHistory);
                        eventNoHistory.setAction(MotionEvent.ACTION_HOVER_ENTER);
                        onHoverVirtualView(child, eventNoHistory);
                        mLastHoveredChild = child;
                        eventNoHistory.setAction(MotionEvent.ACTION_HOVER_MOVE);
                        handled |= onHoverVirtualView(child, eventNoHistory);
                        if (eventNoHistory != event) {
                            eventNoHistory.recycle();
                        } else {
                            event.setAction(action);
                        }
                    }
                } break;
                case MotionEvent.ACTION_HOVER_EXIT: {
                    mLastHoveredChild = null;
                    handled |= onHoverVirtualView(child, event);
                    event.setAction(action);
                } break;
            }
        }
        if (!handled) {
            handled |= onHoverEvent(event);
        }
        return handled;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        // The virtual children are ordered horizontally next to
        // each other and take the entire space of this View.
        int offsetX = 0;
        List<VirtualView> children = mChildren;
        final int childCount = children.size();
        for (int i = 0; i < childCount; i++) {
            VirtualView child = children.get(i);
            Rect childBounds = child.mBounds;
            childBounds.set(offsetX, 0, offsetX + childBounds.width(), childBounds.height());
            offsetX += childBounds.width();
        }
    }

    /**
     * Creates the virtual children of this View.
     */
    private void createVirtualChildren() {
        // The virtual portion of the tree is one level deep. Note
        // that implementations can use any way of representing and
        // drawing virtual view.
        VirtualView firstChild = new VirtualView(0, new Rect(0, 0, 150, 150), "Virtual view 1");
        mChildren.add(firstChild);
        VirtualView secondChild = new VirtualView(1, new Rect(0, 0, 150, 150), "Virtual view 2");
        mChildren.add(secondChild);
        VirtualView thirdChild = new VirtualView(2, new Rect(0, 0, 150, 150), "Virtual view 3");
        mChildren.add(thirdChild);
    }

    /**
     * Handle a hover over a virtual view.
     *
     * @param virtualView The virtual view over which is hovered.
     * @param event The event to dispatch.
     * @return Whether the event was handled.
     */
    private boolean onHoverVirtualView(VirtualView virtualView, MotionEvent event) {
        // The implementation of hover event dispatch can be implemented
        // in any way that is found suitable. However, each virtual View
        // should fire a corresponding accessibility event whose source
        // is that virtual view. Accessibility services get the event source
        // as the entry point of the APIs for querying the window content.
        final int action = event.getAction();
        switch (action) {
            case MotionEvent.ACTION_HOVER_ENTER: {
                sendAccessibilityEventForVirtualView(virtualView,
                        AccessibilityEvent.TYPE_VIEW_HOVER_ENTER);
            } break;
            case MotionEvent.ACTION_HOVER_EXIT: {
                sendAccessibilityEventForVirtualView(virtualView,
                        AccessibilityEvent.TYPE_VIEW_HOVER_EXIT);
            } break;
        }
        return true;
    }

    /**
     * Sends a properly initialized accessibility event for a virtual view..
     *
     * @param virtualView The virtual view.
     * @param eventType The type of the event to send.
     */
    private void sendAccessibilityEventForVirtualView(VirtualView virtualView, int eventType) {
        // If touch exploration, i.e. the user gets feedback while touching
        // the screen, is enabled we fire accessibility events.
        if (mAccessibilityManager.isTouchExplorationEnabled()) {
            AccessibilityEvent event = AccessibilityEvent.obtain(eventType);
            event.setPackageName(getContext().getPackageName());
            event.setClassName(virtualView.getClass().getName());
            event.setSource(VirtualSubtree.this, virtualView.mId);
            event.getText().add(virtualView.mText);
            getParent().requestSendAccessibilityEvent(VirtualSubtree.this, event);
        }
    }

    /**
     * Finds a virtual view given its id.
     *
     * @param id The virtual view id.
     * @return The found virtual view.
     */
    private VirtualView findVirtualViewById(int id) {
        List<VirtualView> children = mChildren;
        final int childCount = children.size();
        for (int i = 0; i < childCount; i++) {
            VirtualView child = children.get(i);
            if (child.mId == id) {
                return child;
            }
        }
        return null;
    }

    /**
     * Represents a virtual View.
     */
    private class VirtualView {
        public final int mId;
        public final String mText;
        public final Rect mBounds;

        public VirtualView(int id, Rect bounds, String text) {
            mId = id;
            mBounds = bounds;
            mText = text;
        }
    }

    /**
     * This is the provider that exposes the virtual View tree to accessibility
     * services. From the perspective of an accessibility service the
     * {@link android.view.accessibility.AccessibilityNodeInfo}s it receives while exploring the sub-tree
     * rooted at this View will be the same as the ones it received while
     * exploring a View containing a sub-tree composed of real Views.
     */
    private class VirtualDescendantsProvider extends AccessibilityNodeProvider {

        /**
         * {@inheritDoc}
         */
        @Override
        public AccessibilityNodeInfo createAccessibilityNodeInfo(int virtualViewId) {
            AccessibilityNodeInfo info = null;
            if (virtualViewId == View.NO_ID) {
                // We are requested to create an AccessibilityNodeInfo describing
                // this View, i.e. the root of the virtual sub-tree. Note that the
                // host View has an AccessibilityNodeProvider which means that this
                // provider is responsible for creating the node info for that root.
                info = AccessibilityNodeInfo.obtain(VirtualSubtree.this);
                onInitializeAccessibilityNodeInfo(info);
                // Add the virtual children of the root View.
                List<VirtualView> children = mChildren;
                final int childCount = children.size();
                for (int i = 0; i < childCount; i++) {
                    VirtualView child = children.get(i);
                    info.addChild(VirtualSubtree.this, child.mId);
                }
            } else {
                // Find the view that corresponds to the given id.
                VirtualView virtualView = findVirtualViewById(virtualViewId);
                if (virtualView == null) {
                    return null;
                }
                // Obtain and initialize an AccessibilityNodeInfo with
                // information about the virtual view.
                info = AccessibilityNodeInfo.obtain();
                info.addAction(AccessibilityNodeInfo.ACTION_SELECT);
                info.addAction(AccessibilityNodeInfo.ACTION_CLEAR_SELECTION);
                info.setPackageName(getContext().getPackageName());
                info.setClassName(virtualView.getClass().getName());
                info.setSource(VirtualSubtree.this, virtualViewId);
                info.setBoundsInParent(virtualView.mBounds);
                info.setParent(VirtualSubtree.this);
                info.setText(virtualView.mText);
            }
            return info;
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public List<AccessibilityNodeInfo> findAccessibilityNodeInfosByText(String searched,
                                                                            int virtualViewId) {
            if (TextUtils.isEmpty(searched)) {
                return Collections.emptyList();
            }
            String searchedLowerCase = searched.toLowerCase();
            List<AccessibilityNodeInfo> result = null;
            if (virtualViewId == View.NO_ID) {
                // If the search is from the root, i.e. this View, go over the virtual
                // children and look for ones that contain the searched string since
                // this View does not contain text itself.
                List<VirtualView> children = mChildren;
                final int childCount = children.size();
                for (int i = 0; i < childCount; i++) {
                    VirtualView child = children.get(i);
                    String textToLowerCase = child.mText.toLowerCase();
                    if (textToLowerCase.contains(searchedLowerCase)) {
                        if (result == null) {
                            result = new ArrayList<AccessibilityNodeInfo>();
                        }
                        result.add(createAccessibilityNodeInfo(child.mId));
                    }
                }
            } else {
                // If the search is from a virtual view, find the view. Since the tree
                // is one level deep we add a node info for the child to the result if
                // the child contains the searched text.
                VirtualView virtualView = findVirtualViewById(virtualViewId);
                if (virtualView != null) {
                    String textToLowerCase = virtualView.mText.toLowerCase();
                    if (textToLowerCase.contains(searchedLowerCase)) {
                        result = new ArrayList<AccessibilityNodeInfo>();
                        result.add(createAccessibilityNodeInfo(virtualViewId));
                    }
                }
            }
            if (result == null) {
                return Collections.emptyList();
            }
            return result;
        }

        /**
         * {@inheritDoc}
         */
        @Override
        public boolean performAction(int virtualViewId, int action, Bundle arguments) {
            if (virtualViewId == View.NO_ID) {
                // Perform the action on the host View.
                switch (action) {
                    case AccessibilityNodeInfo.ACTION_SELECT:
                        if (!isSelected()) {
                            setSelected(true);
                            return isSelected();
                        }
                        break;
                    case AccessibilityNodeInfo.ACTION_CLEAR_SELECTION:
                        if (isSelected()) {
                            setSelected(false);
                            return !isSelected();
                        }
                        break;
                }
            } else {
                // Find the view that corresponds to the given id.
                VirtualView child = findVirtualViewById(virtualViewId);
                if (child == null) {
                    return false;
                }
                // Perform the action on a virtual view.
                switch (action) {
                    case AccessibilityNodeInfo.ACTION_SELECT:
                        //setVirtualViewSelected(child, true);
                        invalidate();
                        return true;
                    case AccessibilityNodeInfo.ACTION_CLEAR_SELECTION:
                        //setVirtualViewSelected(child, false);
                        invalidate();
                        return true;
                }
            }
            return false;
        }
    }
}
