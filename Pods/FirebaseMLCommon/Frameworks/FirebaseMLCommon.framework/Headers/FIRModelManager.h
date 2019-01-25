#import <Foundation/Foundation.h>

@class FIRCloudModelSource;
@class FIRLocalModelSource;

NS_ASSUME_NONNULL_BEGIN

/**
 * A Firebase model manager for both local and cloud models.
 */
NS_SWIFT_NAME(ModelManager)
@interface FIRModelManager : NSObject

/**
 * Gets the model manager for the default Firebase app. The default Firebase app instance must be
 * configured before calling this method; otherwise raises `FIRAppNotConfigured` exception. The
 * returned model manager is thread safe. Models hosted in non-default Firebase apps are currently
 * not supported.
 *
 * @return A model manager for the default Firebase app.
 */
+ (instancetype)modelManager NS_SWIFT_NAME(modelManager());

/** Unavailable. Use the `modelManager` class method. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Registers a cloud model. The model name is unique to each cloud model and can only be registered
 * once with a given instance of the `ModelManager`. The model name should be the same name used
 * when uploading the model to the Firebase Console. It's OK to separately register a cloud model
 * and a local model with the same name for a given instance of the `ModelManager`.
 *
 * @param cloudModelSource The cloud model source to register.
 * @return Whether the registration was successful. Returns `NO` if the given `cloudModelSource` is
 *     invalid or has already been registered.
 */
- (BOOL)registerCloudModelSource:(FIRCloudModelSource *)cloudModelSource;

/**
 * Registers a local model. The model name is unique to each local model and can only be registered
 * once with a given instance of the `ModelManager`. It's OK to separately register a cloud model
 * and a local model with the same name for a given instance of the `ModelManager`.
 *
 * @param localModelSource The local model source to register.
 * @return Whether the registration was successful. Returns `NO` if the given `localModelSource` is
 *     invalid or has already been registered.
 */
- (BOOL)registerLocalModelSource:(FIRLocalModelSource *)localModelSource;

/**
 * Gets the registered cloud model with the given name. Returns `nil` if the model was never
 * registered with this model manager.
 *
 * @param name Name of the cloud model.
 * @return The cloud model that was registered with the given name. Returns `nil` if the model was
 *     never registered with this model manager.
 */
- (nullable FIRCloudModelSource *)cloudModelSourceForModelName:(NSString *)name;

/**
 * Gets the registered local model with the given name. Returns `nil` if the model was never
 * registered with this model manager.
 *
 * @param name Name of the local model.
 * @return The local model that was registered with the given name. Returns `nil` if the model was
 *     never registered with this model manager.
 */
- (nullable FIRLocalModelSource *)localModelSourceForModelName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
