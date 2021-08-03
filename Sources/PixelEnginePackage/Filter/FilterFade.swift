

import Foundation
import CoreImage

public struct FilterFade : Filtering, Equatable, Codable {
  
  public enum Params {
    public static let intensity: ParameterRange<Double, FilterShadows> = .init(min: 0, max: 0.5)
  }
  
  public var intensity: Double = 0
  
  public init() {
    
  }
  
  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    
    let background = image
    let foreground = CIFilter(
      name: "CIConstantColorGenerator",
      parameters: [kCIInputColorKey : CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(intensity))]
      )!
      .outputImage!
      .cropped(to: image.extent)
    
    let composition = CIFilter(
      name: "CISourceOverCompositing",
      parameters: [
        kCIInputImageKey : foreground,
        kCIInputBackgroundImageKey : background
      ])!
    
    return composition.outputImage!
  }
  
}
