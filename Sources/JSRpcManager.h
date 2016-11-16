
#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>
#import "JSJSONRequestEncoder.h"
#import "JSJSONResponseDecoder.h"
#import "JSRpcResult.h"
#import "NSDictionary+JS.h"
#import "NSObject+JS.h"
#import "JSUtil.h"
@interface JSRpcManager : AFHTTPRequestOperationManager

@property (readonly, nonatomic, strong) NSString *gatewayURL;//网关地址

@property (nonatomic, strong) NSDictionary *attachments;//invoke额外的参数

@property (nonatomic, strong) NSDictionary *customHttpHeaders;//自定义的HttpHeaders

+ (instancetype)managerWithGatewayURL:(NSString *)URL;

-(void) invoke:(NSString *)methodEndPoint
withParameters:(NSArray *)parameters
       success:(void (^)(AFHTTPRequestOperation *operation, JSRpcResult *rpcResult))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void) invoke:(NSString *)methodEndPoint
withParameters:(NSArray *)parameters
withAttachments:(NSDictionary *)attachments
       success:(void (^)(AFHTTPRequestOperation *operation, JSRpcResult *rpcResult))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
