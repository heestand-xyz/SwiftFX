<img src="https://github.com/hexagons/SwiftFX/blob/master/Assets/Banner/SwiftFX.png?raw=true" height="256"/>

Powered by Metal through [PixelKit](https://github.com/hexagons/pixelkit)


## Example

```swift
import SwiftUI
import SwiftFX
```

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .fxEdge()
                .fxBlur(style: .zoom, radius: 0.5)
        }
    }
}
```
| <img src="https://github.com/hexagons/SwiftFX/blob/master/Assets/Text/hello_world.png?raw=true" width="256"/> | <img src="https://github.com/hexagons/SwiftFX/blob/master/Assets/Text/hello_world_edge.png?raw=true" width="256"/> | <img src="https://github.com/hexagons/SwiftFX/blob/master/Assets/Text/hello_world_edge_zoom_blur.png?raw=true" width="256"/> |
| --- | --- | --- |
|  `Text("Hello, World!")`  |  `.fxEdge()`  |  `.fxBlur(style: .zoom)`  |


## Install

```swift
.package(url: "https://github.com/heestand-xyz/SwiftFX.git", from: "1.0.0")
```

## Effects

```swift

func fxBlur(style, radius, angle, position, quality) -> FX

func fxEdge(strength, distance) -> FX

func fxDisplace(distance, view) -> FX

func fxDisplaceNoise(distance, octaves, zPosition) -> FX

func fxRainbowBlur(_) -> FX

func fxClamp(low, high) -> FX

func fxKaleidoscope(divisions, mirror) -> FX

func fxBrightness(_) -> FX

func fxDarkness(_) -> FX

func fxContrast(_) -> FX

func fxGamma(_) -> FX

func fxInvert() -> FX

func fxOpacity(_) -> FX

func fxQuantize(fraction) -> FX

func fxSharpen(_) -> FX

func fxSlope(_) -> FX

func fxThreshold(_) -> FX

func fxTwirl(_) -> FX

func fxRange(inLow, inHigh, outLow, outHigh) -> FX

func fxSaturation(_) -> FX

func fxMonochrome() -> FX

func fxHue(_) -> FX

func fxSepia(color) -> FX

func fxFlipX() -> FX

func fxFlipY() -> FX

func fxFlopLeft() -> FX

func fxFlopRight() -> FX
```
