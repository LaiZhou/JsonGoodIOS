

#import "JSJSONRequestEncoder.h"
#import "NSObject+JS.h"
@implementation JSJSONRequestEncoder


- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request
                               withParameters:(id)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    
    [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        [mutableRequest setValue:value forHTTPHeaderField:field];
    }];
    
    if (parameters) {
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        }
        NSString *parametersJson=[parameters  toJsonString];
        NSData *payload=[parametersJson dataUsingEncoding:NSUTF8StringEncoding];
        [mutableRequest setHTTPBody:[self encodedPayload:payload]];
        
    }
    
    return mutableRequest;
}

-(NSData *) encodedPayload:(NSData *)payload{
    //子类可以继承实现
    return payload;
}
@end
