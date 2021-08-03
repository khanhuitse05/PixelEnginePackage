

import Foundation
import CoreGraphics
import CoreImage
import UIKit

open class EditingStack {
    
    // MARK: - Stored Properties
    
    public let source: ImageSourceType
    
    public let preferredPreviewSize: CGSize?
    
    public let targetScreenScale: CGFloat
    
    private(set) public var previewImage: CIImage?
    
    private(set) public var originalPreviewImage: CIImage? {
        didSet {
            updatePreviewImage()
        }
    }
    
    public var adjustmentImage: CIImage?
    
    public var aspectRatio: CGSize? {
        return originalPreviewImage?.extent.size
    }
    
    public var isDirty: Bool {
        return draftEdit != nil
    }
    
    public var canUndo: Bool {
        return edits.count > 1
    }
    
    public var draftEdit: Edit? {
        didSet {
            if oldValue != draftEdit {
                updatePreviewImage()
            }
        }
    }
    
    public var currentEdit: Edit {
        return draftEdit ?? edits.last!
    }
    
    public private(set) var edits: [Edit] {
        didSet {
            print("Edits changed count -> \(edits.count)")
        }
    }
    
    private let queue = DispatchQueue(
        label: "me.muukii.PixelEngine",
        qos: .default,
        attributes: []
    )
    
    // MARK: - Initializers
    public init(
        source: ImageSourceType,
        previewSize: CGSize? = nil,
        screenScale: CGFloat = UIScreen.main.scale
    ) {
        self.source = source
        self.targetScreenScale = screenScale
        self.preferredPreviewSize = previewSize
        self.adjustmentImage = source.imageSource?.image
        
        self.edits = [.init()]
        
        initialCrop()
        commit()
        removeAllHistory()
        self.source.setImageUpdateListener { [weak self] in
            guard let self = self else { return }
            self.adjustmentImage = $0.imageSource?.image
            self.initialCrop()
            guard $0.imageSource?.image != nil else { return }
        }
    }
    
    open func initialCrop() {
        guard let image = source.imageSource?.image else { return }
        if self.preferredPreviewSize != nil{
            setAdjustment()
        }else{
            originalPreviewImage = image
        }
    }
    
    // MARK: - Functions
    
    public func requestApplyingFilterImage() -> CIImage {
        fatalError()
    }
    
    private func makeDraft() {
        draftEdit = edits.last ?? .init()
    }
    
    public func commit() {
        guard let edit = draftEdit else {
            return
        }
        guard edits.last != edit else { return }
        edits.append(edit)
        draftEdit = nil
    }
    
    public func revert() {
        draftEdit = nil
    }
    
    public func undo() {
        edits.removeLast()
        updatePreviewImage()
    }
    
    public func removeAllHistory() {
        edits = [edits.last].compactMap { $0 }
    }
    
    public func set(filters: (inout Edit.Filters) -> Void) {
        applyIfChanged {
            filters(&$0.filters)
        }
    }
    
    public func setAdjustment() {
        
        guard let originalImage = source.imageSource?.image else { return }
        guard let previewSize  = preferredPreviewSize  else {
            originalPreviewImage = originalImage
            return;
        }
       
        let result = ImageTool.resize(
            to: Geometry.sizeThatAspectFit(
                aspectRatio: originalImage.extent.size,
                boundingSize: CGSize(
                    width: previewSize.width * targetScreenScale,
                    height: previewSize.height * targetScreenScale
                )
            ),
            from: originalImage
        )
        
        originalPreviewImage = result
    }
    
        
    public func makeRenderer() -> ImageRenderer {
        let renderer = ImageRenderer(source: source)
        renderer.edit.modifiers = currentEdit.makeFilters()
        
        return renderer
    }
    
    public func makeCustomRenderer(source: ImageSourceType) -> ImageRenderer{
        let renderer = ImageRenderer(source: source)
        renderer.edit.modifiers = currentEdit.makeFilters()
        
        return renderer
    }
    
    private func applyIfChanged(_ perform: (inout Edit) -> Void) {
        
        if draftEdit == nil {
            makeDraft()
        }
        
        var draft = draftEdit!
        perform(&draft)
        
        guard draftEdit != draft else { return }
        
        draftEdit = draft
        
    }
    
    private func updatePreviewImage() {
        
        guard let sourceImage = originalPreviewImage else {
            previewImage = nil
            return
        }
        
        let filters = self.currentEdit.makeFilters()
        
        let result = filters.reduce(sourceImage) { (image, filter) -> CIImage in
            filter.apply(to: image, sourceImage: sourceImage)
        }
        self.previewImage = result
    }
}


extension EditingStack {
    public struct Edit : Equatable {
        
        public struct Filters : Equatable {
            
            public var colorCube: FilterColorCube?
            
            public var color: FilterColor?
            public var contrast: FilterContrast?
            public var saturation: FilterSaturation?
            public var exposure: FilterExposure?
            
            public var highlights: FilterHighlights?
            public var shadows: FilterShadows?
            
            public var temperature: FilterTemperature?
            
            public var whiteBalance: FilterWhiteBalance?
            
            public var sharpen: FilterSharpen?
            public var gaussianBlur: FilterGaussianBlur?
            public var unsharpMask: FilterUnsharpMask?
            
            public var vignette: FilterVignette?
            public var fade: FilterFade?
            public var highlightShadowTint: FilterHighlightShadowTint?
            public var hls:FilterHLS?
            
            func makeFilters() -> [Filtering] {
                return ([
                    
                    // Before
                    exposure,
                    color,
                    temperature,
                    highlights,
                    shadows,
                    saturation,
                    contrast,
                    colorCube,
                    
                    // After
                    sharpen,
                    unsharpMask,
                    gaussianBlur,
                    fade,
                    vignette,
                    
                    // Custom
                    highlightShadowTint,
                    hls,
                    whiteBalance,
                    ] as [Optional<Filtering>])
                    .compactMap { $0 }
            }
        }
        
        public var filters: Filters = .init()
        
        func makeFilters() -> [Filtering] {
            return filters.makeFilters()
        }
    }
}
