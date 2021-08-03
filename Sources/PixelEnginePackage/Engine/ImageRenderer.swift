

import Foundation
import CoreGraphics
import CoreImage
import UIKit

public final class ImageRenderer {
  
  public enum Resolution {
    case full
    case resize(boundingSize: CGSize)
  }

  public struct Edit {
    public var modifiers: [Filtering] = []
  }

  private let cicontext = CIContext(options: [
    .useSoftwareRenderer : false,
    .highQualityDownsample : true,
    ])
  
  public let source: ImageSourceType

  public var edit: Edit = .init()

  public init(source: ImageSourceType) {
    self.source = source
  }

  public func render(resolution: Resolution = .full) -> UIImage {
    guard let targetImage = source.imageSource?.image else {
      preconditionFailure("Nothing to render")
    }
    let resultImage: CIImage = {

      let sourceImage: CIImage = targetImage

      let result = edit.modifiers.reduce(sourceImage, { image, modifier in
        return modifier.apply(to: image, sourceImage: sourceImage)
      })
      return result

    }()

    let canvasSize: CGSize
      
    switch resolution {
    case .full:
      canvasSize = resultImage.extent.size
    case .resize(let boundingSize):
      canvasSize = Geometry.sizeThatAspectFit(aspectRatio: resultImage.extent.size, boundingSize: boundingSize)
    }
    
    let format: UIGraphicsImageRendererFormat
    if #available(iOS 11.0, *) {
      format = UIGraphicsImageRendererFormat.preferred()
    } else {
      format = UIGraphicsImageRendererFormat.default()
    }
    format.scale = 1
    format.opaque = true
    if #available(iOS 12.0, *) {
      format.preferredRange = .extended
    } else {
      format.prefersExtendedRange = false
    }
    
    let image = autoreleasepool { () -> UIImage in
      
      UIGraphicsImageRenderer.init(size: canvasSize, format: format)
        .image { c in
          
          let cgContext = UIGraphicsGetCurrentContext()!
          
          let cgImage = cicontext.createCGImage(resultImage, from: resultImage.extent, format: .RGBA8, colorSpace: resultImage.colorSpace ?? CGColorSpaceCreateDeviceRGB())!
          
          cgContext.saveGState()
          cgContext.translateBy(x: 0, y: canvasSize.height)
          cgContext.scaleBy(x: 1, y: -1)
          cgContext.draw(cgImage, in: CGRect(origin: .zero, size: canvasSize))
          cgContext.restoreGState()
      }
      
    }
    
    return image
  }
}

