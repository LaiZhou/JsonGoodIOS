
#import "NSDictionary+JS.h"
#import "NSObject+JS.h"
#import "JSUtil.h"
@implementation NSDictionary(JS)

- (id) toObject:(Class)clazz {
    if(![self isKindOfClass:[NSDictionary class]]) {
        NSLog(@"the object must be of %@", [NSDictionary class]);
        return nil;
    }
    
    if([clazz isSubclassOfClass:[NSDictionary class]]) {
        return [self copy];
    }
    
    NSArray *propertyArray = [JSUtil allPropertiesOfClass:clazz];
    
    NSDictionary *zelf = (NSDictionary*)self;
    id ret = [[clazz alloc] init];
    NSMutableArray* missedProperties = [NSMutableArray arrayWithCapacity:propertyArray.count];
    
    for (NSString *propertyName in propertyArray) {
        id value = [zelf objectForKey:propertyName];
        if(!value) {
            [missedProperties addObject:propertyName];
            continue;
        }
        
        if(value == [NSNull null]) {
            [ret setValue:nil forKey:propertyName];
            continue;
        }
        
        Class valueClaz = [value class];
        Class propertyClaz = [ret classOfPropertyName:propertyName];
        
        if(propertyClaz) {
            if([value isKindOfClass:propertyClaz]) {
                if([propertyClaz isSubclassOfClass:[NSArray class]]) {
                    NSString *elementClassSel = [NSString stringWithFormat:@"%@ElementClass", propertyName];
                    SEL selector = NSSelectorFromString(elementClassSel);
                    if([[ret class] respondsToSelector:selector]) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Warc-performSelector-leaks"
                        Class elementCls = [[ret class] performSelector:selector];
#pragma GCC diagnostic pop
                        NSArray *arr = (NSArray *)value;
                        NSMutableArray *mutArr = [NSMutableArray arrayWithCapacity:arr.count];
                        for(id item in arr) {
                            if ([item isKindOfClass:[NSDictionary class]]) {
                                id newItem = [item toObject:elementCls];
                                NSAssert(newItem != nil, @"数据错误");
                                if(newItem) {
                                    [mutArr addObject:newItem];
                                }
                            }else{
                                [mutArr addObject:item];

                            }
                           
                        }
                        [ret setValue:mutArr forKey:propertyName];
                    } else {
                        [ret setValue:value forKey:propertyName];
                    }
                } else {
                    [ret setValue:value forKey:propertyName];
                }
            } else if([value isKindOfClass:[NSDictionary class]]){
                [ret setValue:[value toObject:propertyClaz] forKey:propertyName];
            } else {
                [ret setValue:value forKey:propertyName];
                NSLog(@"type of '%@' is %@, %@ is expected", propertyName, propertyClaz, valueClaz);
            }
        } else {
            [ret setValue:value forKey:propertyName];
        }
    }
    
    if([missedProperties count] > 0) {
        NSLog(@"%@ value of properties %@ missed", clazz, missedProperties);
    }
    
    return ret;
}


@end
