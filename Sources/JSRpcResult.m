
#import "JSRpcResult.h"
#import "NSDictionary+JS.h"
@implementation JSRpcResult


-(id) dataToObject:(Class)clazz{
    if([_data isKindOfClass:[NSDictionary class]]){
        return [_data toObject:clazz];

    }else if([_data isKindOfClass:clazz]) {
        return _data;
    }else{
        return nil;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{code=%d,message=%@,data=%@}", _code,_message,_data];
}
@end
