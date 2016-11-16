

#import "JSUtil.h"
#import <objc/runtime.h>

@implementation JSUtil

+ (NSArray *)allPropertiesOfClass:(Class)clazz {
    NSMutableArray *mutArr = [[NSMutableArray alloc] init];
    while(clazz != [NSObject class]) {
        unsigned int count = 0;
        objc_property_t* properties = class_copyPropertyList(clazz, &count);
        
        for (int i = 0; i < count ; i++) {
            objc_property_t prop = properties[i];
            NSString *propertyName = [NSString stringWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
            [mutArr addObject:propertyName];
        }
        
        if(properties) {
            free(properties);
        }
        
        clazz = class_getSuperclass(clazz);
    }
    
    return mutArr;
}
@end
