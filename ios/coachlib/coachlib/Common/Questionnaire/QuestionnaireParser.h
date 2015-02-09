//
//  QuestionnaireParser.h
//  iStressLess
//


//

#import <Foundation/Foundation.h>
#import <Foundation/NSXMLParser.h>

class QHandler;
class QDictionaryAttributes;
class QLibXML2Attributes;

@interface QuestionnaireParser  : NSObject <NSXMLParserDelegate> {
	QHandler *handler;
	QDictionaryAttributes *attrs;
	QLibXML2Attributes *libXMLAttrs;
}

@property (nonatomic, assign) QHandler *handler;
@property (nonatomic, assign) QDictionaryAttributes *attrs;
@property (nonatomic, assign) QLibXML2Attributes *libXMLAttrs;

- (void)parseData:(NSData*)data;

- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@end
