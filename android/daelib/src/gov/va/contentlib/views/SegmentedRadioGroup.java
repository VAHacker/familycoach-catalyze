/*
 * Copyright (C) 2011 Make Ramen, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package gov.va.contentlib.views;

import gov.va.contentlib.content.Content;
import gov.va.daelib.R;
import android.content.Context;
import android.content.res.Resources;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.RadioButton;
import android.widget.RadioGroup;

public class SegmentedRadioGroup extends RadioGroup {

	public SegmentedRadioGroup(Context context) {
		super(context);
        setOrientation(HORIZONTAL);
	}

	public SegmentedRadioGroup(Context context, AttributeSet attrs) {
		super(context, attrs);
        setOrientation(HORIZONTAL);
	}

	@Override
	protected void onFinishInflate() {
		super.onFinishInflate();
		setup();
	}

	public void addOption(String label, Object tag, int id) {
		LayoutInflater inflator = LayoutInflater.from(getContext());
		View v = inflator.inflate(gov.va.daelib.R.layout.minimal_radio_button, this, false);
		RadioButton option = (RadioButton)v;
		option.setText(label);
		option.setTag(tag);
		option.setId(id);
		addView(option);
	}
	
	public void setup(){
		int count = super.getChildCount();

		if(count > 1){
			super.getChildAt(0).setBackgroundResource(R.drawable.segment_radio_left);
			for(int i=1; i < count-1; i++){
				super.getChildAt(i).setBackgroundResource(R.drawable.segment_radio_middle);
			}
			super.getChildAt(count-1).setBackgroundResource(R.drawable.segment_radio_right);
		} else if (count == 1){
			super.getChildAt(0).setBackgroundResource(R.drawable.segment_button);
		}
		
		float maxWidth = 0;
		for(int i=0; i < count; i++) {
			View v = super.getChildAt(i);
			RadioButton b = (RadioButton)v;
			float width = b.getPaint().measureText(""+b.getText());
			if (width > maxWidth) maxWidth = width;
		}
		
		float margin = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 10, getResources().getDisplayMetrics());
		
		for(int i=0; i < count; i++) {
			View v = super.getChildAt(i);
			v.setMinimumWidth((int)(maxWidth+margin*2));
		}
		
		View v = super.getChildAt(0);
		RadioButton b = (RadioButton)v;
//		b.setChecked(true);
	}
}