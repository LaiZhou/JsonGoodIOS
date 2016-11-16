

#import "JSRpcManager.h"

@implementation JSRpcManager

+ (instancetype)managerWithGatewayURL:(NSString *)URL {
    return [[self alloc] initWithGatewayURL:URL];
}

- (id)initWithGatewayURL:(NSString *)URL {
    NSParameterAssert(URL);
    
    self = [super initWithBaseURL:[NSURL URLWithString:URL]];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [JSJSONRequestEncoder serializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.responseSerializer=[[JSJSONResponseDecoder alloc] init];
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    self->_gatewayURL = URL;
    
    return self;
}


-(void) invoke:(NSString *)methodEndPoint
withParameters:(NSArray *)parameters
       success:(void (^)(AFHTTPRequestOperation *operation, JSRpcResult *rpcResult))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    [self invoke:methodEndPoint withParameters:parameters withAttachments:nil success:success failure:failure];
}

-(void) invoke:(NSString *)methodEndPoint
withParameters:(NSArray *)parameters
withAttachments:(NSDictionary *)attachments
       success:(void (^)(AFHTTPRequestOperation *operation, JSRpcResult *rpcResult))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    if (_customHttpHeaders) {
        [_customHttpHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        } ];
        
    }
    NSMutableDictionary *data=[NSMutableDictionary  new];
    
    NSMutableDictionary *mergedAttachments=[NSMutableDictionary  new];
    if (_attachments) {
        [mergedAttachments addEntriesFromDictionary:_attachments];
    }
    if (attachments) {
        [mergedAttachments addEntriesFromDictionary:attachments];
    }
    if ([mergedAttachments count]>0) {
        [data setValue:mergedAttachments forKey:@"attachments"];
    }
    
    [data setValue:methodEndPoint forKey:@"methodEndPoint"];
    if (parameters) {
        [data setValue:parameters forKey:@"parameters"];
        
    }
    
    [self POST:_gatewayURL  parameters:data success:^(AFHTTPRequestOperation *operation, id responseObject) {
        JSRpcResult *rpcResult=[[JSRpcResult alloc] initWithDictionary:responseObject error:nil];
        success(operation,rpcResult);
    }
       failure:failure];
    
    
}
@end
