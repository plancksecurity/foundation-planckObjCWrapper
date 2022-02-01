//
//  PEPEqualableTools.h
//  PEPObjCTypes
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///!!!: ObjCTypes is definatelly the wrong place for this
@interface PEPEqualableTools : NSObject

/**
 Invokes `[value1 isEqual:value2]` between all value pairs retrieved
 from `object` and `other`, based on the list of keys.
 @Note The values of all keys MUST be of type `id`. `nil` is considered equal to `nil`, in contrast to [NSObject isEqual:].
 */
+ (BOOL)object:(NSObject * _Nonnull)object
     isEqualTo:(NSObject * _Nonnull)other
   basedOnKeys:(NSArray<NSString *> * _Nonnull)keys;

/**
 Calculates a hash based on the given `keys`.
 @Note The values of all keys MUST be of type `id`.
 */
+ (NSUInteger)hashForObject:(NSObject * _Nonnull)object basedOnKeys:(NSArray<NSString *> * _Nonnull)keys;

@end

NS_ASSUME_NONNULL_END
