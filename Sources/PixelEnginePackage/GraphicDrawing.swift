
import Foundation
import CoreGraphics
import CoreImage
import UIKit

public protocol GraphicsDrawing {

  func draw(in context: CGContext, canvasSize: CGSize)
}
