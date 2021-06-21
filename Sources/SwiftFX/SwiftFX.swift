#if os(macOS)
import AppKit
#else
import UIKit
#endif
import CoreGraphics
import SwiftUI
import RenderKit
import PixelKit
import PixelColor

public typealias FX = NODERepView

var didSetup: Bool = false

func setup() {
    guard !didSetup else { return }
    #if !DEBUG
    PixelKit.main.disableLogging()
    #endif
    didSetup = true
}

extension View {
    
    func pix() -> ViewPIX {
        #if os(macOS)
        let view: NSView = NSHostingController(rootView: self).view
        view.wantsLayer = true
        view.layer?.backgroundColor = .clear
        #else
        let view: UIView = UIHostingController(rootView: self).view
        view.backgroundColor = .clear
        #endif
        let viewPix = ViewPIX()
        viewPix.renderView = view
        return viewPix
    }
    
    func fx(edit: (PIX & NODEOut) -> (PIX)) -> FX {
        if !didSetup { setup() }
        let inPix: PIX & NODEOut
        if let fx: FX = self as? FX {
            inPix = fx.node as! PIX & NODEOut
        } else {
            inPix = pix()
        }
        let outPix: PIX = edit(inPix)
        outPix.view.checker = false
        return FX(node: outPix)
    }
}

extension NODEOut {
    
    func whiteOnBlack() -> ReorderPIX {
        let reorderPix = ReorderPIX()
        reorderPix.inputA = self as? PIX & NODEOut
        reorderPix.inputB = self as? PIX & NODEOut
        reorderPix.redChannel = .alpha
        reorderPix.greenChannel = .alpha
        reorderPix.blueChannel = .alpha
        reorderPix.alphaChannel = .one
        return reorderPix
    }
    
    func primaryAlpha() -> CrossPIX {
        let darkPix = ReorderPIX()
        darkPix.inputA = self as? PIX & NODEOut
        darkPix.inputB = self as? PIX & NODEOut
        darkPix.redChannel = .zero
        darkPix.greenChannel = .zero
        darkPix.blueChannel = .zero
        darkPix.alphaChannel = .luma
        let lightPix = ReorderPIX()
        lightPix.inputA = self as? PIX & NODEOut
        lightPix.inputB = self as? PIX & NODEOut
        lightPix.redChannel = .luma
        lightPix.greenChannel = .luma
        lightPix.blueChannel = .luma
        lightPix.alphaChannel = .luma
        let crossPix = CrossPIX()
        crossPix.inputA = darkPix
        crossPix.inputB = lightPix
        crossPix.fraction = PixelColor.appearance == .dark ? 1.0 : 0.0
        return crossPix
    }
}

public extension View {
    
    func fxBlur(style: BlurPIX.BlurStyle = .gaussian,
                radius: CGFloat,
                angle: Angle = .zero,
                position: CGPoint = .zero,
                quality: PIX.SampleQualityMode = .mid) -> FX {
        fx { pix in
            let blurPix = BlurPIX()
            blurPix.input = pix
            blurPix.radius = radius
            blurPix.style = style
            blurPix.angle = angle.degrees / 360
            blurPix.position = position
            blurPix.quality = quality
            return blurPix
        }
    }
    
    func fxEdge(strength: CGFloat = 10.0,
                distance: CGFloat = 1.0) -> FX {
        fx { pix in
            let edgePix = EdgePIX()
            edgePix.input = pix
            edgePix.strength = strength
            edgePix.distance = distance
            edgePix.includeAlpha = true
            return edgePix.primaryAlpha()
        }
    }
    
    func fxDisplace<Content: View>(distance: CGFloat, with content: () -> (Content)) -> FX {
        fx { pix in
            let displacePix = DisplacePIX()
            displacePix.inputA = pix
            displacePix.inputB = content().pix()
            displacePix.distance = distance
            return displacePix
        }
    }
    
