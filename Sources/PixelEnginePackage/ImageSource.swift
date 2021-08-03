

import Foundation

import CoreImage

#if canImport(UIKit)
import UIKit
#endif

public enum ImageSource {
  case previewOnly(CIImage)
  case editable(CIImage)

  var image: CIImage {
    switch self {
    case .editable(let image):
      return image
    case .previewOnly(let image)  :
      return image
    }
  }
}

public protocol ImageSourceType {
  func setImageUpdateListener(_ listner: @escaping (ImageSourceType) -> Void)
  var imageSource: ImageSource? { get }
}

#if canImport(Photos)
import Photos

public final class PHAssetImageSource: ImageSourceType {
  private var listner: ((ImageSourceType) -> Void) = { _ in }
  public var imageSource: ImageSource? {
    didSet {
      listner(self)
    }
  }

  public init(_ asset: PHAsset) {
    let previewRequestOptions = PHImageRequestOptions()
    previewRequestOptions.deliveryMode = .highQualityFormat
    previewRequestOptions.isNetworkAccessAllowed = true
    previewRequestOptions.version = .current
    previewRequestOptions.resizeMode = .fast
    let finalImageRequestOptions = PHImageRequestOptions()
    finalImageRequestOptions.deliveryMode = .highQualityFormat
    finalImageRequestOptions.isNetworkAccessAllowed = true
    finalImageRequestOptions.version = .current
    finalImageRequestOptions.resizeMode = .none
    //TODO cancellation, Error handeling

    PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 360, height: 360), contentMode: .aspectFit, options: previewRequestOptions) { [weak self] (image, _) in
      guard let image = image, let self = self else { return }
      let ciImage = image.ciImage ?? CIImage(cgImage: image.cgImage!)
      self.imageSource = .previewOnly(ciImage)
    }
    PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: finalImageRequestOptions) { [weak self] (image, _) in
      guard let image = image, let self = self else { return }
      let ciImage = image.ciImage ?? CIImage(cgImage: image.cgImage!)
      self.imageSource = .editable(ciImage)
    }
  }

  public func setImageUpdateListener(_ listner: @escaping (ImageSourceType) -> Void) {
    if imageSource != nil {
      listner(self)
    }
    self.listner = listner
  }
}

#endif

public struct StaticImageSource: ImageSourceType {
  private let image: CIImage
  public var imageSource: ImageSource? {
    return .editable(image)
  }

  public func setImageUpdateListener(_ listner: @escaping (ImageSourceType) -> Void) {
    listner(self)
  }


  #if os(iOS)

  public init(source: UIImage) {

    let image = CIImage(image: source)!
    let fixedOriantationImage = image.oriented(forExifOrientation: imageOrientationToTiffOrientation(source.imageOrientation))

    self.init(source: fixedOriantationImage)
  }

  #endif

  public init(source: CIImage) {

    precondition(source.extent.origin == .zero)
    self.image = source
  }

}

fileprivate func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
  switch value{
  case .up:
    return 1
  case .down:
    return 3
  case .left:
    return 8
  case .right:
    return 6
  case .upMirrored:
    return 2
  case .downMirrored:
    return 4
  case .leftMirrored:
    return 5
  case .rightMirrored:
    return 7
  default:
    return 1
  }
}
