

import Foundation
import CoreImage

public struct FilterSharpen: Filtering, Equatable, Codable {
  
  public enum Params {
    public static let radius: ParameterRange<Double, FilterSharpen> = .init(min: 0, max: 20)
    public static let sharpness: ParameterRange<Double, FilterSharpen> = .init(min: 0, max: 1)
  }

  public var sharpness: Double = 0
  public var radius: Double = 0

  public init() {

  }

  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {

    let _radius = RadiusCalculator.radius(value: radius, max: FilterGaussianBlur.range.max, imageExtent: image.extent)

    return
      image
        .applyingFilter(
          "CISharpenLuminance", parameters: [
            "inputRadius" : _radius,
            "inputSharpness": sharpness,
            ])
  }
}
