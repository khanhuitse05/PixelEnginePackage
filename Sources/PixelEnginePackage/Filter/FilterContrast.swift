
import Foundation
import CoreImage

public struct FilterContrast: Filtering, Equatable, Codable {

  public static let range: ParameterRange<Double, FilterContrast> = .init(min: -0.18, max: 0.18)
  
  public var value: Double = 0

  public init() {

  }

  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    return
      image
        .applyingFilter(
          "CIColorControls",
          parameters: [
            kCIInputContrastKey: 1 + value,
            ]
    )
  }

}
