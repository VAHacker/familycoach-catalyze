package gov.va.contentlib.questionnaire;

import java.io.InputStream;

public interface QuestionnaireReader {

	public Questionnaire read(InputStream in);
	
}
