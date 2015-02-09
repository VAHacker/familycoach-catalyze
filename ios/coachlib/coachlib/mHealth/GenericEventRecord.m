
#import "GenericEventRecord.h"

@implementation GenericEventRecord

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)pack:(msgpack_packer*)pk {
    msgpack_pack_array(pk, 3);
    msgpack_pack_int(pk, eventID);
    msgpack_pack_long(pk, timestamp);
    msgpack_pack_raw(pk, [eventData length]);
    msgpack_pack_raw_body(pk, [eventData UTF8String], [eventData length]);
}

- (void)unpack:(msgpack_object_array*)array {
    eventID = array->ptr[0].via.i64;
    timestamp = array->ptr[0].via.u64;
}

@end
