

import Foundation
import CoreImage

public struct FilterShadows: Filtering, Equatable, Codable {

  public static let range: ParameterRange<Double, FilterShadows> = .init(min: -1, max: 1)

  public var value: Double = 0

  public init() {

  }

  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {

    return
      image
        .applyingFilter("CIHighlightShadowAdjust", parameters: ["inputShadowAmount" : value])
  }
}
