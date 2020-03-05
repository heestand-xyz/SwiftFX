#if os(macOS)
import Cocoa
#else
import UIKit
#endif
import CoreGraphics
import SwiftUI
import LiveValues
import RenderKit
import PixelKit

public typealias FX = NODERepView

#if os(macOS)
public typealias _Color = NSColor
#else
public typealias _Color = UIColor
#endif

var didSetup: Bool = false
var didSetLib: Bool = false

func setup() {
    guard didSetLib else { return }
    guard !didSetup else { return }
    #if DEBUG
//    PixelKit.main.logDebug()
    #else
    PixelKit.main.disableLogging()
    #endif
    didSetup = true
}

func setLib(url: URL) {
    guard !didSetLib else { return }
    guard FileManager.default.fileExists(atPath: url.path) else { return }
    pixelKitMetalLibURL = url
    didSetLib = true
    setup()
}

public func fxMetalLib(url: URL) {
    setLib(url: url)
}

extension View {
    func pix() -> ViewPIX {
        let view: UIView = UIHostingController(rootView: self).view
        view.backgroundColor = .clear
        let viewPix = ViewPIX()
        viewPix.renderView = view
        return viewPix
    }
    func fx(edit: (PIX & NODEOut) -> (PIX)) -> FX {
        #if DEBUG && os(macOS)
        setLib(url: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Code/Frameworks/Production/PixelKit/Resources/Metal Libs/PixelKitShaders-macOS.metallib"))
        #endif
        guard didSetup else { fatalError("please call fxMetalLib(url:)") }
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
        darkPix.alphaChannel = .lum
        let lightPix = ReorderPIX()
        lightPix.inputA = self as? PIX & NODEOut
        lightPix.inputB = self as? PIX & NODEOut
        lightPix.redChannel = .lum
        lightPix.greenChannel = .lum
        lightPix.blueChannel = .lum
        lightPix.alphaChannel = .lum
        let crossPix = CrossPIX()
        crossPix.inputA = darkPix
        crossPix.inputB = lightPix
        crossPix.fraction = LiveBool.darkMode <?> 1.0 <=> 0.0
        return crossPix
    }
}

public extension View {
    
    func fxBlur(style: BlurPIX.BlurStyle = .regular,
                radius: Binding<CGFloat>,
                angle: Binding<CGFloat> = .constant(0.0),
                position: Binding<CGPoint> = .constant(.zero),
                quality: PIX.SampleQualityMode = .mid) -> FX {
        fx { pix in
            let blurPix = BlurPIX()
            blurPix.input = pix
            blurPix.radius = LiveFloat({ radius.wrappedValue })
            blurPix.style = style
            blurPix.angle = LiveFloat({ angle.wrappedValue })
            blurPix.position = LivePoint({ position.wrappedValue })
            blurPix.quality = quality
            return blurPix
        }
    }
    
    func fxEdge(strength: Binding<CGFloat> = .constant(10.0),
                distance: Binding<CGFloat> = .constant(1.0)) -> FX {
        fx { pix in
            let edgePix = EdgePIX()
            edgePix.input = pix
            edgePix.strength = LiveFloat({ strength.wrappedValue })
            edgePix.distance = LiveFloat({ distance.wrappedValue })
            edgePix.includeAlpha = true
            return edgePix.primaryAlpha()
        }
    }
    
    func fxDisplace<Content: View>(distance: Binding<CGFloat> = .constant(0.1), with content: () -> (Content)) -> FX {
        fx { pix in
            let displacePix = DisplacePIX()
            displacePix.inputA = pix
            displacePix.inputB = content().pix()
            displacePix.distance = LiveFloat({ distance.wrappedValue })
            return displacePix
        }
    }
    
    func fxDisplaceNoise(distance: Binding<CGFloat> = .constant(0.1),
                         octaves: Binding<Int> = .constant(10),
                         zPosition: Binding<CGFloat> = .constant(0.0)) -> FX {
        fx { pix in
            let noisePix = NoisePIX(at: ._1024)
            noisePix.colored = true
            noisePix.octaves = LiveInt({ octaves.wrappedValue })
            noisePix.zPosition = LiveFloat({ zPosition.wrappedValue })
            let displacePix = DisplacePIX()
            displacePix.placement = .aspectFill
            displacePix.inputA = pix
            displacePix.inputB = noisePix
            displacePix.distance = LiveFloat({ distance.wrappedValue })
            return displacePix
        }
    }
    
