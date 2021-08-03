

import UIKit
import CoreImage
import AVFoundation

public enum ImageTool {

  private static let ciContext = CIContext(options: [
    .useSoftwareRenderer : false,
    .highQualityDownsample: true,
    .workingColorSpace : CGColorSpaceCreateDeviceRGB()
    ]
  )

  public static func resize(to pixelSize: CGSize, from image: CIImage) -> CIImage? {

    var targetSize = pixelSize
    targetSize.height.round(.down)
    targetSize.width.round(.down)

    let scaleX = targetSize.width / image.extent.width
    let scaleY = targetSize.height / image.extent.height

    return
      autoreleasepool { () -> CIImage? in

        let originalExtent = image.extent

        let format: UIGraphicsImageRendererFormat
        if #available(iOS 11.0, *) {
          format = UIGraphicsImageRendererFormat.preferred()
        } else {
          format = UIGraphicsImageRendererFormat.default()
        }
        format.scale = 1
        format.opaque = true
        format.preferredRange = .automatic
        
                  
        let uiImage = UIGraphicsImageRenderer.init(size: targetSize, format: format)
          .image { c in
            
            autoreleasepool {
              let rect = CGRect(origin: .zero, size: targetSize)
              if let cgImage = image.cgImage {
                c.cgContext.translateBy(x: 0, y: targetSize.height)
                c.cgContext.scaleBy(x: 1, y: -1)
                c.cgContext.draw(cgImage, in: rect)

              } else {
                  c.cgContext.translateBy(x: 0, y: targetSize.height)
                  c.cgContext.scaleBy(x: 1, y: -1)
                  let context = CIContext(cgContext: c.cgContext, options: [:])
                  context.draw(image, in: rect, from: image.extent)
                
              }
            }
          }
        
        if let resizedImage: CIImage = CIImage(image: uiImage)?.insertingIntermediate(cache: true){
            let r = resizedImage.transformed(by: .init(
              translationX: (originalExtent.origin.x * scaleX).rounded(.down),
              y: (originalExtent.origin.y * scaleY).rounded(.down)
              )
            )

            return r
       }else{
        return image
       }
    }
  }

}
