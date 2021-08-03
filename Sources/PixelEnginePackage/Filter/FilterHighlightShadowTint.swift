

import Foundation
import UIKit

public typealias ColorName = UInt32

public struct FilterHighlightShadowTint : Filtering, Equatable {
  
  public enum HighlightTintColors: ColorName, CaseIterable {
    case Color1 = 0xE6E377
    case Color2 = 0xE6BB78
    case Color3 = 0xE67777
    case Color4 = 0xEA8CB7
    case Color5 = 0xB677E6
    case Color6 = 0x7781E6
    case Color7 = 0x77D2E5
    case Color8 = 0x77E681
  }

  public enum ShadowTintColors: ColorName, CaseIterable {
    case Color1 = 0xC7C12E
    case Color2 = 0xC78B2E
    case Color3 = 0xC72E2E
    case Color4 = 0xC4417E
    case Color5 = 0x852EC7
    case Color6 = 0x2E3CC7
    case Color7 = 0x2EABC7
    case Color8 = 0x2EC73C
  }
  
  public var highlightColor: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
  public var shadowColor: CIColor = CIColor(red: 0, green: 0, blue: 0, alpha: 0)
  
  public init() {
    
  }
  
  public func apply(to image: CIImage, sourceImage: CIImage) -> CIImage {
    
    let highlight = CIFilter(
      name: "CIConstantColorGenerator",
      parameters: [kCIInputColorKey : highlightColor]
      )!
      .outputImage!
      .cropped(to: image.extent)
    
    let shadow = CIFilter(
      name: "CIConstantColorGenerator",
      parameters: [kCIInputColorKey : shadowColor]
      )!
      .outputImage!
      .cropped(to: image.extent)
    
    let darken = CIFilter(
      name: "CISourceOverCompositing",
      parameters: [
        kCIInputImageKey : shadow,
        kCIInputBackgroundImageKey : image
      ])!
    
    let lighten = CIFilter(
      name: "CISourceOverCompositing",
      parameters: [
        kCIInputImageKey : highlight,
        kCIInputBackgroundImageKey : darken.outputImage!
      ])!
    
    return lighten.outputImage!
  }
}