    func fxRainbowBlur(_ value: Binding<CGFloat>) -> FX {
        fx { $0._rainbowBlur(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxClamp(low: Binding<CGFloat> = .constant(0.0), high: Binding<CGFloat> = .constant(1.0)) -> FX {
        fx { $0._clamp(low: LiveFloat({ low.wrappedValue }), high: LiveFloat({ high.wrappedValue })) }
    }
    
    func fxKaleidoscope(divisions: Binding<Int> = .constant(12), mirror: Binding<Bool> = .constant(true)) -> FX {
        fx { $0._kaleidoscope(divisions: LiveInt({ divisions.wrappedValue }), mirror: LiveBool({ mirror.wrappedValue })) }
    }
    
    func fxBrightness(_ value: Binding<CGFloat>) -> FX {
        fx { $0._brightness(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxDarkness(_ value: Binding<CGFloat>) -> FX {
        fx { $0._darkness(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxContrast(_ value: Binding<CGFloat>) -> FX {
        fx { $0._contrast(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxGamma(_ value: Binding<CGFloat>) -> FX {
        fx { $0._gamma(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxInvert() -> FX {
        fx { $0._invert() }
    }
    
    func fxOpacity(_ value: Binding<CGFloat>) -> FX {
        fx { $0._opacity(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxQuantize(fraction: Binding<CGFloat> = .constant(0.1)) -> FX {
        fx { $0._quantize(LiveFloat({ fraction.wrappedValue })) }
    }
    
    func fxSharpen(_ value: Binding<CGFloat> = .constant(2.0)) -> FX {
        fx { $0._sharpen(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxSlope(_ value: Binding<CGFloat> = .constant(1.0)) -> FX {
        fx { $0._slope(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxThreshold(_ value: Binding<CGFloat> = .constant(0.5)) -> FX {
        fx { $0.whiteOnBlack()._threshold(LiveFloat({ value.wrappedValue })).primaryAlpha() }
    }
    
    func fxTwirl(_ value: Binding<CGFloat> = .constant(2.0)) -> FX {
        fx { $0._twirl(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxRange(inLow: Binding<_Color> = .constant(.black), inHigh: Binding<_Color> = .constant(.white), outLow: Binding<_Color> = .constant(.black), outHigh: Binding<_Color> = .constant(.white)) -> FX {
        fx { $0._range(inLow: LiveColor({ inLow.wrappedValue }), inHigh: LiveColor({ inHigh.wrappedValue }), outLow: LiveColor({ outLow.wrappedValue }), outHigh: LiveColor({ outHigh.wrappedValue })) }
    }
    
    func fxRange(inLow: Binding<CGFloat> = .constant(0.0), inHigh: Binding<CGFloat> = .constant(1.0), outLow: Binding<CGFloat> = .constant(0.0), outHigh: Binding<CGFloat> = .constant(1.0)) -> FX {
        fx { $0._range(inLow: LiveFloat({ inLow.wrappedValue }), inHigh: LiveFloat({ inHigh.wrappedValue }), outLow: LiveFloat({ outLow.wrappedValue }), outHigh: LiveFloat({ outHigh.wrappedValue })) }
    }
    
    func fxSaturation(_ value: Binding<CGFloat>) -> FX {
        fx { $0._saturation(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxMonochrome() -> FX {
        fxSaturation(.constant(0.0))
    }
    
    func fxHue(_ value: Binding<CGFloat>) -> FX {
        fx { $0._hue(LiveFloat({ value.wrappedValue })) }
    }
    
    func fxSepia(color: Binding<_Color>) -> FX {
        fx { imagePix in
            let sepiaPix = SepiaPIX()
            sepiaPix.input = imagePix
            sepiaPix.color = LiveColor({ color.wrappedValue })
            return sepiaPix
        }
    }
    
    func fxFlipX() -> FX {
        fx { $0._flipX() }
    }
    
    func fxFlipY() -> FX {
        fx { $0._flipY() }
    }
    
    func fxFlopLeft() -> FX {
        fx { $0._flopLeft() }
    }
    
    func fxFlopRight() -> FX {
        fx { $0._flopRight() }
    }
    
}
