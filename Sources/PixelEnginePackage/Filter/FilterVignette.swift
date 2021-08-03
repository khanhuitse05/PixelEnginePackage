
import Foundation
import CoreImage

public struct FilterVignette: Filtering, Equatable, Codable {

  public static let range: ParameterRange<Double, FilterVignette> = .init(min: 0, max: 2)

  public var value: Double = 0

  public init() {

  }
    
  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {

    let radius = RadiusCalculator.radius(value: value, max: FilterVignette.range.max, imageExtent: image.extent)

    return
      image.applyingFilter(
        "CIVignette",
        parameters: [
          kCIInputRadiusKey: radius as AnyObject,
          kCIInputIntensityKey: value as AnyObject,
        ])
  }
}
