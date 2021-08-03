

import Foundation
import CoreImage

public struct FilterColor: Filtering, Equatable, Codable {
    
    public static let rangeSaturation: ParameterRange<Double, FilterContrast> = .init(min: 0, max: 2)
    public static let rangeBrightness: ParameterRange<Double, FilterContrast> = .init(min: -0.2, max: 0.2)
    public static let rangeContrast: ParameterRange<Double, FilterContrast> = .init(min: 0, max: 2)
    
    public var valueSaturation: Double = 1
    public var valueBrightness: Double = 0
    public var valueContrast: Double = 1
    
    public init() {
        
    }
    
    public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
        return
            image
                .applyingFilter(
                    "CIColorControls",
                    parameters: [
                        "inputSaturation": valueSaturation,
                        "inputBrightness": valueBrightness,
                        "inputContrast": valueContrast,
                    ]
        )
    }
    
}
