#import <Foundation/Foundation.h>

@class FIRVisionBarcode;
@class FIRVisionImage;

NS_ASSUME_NONNULL_BEGIN

/**
 * A block containing an array of barcodes or `nil` if there's an error.
 *
 * @param barcodes Array of barcodes detected in the image or `nil` if there was an error.
 * @param error The error or `nil`.
 */
typedef void (^FIRVisionBarcodeDetectionCallback)(NSArray<FIRVisionBarcode *> *_Nullable barcodes,
                                                  NSError *_Nullable error)
    NS_SWIFT_NAME(VisionBarcodeDetectionCallback) DEPRECATED_MSG_ATTRIBUTE(
        "This API is deprecated and replaced by the new standalone ML Kit SDK. See the migration "
        "guide at https://developers.google.com/ml-kit/migration");

/** A barcode detector that detects barcodes in an image. */
NS_SWIFT_NAME(VisionBarcodeDetector)
DEPRECATED_MSG_ATTRIBUTE(
    "This API is deprecated and replaced by the new standalone ML Kit SDK. See the migration guide "
    "at https://developers.google.com/ml-kit/migration")
@interface FIRVisionBarcodeDetector : NSObject

/** Unavailable. Use `Vision` factory methods. */
- (instancetype)init NS_UNAVAILABLE;

/**
 * Detects barcodes in the given image.
 *
 * @param image The image to use for detecting barcodes.
 * @param completion Handler to call back on the main queue with barcodes detected or error.
 */
- (void)detectInImage:(FIRVisionImage *)image
           completion:(FIRVisionBarcodeDetectionCallback)completion;

@end

NS_ASSUME_NONNULL_END
