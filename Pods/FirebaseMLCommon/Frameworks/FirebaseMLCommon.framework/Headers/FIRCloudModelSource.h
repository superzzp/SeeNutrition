#import <Foundation/Foundation.h>

@class FIRModelDownloadConditions;

NS_ASSUME_NONNULL_BEGIN

/**
 * A model stored in the cloud and downloaded to the device.
 */
NS_SWIFT_NAME(CloudModelSource)
@interface FIRCloudModelSource : NSObject

/** The model name. */
@property(nonatomic, copy, readonly) NSString *name;

/** Indicates whether model updates are enabled. */
@property(nonatomic, readonly) BOOL enableModelUpdates;

/** Initial downloading conditions for the model. */
@property(nonatomic, readonly) FIRModelDownloadConditions *initialConditions;

/**
 * Subsequent update conditions for the model. If `nil` is passed to the initializer, the default
 * download conditions are set, but are only used if `enableModelUpdates` is `YES`.
 */
@property(nonatomic, readonly) FIRModelDownloadConditions *updateConditions;

/**
 * Creates an instance of `CloudModelSource` with the given name and the download conditions.
 *
 * @param name The name of the model to download. Specify the name you assigned the model when you
 *     uploaded it to the Firebase console. Within the same Firebase app, all cloud models should
 *     have distinct names.
 * @param enableModelUpdates Indicates whether model updates are enabled.
 * @param initialConditions Initial downloading conditions for the model.
 * @param updateConditions Subsequent update conditions for the model. If it is `nil` and
 *     `enableModelUpdates` is `YES`, the default download conditions are used.
 * @return A new instance of `CloudModelSource` with the given name and conditions.
 */
- (instancetype)initWithName:(NSString *)name
          enableModelUpdates:(BOOL)enableModelUpdates
           initialConditions:(FIRModelDownloadConditions *)initialConditions
            updateConditions:(nullable FIRModelDownloadConditions *)updateConditions
    NS_SWIFT_NAME(init(name:enableModelUpdates:initialConditions:updateConditions:));

/**
 * Unavailable.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
