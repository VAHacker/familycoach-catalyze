package gov.va.contentlib.controllers;

import android.content.Context;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;

import com.actionbarsherlock.view.MenuItem;

import java.util.Map;

import gov.va.contentlib.content.Content;
import gov.va.contentlib.content.Record;

/**
 * Created by geh on 2/6/14.
 */
public class FormController extends ContentViewController {

    Record record;
    String onSave;

    public FormController(Context c) {
        super(c);
    }

    public Record getBinding() {
        return record;
    }

    public void saveAndBackUp() {
        if ((onSave != null) && evalJavascriptPredicate(onSave)) return;
        copyValuesOut();
        record.save();
        goBack();
    }

    public boolean dispatchContentEvent(ContentEvent event) {
        if (event.eventType == ContentEvent.Type.BACK_BUTTON) {
            if (record != null) {
                copyValuesOut();
                record.revert();
            }
            return super.dispatchContentEvent(event);
        }

        return super.dispatchContentEvent(event);
    }

    public boolean gatherOptions(ContentEvent event) {
        if (event.menu != null) {
            android.view.MenuItem item = event.menu.add("Save");
            item.setOnMenuItemClickListener(new android.view.MenuItem.OnMenuItemClickListener() {
                public boolean onMenuItemClick(android.view.MenuItem item) {
                    saveAndBackUp();
                    return true;
                }
            });
            event.booleanResult = true;
        } else {
            MenuItem item = event.sherlockMenu.add("Save");
            item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                public boolean onMenuItemClick(MenuItem item) {
                    saveAndBackUp();
                    return true;
                }
            });
            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
            event.booleanResult = true;
        }
        return false;
    }

    @Override
    public void buildClientViewFromContent() {
        onSave = getContent().getStringAttribute("onsave");
        record = (Record)getVariable("@binding");
        if (record != null) copyValuesIn();
        super.buildClientViewFromContent();
    }

    public void copyValuesIn() {
        for (Map.Entry<String,Object> entry : record.entrySet()) {
            setLocalVariable(entry.getKey(), entry.getValue());
        }
    }

    public void copyValuesOut() {
        Map<String,Object> vars = getLocalVariables();
        for (Map.Entry<String,Object> entry : record.entrySet()) {
            String key = entry.getKey();
            if (vars.containsKey(key)) {
                entry.setValue(vars.get(key));
            }
        }
    }

    @Override
    public void setVariable(String name, Object value) {
        setLocalVariable(name, value);
    }

    @Override
    public Object getVariable(String name) {
        return super.getVariable(name);
    }

    @Override
    public boolean navigateToNext(ContentViewControllerBase next, boolean removeOld) {
        boolean r = super.navigateToNext(next, removeOld);
        if (r) {
            next.setNavigator(this);
        }
        return r;
    }

    public boolean navigateToNextFrom(ContentViewControllerBase next, ContentViewControllerBase from, boolean removeOriginal) {
        boolean r = super.navigateToNextFrom(next, from, removeOriginal);
        if (r) {
            next.setNavigator(this);
        }
        return r;
    }

}
