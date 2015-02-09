//
//  QuestionnaireParser.m
//  iStressLess
//


//

#include "QHandler.h"
#include "QAttributes.h"
#import "QuestionnaireParser.h"
#import <libxml/tree.h>

static void startElementSAX(void *ctx, const xmlChar * name, const xmlChar ** atts);
static void startElementSAXNs(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void endElementSAX(void * ctx, const xmlChar * name);
static void charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    startElementSAX,            /* startElement*/
    endElementSAX,              /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    NULL, //startElementSAXNs,            /* startElementNs */
    NULL, //endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

class QDictionaryAttributes : public QAttributes {
public:
	NSDictionary *dict;
	virtual const char *get(const char *name) {
		NSString *s = [dict objectForKey:[NSString stringWithUTF8String:name]];
		return [s UTF8String];
	}
};

class QLibXML2Attributes : public QAttributes {
	const xmlChar **attrs;
	//char *strings[64];
public:

	QLibXML2Attributes() {
		attrs = NULL;
/*
		for (int i=0;i<64;i++) {
			strings[i] = NULL;
		}
*/ 
	}
	
	~QLibXML2Attributes() {
		freeStrings();
	}

	void freeStrings() {
/*
		for (int i=0;i<64;i++) {
			if (strings[i] != NULL) {
				free(strings[i]);
				strings[i] = NULL;
			}
		}
*/
	}
	
	void setAttrs(const xmlChar **_attrs) {
		attrs = _attrs;
		freeStrings();
	}
	
	virtual const char *get(const char *name) {
		if (!attrs) return NULL;
		
		for (int i=0;attrs[i];i+=2) {
			const char *key = (const char*)attrs[i];
			if (!strcmp(name,key)) {
/*
				if (!strings[attrIndex]) {
					const char *value = (const char*)attrs[i+3];
					const char *valueEnd = (const char*)attrs[i+4];
					strings[attrIndex] = (char*)malloc(valueEnd - value + 1);
					strncpy(strings[attrIndex], value, valueEnd - value);
				}
				return strings[attrIndex];
*/ 
				const char *value = (const char*)attrs[i+1];
				return value;
			}
		}
		
		return NULL;
	}
};

@implementation QuestionnaireParser

@synthesize libXMLAttrs , attrs, handler;

- (id) init {
	handler = new QHandler();
	attrs = NULL;
	libXMLAttrs = NULL;
	return self;
}

- (void)parseData:(NSData*)data {
	xmlParserCtxtPtr context;
	context = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
	xmlParseChunk(context, (const char *)[data bytes], [data length], 1);
	xmlFreeParserCtxt(context);
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	if (!attrs) attrs = new QDictionaryAttributes();
	handler->startDocument();
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	attrs->dict = attributeDict;
	handler->startElement([elementName UTF8String], attrs);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	handler->endElement([elementName UTF8String]);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	const char *s = [string UTF8String];
	handler->characters(s, strlen(s));
}

@end


static void startElementSAX(void * ctx, 
							const xmlChar * name, 
							const xmlChar ** atts) {
    QuestionnaireParser *parser = (QuestionnaireParser *)ctx;
	if (!parser.libXMLAttrs) parser.libXMLAttrs = new QLibXML2Attributes();
	parser.libXMLAttrs->setAttrs(atts);
	NSLog(@"startElement %s",name);
	parser.handler->startElement((const char*)name, parser.libXMLAttrs);
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void endElementSAX(void *ctx, const xmlChar * name) {    
    QuestionnaireParser *parser = (QuestionnaireParser *)ctx;
//	NSLog(@"endElement %s",name);
	parser.handler->endElement((const char*)name);
}

/*
 This callback is invoked when the parser encounters character data inside a node. The parser class determines how to use the character data.
 */
static void charactersFoundSAX(void *ctx, const xmlChar *ch, int len) {
    QuestionnaireParser *parser = (QuestionnaireParser *)ctx;
	parser.handler->characters((const char*)ch, len);
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
static void errorEncounteredSAX(void *ctx, const char *msg, ...) {
    // Handle errors as appropriate for your application.
    NSCAssert(NO, @"Unhandled error encountered during SAX parse.");
}
