

import Foundation
import CoreImage

public struct FilterSaturation: Filtering, Equatable, Codable {

  public static let range: ParameterRange<Double, FilterSaturation> = .init(min: -1, max: 1)
    
  public var value: Double = 0

  public init() {

  }

  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    return
      image
        .applyingFilter(
          "CIColorControls",
          parameters: [
            kCIInputSaturationKey: 1 + value,
            ]
    )
  }
}
