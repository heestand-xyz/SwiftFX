# SwiftFX

Powered by Metal through [PixelKit](https://github.com/hexagons/pixelkit)


## Install

~~~~swift
.package(url: "https://github.com/hexagons/SwiftFX.git", from: "0.1.0")
~~~~

## Setup

~~~~swift
#if os(iOS)
fxMetalLib(url: Bundle.main.url(forResource: "PixelKitShaders-iOS", withExtension: "metallib")!)
#elseif os(macOS)
fxMetalLib(url: URL(fileURLWithPath: "/path/to/PixelKitShaders-macOS.metallib"))
#endif
~~~~

You can find the latest Metal library from PixelKit [here](https://github.com/hexagons/PixelKit/tree/master/Resources/Metal%20Libs).

## Example

~~~swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .fxEdge()
    }
}
~~~

~~~swift
struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
            .font(.system(size: 50, weight: .bold, design: .rounded))
//            .fxEdge()
//            .fxBlur(style: .zoom, radius: .constant(0.25))
//            .fxDisplaceNoise(distance: .constant(0.25))
//            .fxFlipY()
//            .fxBlur(radius: .constant(0.1))
//            .blur(radius: 5)
//            .fxThreshold()
//            .fxKaleidoscope()
//            .fxTwirl()
    }
}
~~~

## Effects

~~~swift
func fxBlur(style:radius:angle:position:quality:) -> FX

func fxEdge(strength:distance:) -> FX

func fxDisplace(distance:with:) -> FX

func fxDisplaceNoise(distance:octaves:zPosition:) -> FX

func fxRainbowBlur(_:) -> FX

func fxClamp(low:high:) -> FX

func fxKaleidoscope(divisions:mirror:) -> FX

func fxBrightness(_:) -> FX

func fxDarkness(_:) -> FX

func fxContrast(_:) -> FX

func fxGamma(_:) -> FX

func fxInvert() -> FX

func fxOpacity(_:) -> FX

func fxQuantize(fraction:) -> FX

func fxSharpen(_:) -> FX

func fxSlope(_:) -> FX

func fxThreshold(_:) -> FX

func fxTwirl(_:) -> FX

func fxRange(inLow:inHigh:outLow:outHigh:) -> FX

func fxSaturation(_:) -> FX

func fxMonochrome() -> FX

func fxHue(_:) -> FX

func fxSepia(color:) -> FX

func fxFlipX() -> FX

func fxFlipY() -> FX

func fxFlopLeft() -> FX

func fxFlopRight() -> FX
~~~
