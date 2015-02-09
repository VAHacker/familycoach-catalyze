//
//  iStressLess_Desktop_AppDelegate.m
//  iStressLess Desktop
//


//

#import "ResourceParser.h"
#import <CommonCrypto/CommonDigest.h>
#import <libxml/HTMLtree.h>

static void startElementSAX(void *ctx, const xmlChar * name, const xmlChar ** atts);
static void endElementSAX(void *ctx, const xmlChar *name);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

#if 0
static xmlSAXHandler htmlHandlerStruct = {
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
    NULL,              /* endElement */
    NULL,                       /* reference */
    NULL,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    errorEncounteredSAX,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    NULL, //startElementSAXNs,            /* startElementNs */
    NULL, //endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};
#endif

@interface Reference : NSObject{
    NSManagedObject *from;
    NSRelationshipDescription *keyDesc;
    NSString *refs;
}

@property (nonatomic, retain) NSManagedObject *from;
@property (nonatomic, retain) NSRelationshipDescription *keyDesc;
@property (nonatomic, retain) NSString *refs;
@end

@implementation Reference
@synthesize from,keyDesc,refs;
@end

static NSMutableArray *references;
static NSMutableSet *_contentFiles;
static NSString *_contentSrcDir;

static void addFile(NSString *fn) {
    NSLog(@"addFile '%@'",fn);
    NSString *pathToContentRoot = _contentSrcDir;
    NSString *pathToDataFile = [pathToContentRoot stringByAppendingPathComponent:fn];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathToDataFile]) {
        NSLog(@"Cannot find file '%@'",fn);
        exit(-1);
    }
    
    [_contentFiles addObject:fn];
    if ([@"png" isEqual:[fn pathExtension]]) {
        NSString *twoxPng = [[[fn stringByDeletingPathExtension] stringByAppendingString:@"@2x"] stringByAppendingPathExtension:@"png"];
        pathToDataFile = [pathToContentRoot stringByAppendingPathComponent:twoxPng];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathToDataFile]) {
            [_contentFiles addObject:twoxPng];
        }
    }
}

static int indent = 0;

static void startElementSAX(void *ctx, const xmlChar * name, const xmlChar ** atts) {
    if (strcasecmp((const char*)name,"img") == 0) {
        const xmlChar **a = atts;
        while (*a) {
            const xmlChar *key = *a++;
            const xmlChar *value = *a++;
            if (strcasecmp((const char*)key,"src") == 0) {
                NSString *fn = [NSString stringWithUTF8String:(const char*)value];
                NSLog(@"addFile1 '%@'",fn);
                NSMutableArray *a = [NSMutableArray arrayWithArray:[fn pathComponents]];
                if ([[a objectAtIndex:0] isEqualToString:@"Content"]) [a removeObjectAtIndex:0];
                NSMutableString *fn2 = [NSMutableString string];
                BOOL first = TRUE;
                for (NSString *s in a) {
                    if (!first) {
                        [fn2 appendString:@"/"];
                    }
                    first = FALSE;
                    [fn2 appendString:s];
                }
                addFile(fn2);
            }
        }
    }
}

static void errorEncounteredSAX(void * ctx, const char * msg, ...) {
    NSLog(@"errorEncounteredSAX: %s",msg);
}

static void extractImagesFromNode(htmlNodePtr node) {
    if (node->type == XML_ELEMENT_NODE) {
        if (strcmp((const char*)node->name,"img") == 0) {
            xmlAttrPtr attr = node->properties;
            while (attr) {
                if (strcmp((const char*)attr->name,"src") == 0) {
                    NSString *fn = [NSString stringWithUTF8String:(const char*)attr->children->content];
                    NSLog(@"addFile1 '%@'",fn);
                    NSMutableArray *a = [NSMutableArray arrayWithArray:[fn pathComponents]];
                    if ([[a objectAtIndex:0] isEqualToString:@"Content"]) [a removeObjectAtIndex:0];
                    NSMutableString *fn2 = [NSMutableString string];
                    BOOL first = TRUE;
                    for (NSString *s in a) {
                        if (!first) {
                            [fn2 appendString:@"/"];
                        }
                        first = FALSE;
                        [fn2 appendString:s];
                    }
                    addFile(fn2);
                }
                attr = attr->next;
            }
        }
    }
    
    htmlNodePtr child = node->children;
    while (child) {
        extractImagesFromNode(child);
        child = child->next;
    }
}

