#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A model stored locally on the device.
 */
NS_SWIFT_NAME(LocalModelSource)
@interface FIRLocalModelSource : NSObject

/** The model name. */
@property(nonatomic, copy, readonly) NSString *name;

/** The file path to the model stored locally on the device. */
@property(nonatomic, copy, readonly) NSString *path;

/**
 * Creates an instance of `LocalModelSource` with a given name and file path.
 *
 * @param name A local model name. Within the same Firebase app, all local models should have
 *     distinct names.
 * @param path An absolute path to the model file stored locally on the device.
 * @return A new instance of `LocalModelSource` with the given path.
 */
- (instancetype)initWithName:(NSString *)name path:(NSString *)path NS_SWIFT_NAME(init(name:path:));

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
