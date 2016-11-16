
#import <Foundation/Foundation.h>

@interface NSObject(JS)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

- (Class)classOfPropertyName:(NSString*) propertyName;
- (NSString*) toJsonString;
@end
