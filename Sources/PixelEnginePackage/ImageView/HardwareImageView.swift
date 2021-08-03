

import Foundation
import CoreImage

public protocol HardwareImageViewType : class {
  var image: CIImage? { get set }
}
