#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Configurations for model downloading conditions.
 */
NS_SWIFT_NAME(ModelDownloadConditions)
@interface FIRModelDownloadConditions : NSObject<NSCopying>

/**
 * Indicates whether Wi-Fi is required for downloading. The default is `NO`.
 */
@property(nonatomic, readonly) BOOL isWiFiRequired;

/**
 * Indicates whether the model can be downloaded while the app is in the background. The default is
 * `NO`.
 */
@property(nonatomic, readonly) BOOL canDownloadInBackground;

/**
 * Creates an instance of `ModelDownloadConditions` with the given conditions.
 *
 * @param isWiFiRequired Whether a device has to be connected to Wi-Fi for downloading to start.
 * @param canDownloadInBackground Whether the model can be downloaded while the app is in the
 *     background.
 * @return A new instance of `ModelDownloadConditions`.
 */
- (instancetype)initWithIsWiFiRequired:(BOOL)isWiFiRequired
               canDownloadInBackground:(BOOL)canDownloadInBackground NS_DESIGNATED_INITIALIZER;

/**
 * Creates an instance of `ModelDownloadConditions` with the default conditions. The default values
 * are listed in the documentation for each download condition property.
 *
 * @return A new instance of `ModelDownloadConditions`.
 */
- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