static void extractImages(htmlDocPtr doc) {
    htmlNodePtr child = doc->children;
    while (child) {
        extractImagesFromNode(child);
        child = child->next;
    }
}

@implementation ResourceParser

@synthesize contentDstDir,contentSrcDir;

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error {
    NSLog(@"%@ %@",[error localizedDescription], error);
    exit(1);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
}

- (id)init {
	self = [super init];
	stack = [[NSMutableArray alloc] init];
    contentFiles = [[NSMutableSet alloc] init];
    _contentFiles = contentFiles;
    references = [[NSMutableArray array] retain];
	return self;
}

- (void)parseXMLFile:(NSString *)pathToFile {
    _contentSrcDir = contentSrcDir;
    
    NSURL *xmlURL = [NSURL fileURLWithPath:pathToFile];
    if (parser) [parser release];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:YES];
    [parser parse];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dstDir = [contentDstDir stringByAppendingPathExtension:@"tmp"];
    [fm removeItemAtPath:dstDir error:NULL];
    [fm createDirectoryAtPath:dstDir withIntermediateDirectories:TRUE attributes:NULL error:NULL];

    for (Reference *r in references) {
        NSString *key = r.keyDesc.name;
        NSEntityDescription *edesc = [r.keyDesc destinationEntity];
        NSString *destEntity = [edesc name];
        NSArray *aStrs = [r.refs componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableSet *a = [NSMutableSet setWithCapacity:[aStrs count]];
        for (int i=0;i<[aStrs count];i++) {
            NSString *name = [aStrs objectAtIndex:i];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",name];
            [request setEntity:[NSEntityDescription entityForName:destEntity inManagedObjectContext:managedObjectContext]];
            [request setPredicate:(NSPredicate *)predicate];
            NSArray *results = [managedObjectContext executeFetchRequest:request error:nil];
            if (results.count) {
                [a addObject:[results objectAtIndex:0]];
            } else {
                NSLog(@"Could not find item named '%@'",name);
                exit(1);
            }
            [request release];
        }
        
        if ([a count] == 0) {
            if ([destEntity isEqual:@"Blob"]) {
                NSManagedObject *newBlob = [self addEntity:@"Blob"];
                
                NSString *fn = [aStrs objectAtIndex:0];
                NSString *pathToContentRoot = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
                pathToContentRoot = [pathToContentRoot stringByDeletingLastPathComponent];
                NSString *pathToDataFile = [pathToContentRoot stringByAppendingPathComponent:fn];
                NSData *data = [NSData dataWithContentsOfFile:pathToDataFile];
                
                [newBlob setValue:fn forKey:@"name"];
                [newBlob setValue:data forKey:@"data"];
                [a addObject:newBlob];
            }
        }
        
        if ([r.keyDesc maxCount] == 1) {
            [r.from setValue:[a anyObject] forKey:key];
        } else {
            [r.from setValue:a forKey:key];
        }
    }
    
    for (NSString *fn in contentFiles) {
        NSString *srcPath = [_contentSrcDir stringByAppendingPathComponent:fn];
        NSString *dstPath = [dstDir stringByAppendingPathComponent:fn];
        NSString *dstDir = [dstPath stringByDeletingLastPathComponent];
        [fm createDirectoryAtPath:dstDir withIntermediateDirectories:TRUE attributes:nil error:NULL];
        if ([[dstPath pathExtension] isEqual:@"png"]) {
            NSTask *task;
            task = [[NSTask alloc] init];
            [task setLaunchPath: @"/usr/bin/xcrun"];
            [task setArguments: @[@"-sdk",@"iphoneos",@"pngcrush",@"-iphone",srcPath,dstPath]];
            [task launch];
            [task waitUntilExit];
            [task release];
        } else {
            [fm copyItemAtPath:srcPath toPath:dstPath error:NULL];
        }
    }
}

