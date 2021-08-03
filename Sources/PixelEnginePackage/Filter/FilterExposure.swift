

import Foundation
import CoreImage

public struct FilterExposure : Filtering, Equatable, Codable {
  
  public static let range: ParameterRange<Double, FilterExposure> = .init(min: -1.8, max: 1.8)
  
  public var value: Double = 0
  
  public init() {
    
  }
  
  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    return
      image
        .applyingFilter(
          "CIExposureAdjust",
          parameters: [
            kCIInputEVKey: value as AnyObject
          ]
    )
  }
  
}
