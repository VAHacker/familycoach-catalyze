package gov.va.contentlib.questionnaire;

public class Choice extends TextContainer {
	private String value;
	
	public void setValue(String value) {
		this.value = value;
	}
	
	public String getValue() {
		return value;
	}
}