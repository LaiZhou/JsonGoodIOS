
#import <Foundation/Foundation.h>

@interface JSRpcResult : NSObject

@property(nonatomic, assign) int code;

@property(nonatomic, strong) NSString *message;

@property(nonatomic, strong) id data;


@property(nonatomic, assign) BOOL success;
@property(nonatomic, assign) BOOL valid;

    
-(id) dataToObject:(Class)clazz;
@end