- (void)convertFile:(NSString*)xmlFilename into:(NSManagedObjectContext*)context {
	managedObjectContext = context;
	[self parseXMLFile:xmlFilename];
	[context commitEditing];
}

-(void) parserDidStartDocument:(NSXMLParser *)parser {
    NSManagedObjectContext *context = managedObjectContext;

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
//	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"true"];
	[request setEntity:[NSEntityDescription entityForName:@"Content" inManagedObjectContext:context]];
//	[request setPredicate:predicate];
	
	NSArray *a = [context executeFetchRequest:request error:nil];
	for (int i=0;i<a.count;i++) {
		NSManagedObject *mo = [a objectAtIndex:i];
		NSString *s = [mo valueForKey:@"name"];
		if (s) {
//			NSLog([NSString stringWithFormat:@"name = %@",s]);
		}
	}
	[request release];

	orderIndexStack[0] = 0;
	stackDepth = 0;

	[context reset];
}

-(NSManagedObject*) addEntity:(NSString*)entityName {
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    return newManagedObject;
}
    
-(void) addAttributeWithName:(NSString*)key andValue:(id)val toObject:(NSManagedObject*)o {
//	NSLog(@"attr: %@",key);
	if ([key isEqual:@"theme"]) {
//		NSLog(@"THEME");
	}
	NSAttributeDescription *desc = [[[o entity] attributesByName] objectForKey:key];
	if (desc) {
		NSAttributeType attrType = [desc attributeType];
		if (attrType == NSStringAttributeType) {
            if ([[desc.userInfo objectForKey:@"type"] isEqual:@"filename"]) {
                addFile(val);
			}
			[o setValue:val forKey:key];
		} else if (attrType <= NSInteger64AttributeType) {
            NSRange range = [val rangeOfString:@":"];
            if (range.location == NSNotFound) {
                [o setValue:[NSNumber numberWithInt:[val intValue]] forKey:key];
            } else {
                NSScanner *captionTimeScanner = [NSScanner scannerWithString:val];
                [captionTimeScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@" \n\t:"]];
                int minute,second;
                [captionTimeScanner scanInt:&minute];
                [captionTimeScanner scanInt:&second];
//                NSLog(@"converting time '%@' to %d:%d\n",val,minute,second);
                int ms = second * 1000 + minute * 60000;
                [o setValue:[NSNumber numberWithInt:ms] forKey:key];
            }
		} else if (attrType == NSFloatAttributeType) {
			[o setValue:[NSNumber numberWithFloat:[val floatValue]] forKey:key];
		} else if (attrType == NSDoubleAttributeType) {
			[o setValue:[NSNumber numberWithDouble:[val doubleValue]] forKey:key];
		} else if (attrType == NSBooleanAttributeType) {
			[o setValue:[NSNumber numberWithBool:[val boolValue]] forKey:key];
		} else if (attrType == NSDateAttributeType) {
			NSDate *date = [NSDate dateWithNaturalLanguageString:val];
			[o setValue:date forKey:key];
		} else if (attrType == NSBinaryDataAttributeType) {
			// load the file
			/*					NSString *fn = (NSString*)val;
			 
			 NSFetchRequest *request = [[NSFetchRequest alloc] init];
			 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",fn];
			 [request setEntity:[NSEntityDescription entityForName:@"Blob" inManagedObjectContext:context]];
			 [request setPredicate:(NSPredicate *)predicate];
			 NSArray *results = [context executeFetchRequest:request error:nil];
			 if (results.count) {
			 [o setValue:[results objectAtIndex:0] forKey:key];
			 } else {
			 NSManagedObject *newBlob = [self addEntity:@"Blob"];
			 
			 NSString *pathToContentRoot = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
			 pathToContentRoot = [pathToContentRoot stringByDeletingLastPathComponent];
			 NSString *pathToDataFile = [pathToContentRoot stringByAppendingPathComponent:fn];
			 NSData *data = [NSData dataWithContentsOfFile:pathToDataFile];
			 
			 [newBlob setValue:fn forKey:@"name"];
			 [newBlob setValue:data forKey:@"data"];
			 [o setValue:newBlob forKey:key];
			 }
			 */
		} else {
		}
	} else {
		NSRelationshipDescription *rdesc = [[[o entity] relationshipsByName] objectForKey:key];
		if (rdesc) {
            Reference *ref = [[Reference alloc] init];
            ref.from = o;
            ref.keyDesc = rdesc;
            ref.refs = val;
            [references addObject:ref];
            [ref release];
		} else {
//			NSLog([NSString stringWithFormat:@"Unknown field '%@', adding to 'extras'",key]);
			NSMutableDictionary *extras = [o valueForKey:@"extras"];
            if (!extras) extras = [NSMutableDictionary dictionaryWithCapacity:1];
			[extras setValue:val forKey:key];
			[o setValue:extras forKey:@"extras"];
            BOOL hasFileSuffix = [key hasSuffix:@"_file"];
            if (hasFileSuffix) {
                addFile(val);
            }

		}
	}
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    NSMutableString *str = [NSMutableString string];
    for (int i=0;i<indent;i++) [str appendString:@"    "];
    [str appendFormat:@"%@-%@-%@",
        elementName,
        [attributeDict objectForKey:@"name"] ? [attributeDict objectForKey:@"name"] : @"nil",
        [attributeDict objectForKey:@"displayName"] ? [attributeDict objectForKey:@"displayName"] : @"nil"];
    indent++;
    NSLog(@"%@",str);

    // If appropriate, configure the new managed object.
	if ([elementName isEqual:@"iStressLess"]) {
	} else {

        NSString *name=[attributeDict objectForKey:@"name"];
        if ([name isEqualToString:@"learn"]) {
//            NSLog(@"LEARN");
        }
//		NSLog(@"%d:%@(%@,'%@')",c,elementName,[attributeDict objectForKey:@"name"],[attributeDict objectForKey:@"displayName"]);
		
		NSManagedObject *o = [self addEntity:elementName];
		
		if (stack.count) {
			NSMutableDictionary *dict = [stack lastObject];
			NSManagedObject *parent = [dict objectForKey:@"_"];
			[o setValue:parent forKey:@"parent"];
			if ([parent.entity.name isEqual:@"ExerciseCategory"]) {
				[o setValue:parent forKey:@"category"];
			}
			[o setValue:[NSNumber numberWithInt:orderIndexStack[stackDepth]++] forKey:@"order"];	
		}
		
		NSMutableDictionary *parentDict = [stack lastObject];
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];

		id key;
		NSEnumerator *enumerator;

		enumerator = [parentDict keyEnumerator];
		while ((key = [enumerator nextObject])) {
			if ([key hasPrefix:@"child_"]) {
				id val = [parentDict objectForKey:key];
				[self addAttributeWithName:[key substringFromIndex:6] andValue:val toObject:o];
			}
		}
		
		enumerator = [attributeDict keyEnumerator];
		while ((key = [enumerator nextObject])) {
			id val = [attributeDict objectForKey:key];
			if ([key hasPrefix:@"child_"]) {
				[dict setValue:val forKey:key];
			} else {
				[self addAttributeWithName:key andValue:val toObject:o];
			}
		}
		
		[dict setValue:o forKey:@"_"];
		[stack addObject:dict];
		stackDepth++;
		orderIndexStack[stackDepth] = 0;
	}
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (stack.count == 0) return;

    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        NSMutableDictionary *dict = [stack lastObject];
        NSMutableString *text = [dict objectForKey:@"_mainText"];
        if (!text) {
            text = [NSMutableString stringWithCapacity:0];
            [dict setObject:text forKey:@"_mainText"];
        }
        [text appendString:string];
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
//    NSLog([NSString stringWithFormat:@"%d: close %@",stack.count,elementName]);
    
    indent--;
    NSMutableString *str = [NSMutableString string];
    for (int i=0;i<indent;i++) [str appendString:@"    "];
    [str appendFormat:@"/%@",elementName];
    NSLog(@"%@",str);
    
	if (stack.count == 0) return;
    
    NSMutableDictionary *dict = [stack lastObject];
	NSManagedObject *o = [dict objectForKey:@"_"];
    NSString *text = [dict objectForKey:@"_mainText"];
    NSString *name = [o.entity.name isEqualToString:@"Content"] ? [o valueForKey:@"name"] : nil;
	NSAttributeDescription *desc = [[[o entity] attributesByName] objectForKey:@"mainText"];
	if (desc) {
		if (text) {
            if ([name isEqualToString:@"careForExServing"]) {
                NSLog(@"foo");
            }
			text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            const char *utf8Text = [text UTF8String];
            htmlDocPtr doc = htmlReadMemory(utf8Text, (int)strlen(utf8Text), NULL, "UTF8", HTML_PARSE_RECOVER|HTML_PARSE_PEDANTIC);
            extractImages(doc);
            xmlFreeDoc(doc);
/*

            htmlParserCtxtPtr context = htmlCreatePushParserCtxt(&htmlHandlerStruct, self, NULL, 0, NULL, XML_CHAR_ENCODING_ASCII);
            htmlParseChunk(context, utf8Text, (int)strlen(utf8Text), 1);
            htmlFreeParserCtxt(context);
*/
			[o setValue:text forKey:@"mainText"];
		}

//		NSMutableData *data = [NSMutableData data];
/*
        if ([[[o entity] propertiesByName] objectForKey:@"displayName"] != nil) {
            NSString *s = [o valueForKey:@"displayName"];
            if (s) [data appendData:[s dataUsingEncoding: NSUTF8StringEncoding]];
        }
		
        if ([[[o entity] propertiesByName] objectForKey:@"name"] != nil) {
            NSString *s = [o valueForKey:@"name"];
            if (s) [data appendData:[s dataUsingEncoding: NSUTF8StringEncoding]];
        }
        
        if (data.length) {
            unsigned char result[16];
            CC_MD5([data bytes],(unsigned int)[data length],result);
            NSString *md5 = [NSString
                             stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                             result[0], result[1],
                             result[2], result[3],
                             result[4], result[5],
                             result[6], result[7],
                             result[8], result[9],
                             result[10], result[11],
                             result[12], result[13],
                             result[14], result[15]
                             ];
            
            if ([[[o entity] propertiesByName] objectForKey:@"uniqueID"] != nil) {
                [o setValue:md5 forKey:@"uniqueID"];
            }
        } else {
*/
            if ([[[o entity] propertiesByName] objectForKey:@"uniqueID"] != nil) {
                unsigned char guidBin[128];
                char guid[128];
                uuid_generate_random(guidBin);
                uuid_unparse(guidBin, guid);
                NSString *guidStr = [NSString stringWithUTF8String:guid];
                [o setValue:guidStr forKey:@"uniqueID"];
            }
//        }
	}
	
	[stack removeLastObject];
	stackDepth--;
}


-(void) parserDidEndDocument:(NSXMLParser *)parser {
//    NSLog(@"Ending document\n");
}

- (void)dealloc {
    [super dealloc];
}


@end
