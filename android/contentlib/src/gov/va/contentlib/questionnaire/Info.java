package gov.va.contentlib.questionnaire;

public class Info extends TextContainer {

	public Object evaluate(AbstractQuestionnairePlayer ctx) {
		ctx.addText(getText(ctx));
		return null;
	}
}
