
#import "NSObject+JS.h"
#import "JSUtil.h"
#import <objc/runtime.h>

@implementation NSObject(JS)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    self = [self init];
    if (self == nil) return nil;
    
    for (NSString *key in dictionary) {
        // Mark this as being autoreleased, because validateValue may return
        // a new object to be stored in this variable (and we don't want ARC to
        // double-free or leak the old or new values).
        __autoreleasing id value = [dictionary objectForKey:key];
        
        if ([value isEqual:NSNull.null]) value = nil;
        
        BOOL success =JSValidateAndSetValue(self, key, value, YES, error);
        if (!success) return nil;
    }
    
    return self;
}

static BOOL JSValidateAndSetValue(id obj, NSString *key, id value, BOOL forceUpdate, NSError **error) {
    // Mark this as being autoreleased, because validateValue may return
    // a new object to be stored in this variable (and we don't want ARC to
    // double-free or leak the old or new values).
    __autoreleasing id validatedValue = value;
    
    @try {
        if (![obj validateValue:&validatedValue forKey:key error:error]) return NO;
        
        if (forceUpdate || value != validatedValue) {
            [obj setValue:validatedValue forKey:key];
        }
        
        return YES;
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception setting key \"%@\" : %@", key, ex);
        
        // Fail fast in Debug builds.
#if DEBUG
        @throw ex;
#else
        if (error != NULL) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: ex.description,
                                       NSLocalizedFailureReasonErrorKey: ex.reason,
                                       };
            
             *error = [NSError errorWithDomain:@"JSONGOOD" code:-1 userInfo:userInfo];

        }
        
        return NO;
#endif
    }
}


- (id) toJsonObject {
    
    if([self isKindOfClass:[NSNumber class]]) {
        return self;
    } else if([self isKindOfClass:[NSString class]]) {
        return self;
    }else if([self isKindOfClass:[NSDate class]]){
        return [NSString stringWithFormat:@"%@", self];
    } else if([self isKindOfClass:[NSArray class]]) {
        NSArray *oldArray = (NSArray *)self;
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[oldArray count]];
        for(id item in oldArray) {
            [newArray addObject:[item toJsonObject]];
        }
        return newArray;
    } else if([self isKindOfClass:[NSDictionary class]]) {
        NSDictionary *oldDict = (NSDictionary *)self;
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:[oldDict count]];
        for(id key in [oldDict allKeys]) {
            id item = [oldDict valueForKey:key];
            [newDict setValue:[item toJsonObject] forKey:key];
        }
        return newDict;
    } else {
        NSArray *propertyArray = [JSUtil allPropertiesOfClass:[self class]];
        NSMutableDictionary *returnDic = [NSMutableDictionary dictionaryWithCapacity:propertyArray.count];
        for(NSString *property in propertyArray) {
            id value = [self valueForKey:property];
            if(value) {
                value = [value toJsonObject];
                [returnDic setValue:value forKey:property];

            }
        }
        return returnDic;
    }
}



- (NSString*) toJsonString{
    NSData *data = [NSJSONSerialization dataWithJSONObject:[self toJsonObject] options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

- (Class)classOfPropertyName:(NSString*) propertyName {
    Class propertyClass = nil;
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
    NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
    if(splitPropertyAttributes.count > 0) {
        NSString *encodeType = splitPropertyAttributes[0];
        /**
         if([encodeType isEqualToString:@"Ti"] || [encodeType isEqualToString:@"TI"] || [encodeType isEqualToString:@"Ts"] ||
         [encodeType isEqualToString:@"Tf"] || [encodeType isEqualToString:@"Td"] || [encodeType isEqualToString:@"Tl"]) {
         return nil;
         }
         */
        
        if([encodeType hasPrefix:@"T@"]) {
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            NSString *className = nil;
            if(splitEncodeType.count > 1) {
                className = splitEncodeType[1];
            }
            
            if(className) {
                propertyClass = NSClassFromString(className);
            }
        }
    }
    return propertyClass;
}




@end
