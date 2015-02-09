package gov.va.contentlib.controllers;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.EditText;
import android.widget.TextView;

import gov.va.contentlib.content.Content;

/**
 * Created by geh on 2/6/14.
 */
public class TextEntryController extends ContentViewController {

    String selectionVariable;
    EditText editText;

    public TextEntryController(Context c) {
        super(c);
    }

    @Override
    public void buildClientViewFromContent() {
        super.buildClientViewFromContent();

        Content c = getContent();
        Integer lines = c.getIntAttribute("lines");
        selectionVariable = c.getStringAttribute("selectionVariable");
        String exampleText = c.getStringAttribute("exampleText");

        editText = new EditText(getContext());
        editText.setMaxLines(lines != null ? lines : 3);
        if (exampleText != null) editText.setHint(exampleText);
        String startingText = getVariableAsString(selectionVariable);
        if (startingText != null) editText.setText(startingText);
        editText.addTextChangedListener(new TextWatcher() {
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                setVariable(selectionVariable, s.toString());
            }
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
            public void afterTextChanged(Editable s) {}
        });

        clientView.addView(editText);
    }

}