    func fxDisplaceNoise(distance: CGFloat = 0.1,
                         octaves: Int = 10,
                         zPosition: CGFloat = 0.0) -> FX {
        fx { pix in
            let noisePix = NoisePIX(at: ._1024)
            noisePix.colored = true
            noisePix.octaves = octaves
            noisePix.zPosition = zPosition
            let displacePix = DisplacePIX()
            displacePix.placement = .fill
            displacePix.inputA = pix
            displacePix.inputB = noisePix
            displacePix.distance = distance
            return displacePix
        }
    }
    
    func fxRainbowBlur(_ value: CGFloat) -> FX {
        fx { $0.pixRainbowBlur(value) }
    }
    
    func fxClamp(low: CGFloat = 0.0, high: CGFloat = 1.0) -> FX {
        fx { $0.pixClamp(low: low, high: high) }
    }
    
    func fxKaleidoscope(divisions: Int = 12, mirror: Bool = true) -> FX {
        fx { $0.pixKaleidoscope(divisions: divisions, mirror: mirror) }
    }
    
    func fxBrightness(_ value: CGFloat) -> FX {
        fx { $0.pixBrightness(value) }
    }
    
    func fxDarkness(_ value: CGFloat) -> FX {
        fx { $0.pixDarkness(value) }
    }
    
    func fxContrast(_ value: CGFloat) -> FX {
        fx { $0.pixContrast(value) }
    }
    
    func fxGamma(_ value: CGFloat) -> FX {
        fx { $0.pixGamma(value) }
    }
    
    func fxInvert() -> FX {
        fx { $0.pixInvert() }
    }
    
    func fxOpacity(_ value: CGFloat) -> FX {
        fx { $0.pixOpacity(value) }
    }
    
    func fxQuantize(fraction: CGFloat = 0.1) -> FX {
        fx { $0.pixQuantize(fraction) }
    }
    
    func fxSharpen(_ value: CGFloat = 2.0) -> FX {
        fx { $0.pixSharpen(value) }
    }
    
    func fxSlope(_ value: CGFloat = 1.0) -> FX {
        fx { $0.pixSlope(value) }
    }
    
    func fxThreshold(_ value: CGFloat = 0.5) -> FX {
        fx { $0.whiteOnBlack().pixThreshold(value).primaryAlpha() }
    }
    
    func fxTwirl(_ value: CGFloat = 2.0) -> FX {
        fx { $0.pixTwirl(value) }
    }
    
    @available(iOS 14.0, *)
    @available(macOS 11.0, *)
    func fxRange(inLow: Color = .black, inHigh: Color = .white, outLow: Color = .black, outHigh: Color = .white) -> FX {
        fx { $0.pixRange(inLow: PixelColor(inLow), inHigh: PixelColor(inHigh), outLow: PixelColor(outLow), outHigh: PixelColor(outHigh)) }
    }
    
    func fxRange(inLow: CGFloat = 0.0, inHigh: CGFloat = 1.0, outLow: CGFloat = 0.0, outHigh: CGFloat = 1.0) -> FX {
        fx { $0.pixRange(inLow: inLow, inHigh: inHigh, outLow: outLow, outHigh: outHigh) }
    }
    
    func fxSaturation(_ value: CGFloat) -> FX {
        fx { $0.pixSaturation(value) }
    }
    
    func fxMonochrome() -> FX {
        fxSaturation(0.0)
    }
    
    func fxHue(_ value: CGFloat) -> FX {
        fx { $0.pixHue(value) }
    }
    
    @available(iOS 14.0, *)
    @available(macOS 11.0, *)
    func fxSepia(color: Color) -> FX {
        fx { imagePix in
            let sepiaPix = SepiaPIX()
            sepiaPix.input = imagePix
            sepiaPix.color = PixelColor(color)
            return sepiaPix
        }
    }
    
    func fxFlipX() -> FX {
        fx { $0.pixFlipX() }
    }
    
    func fxFlipY() -> FX {
        fx { $0.pixFlipY() }
    }
    
    func fxFlopLeft() -> FX {
        fx { $0.pixFlopLeft() }
    }
    
    func fxFlopRight() -> FX {
        fx { $0.pixFlopRight() }
    }
}
