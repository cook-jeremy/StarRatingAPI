# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a star rating view. For example:
<img width="133" alt="Screenshot 2023-12-07 at 11 02 58 PM" src="https://github.com/cook-jeremy/StarRatingAPI/assets/12803067/ae6806b4-7bd9-4196-a8d6-450aab83ad6a">
We call this new view `Rating`.  The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars. The aim is to provide a consistent rating experience across all Apple platforms, while also providing ample customizability for specific apps.

## Detailed Design
The initializer for `Rating` has only one required parameter: a binding to the value of the rating, which must conform to the `BinaryFloatingPoint` protocol (e.g. `Float`, `Double`). The rest of the initialization parameters customize the holistic features of a `Rating`, and each has a default value:
- **Granularity:** The step size by which symbols are filled. A granularity of 1 indicates an integer step size, so each symbol is either empty or completely filled. A granularity of 0.5 indicates a half-integer step size, 0.25 indicates a quarter-integer step size, etc. A granularity of 0 indicates an extremely small step size (the maximum precision of `Double`). The valid range of granularity is `0...1`.
- **Spacing:** The spacing between symbols. The default spacing is that of `HStack`.
- **Count:** The number of symbols. The default is 5. The minimum is 1.

The API for the initializer of `Rating` is:
```swift
public struct Rating: View {
	public init<Value>(
        value: Binding<Value>,
        granularity: Value = 1,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where Value: BinaryFloatingPoint
}
```
The main benefit of `Rating` over an `HStack` of symbols is the gesture interaction it provides. The user can tap or drag to choose a rating. The gesture works even if the user taps in between symbols, or drags out of bounds. The resulting value is the ceiling of the closest step size specified by the `granularity` parameter. For example, if a user taps at location 3.2 with a granularity of 0.5, the value will update to 3.5. If the user taps in the space between the first symbol and the second symbol, the value will update to 1.

To draw custom symbols, we introduce a `RatingStyle` protocol, along with a `RatingStyleConfiguration` struct for accessing the rating's current value and symbol count:
```swift
public protocol RatingStyle {
	associatedtype Body: View
    @ViewBuilder func makeBody(configuration: RatingStyleConfiguration, index: Int) -> Body
}

public struct RatingStyleConfiguration {
    public var value: Double
    public let count: Int
}
```
To define a custom rating style, create a type which conforms to `RatingStyle` by implementing the `makeBody(configuration:index:)` method. This method is responsible for drawing the symbol at `index` in the `Rating` view. For example, a `Rating` with a `count` of 5 will call the `makeBody` method 5 times with indices 0, 1, 2, 3, and 4. Utilize the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's current value and count. The implementation should return a view which has the appearance and behavior of the symbol at `index` in the rating with value `configuration.value`.

For example, here's a rating style that draws circle symbols instead of star symbols:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
		Image(systemName: index < Int(configuration.value) ? "circle.fill" : "circle")
    }
}
```

Here's a rating style which supports half-integer star ratings:
```swift
struct HalfStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
		if index < Int(configuration.value) {
			Image(systemName: "star.fill")
		} else if Double(index) <= configuration.value - 0.5 {
			Image(systemName: "star.leadinghalf.filled")
		} else {
			Image(systemName: "star")
		}
    }
}
```

To apply a rating style to a `Rating`, the API provides a convenience method on `View`:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S: RatingStyle
}
```
This method will propagate the style to all `Rating` views within the view hierarchy. If we create a `circle` static variable from the `CircleRatingStyle`, we can apply the style to each `Rating` in the following:
```swift
VStack {
    Rating(value: .constant(Float(3.2)))
    Rating(value: .constant(Double(4.6)))
}
.ratingStyle(.circle)
```

To facilitate easy modification of an existing style rather than implementing an entirely new one, we provide an additional initializer:
```swift
extension Rating {
    public init(configuration: RatingStyleConfiguration, index: Int)
}
```

This initializer is particularly useful for custom rating styles that aim to modify the existing style rather than implementing an entirely new one. For instance, the `RedBorderRatingStyle` below adds a red border to the rating while retaining the rating's current style:
```swift
struct RedBorderRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
        Rating(configuration: configuration, index: index)
            .padding()
            .border(.red)
    }
}
```

If we create a `redBorder` static variable from this style, we can apply the style to ratings that already use another style, like the `circle` style from earlier:
```swift
Rating(value: $value)
    .ratingStyle(.redBorder)
    .ratingStyle(.circle)
```
Apply the custom style closer to the rating than the modified style because the framework evaluates style view modifiers in order from outermost to innermost. If you apply the styles in the other order, the red border style doesn't have an effect, because the built-in styles override it completely.
## Alternatives Considered
### Alternative 1
We considered making `RatingStyleConfiguration` generic over the type `Value` used in the `Rating`, so that a custom style can decide how to draw a symbol using the original `BinaryFloatingPoint` type:
```swift
public protocol RatingStyle {
    @ViewBuilder func makeBody(
	    configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, 
	    index: Int
    ) -> any View
}

public struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    public var value: Value
    public let spacing: CGFloat
    public let count: Int
}
```
However, not much is gained by keeping the concrete type of `Value` using generics. A rating's style applies regardless of the type of `Value` used in each `Rating` in the view hierarchy, because they deal with independent concerns: the style specifies how a rating is drawn, and the type of `Value` specifies how a rating's value is represented in memory. The difference between drawing a rating symbol using a `Double` (12-13 decimal digits of precision) vs a `Float80` (19-20 decimal digits of precision) is minuscule and often not visible when drawn.

We also have to erase the result type of `makeBody` from `some View` to `any View`. Associated type inference can only infer an opaque result type for a non-generic requirement, because the opaque type can be parameterized by the function's own generic arguments. For example, consider:
```swift
protocol Recipe {
	associatedtype Dish: Recipe
	func makeDish<Ingredient: Recipe>(ingredient: Ingredient) -> Dish
}

struct Chef: Recipe {
	func makeDish<Ingredient: Recipe>(ingredient: Ingredient) -> some Recipe {
		return ingredient
	}
}
```
There is no single underlying type to infer `Dish` because it depends on the generic parameter `Ingredient` which is allowed to change with the caller. The only way around it is to type erase the parameter or the return value. In our case, erasing `some View` to `any View` in `makeBody` leads to less efficient view diffing, so view updates of `Rating` aren't as efficient because the type of our view hierarchy is erased.
### Alternative 2
We also considered providing a binding to the value of a rating in `RatingStyleConfiguration`, instead of a read-only value:
```swift
public struct RatingStyleConfiguration {
    @Binding var value: Double
    public let spacing: CGFloat
    public let count: Int
}
```
This way a custom style can alter the interaction of a rating. However, the use cases of this are limited. The `makeBody` of `RatingStyle` creates the view for only one symbol, so the custom style can't create a new gesture which covers the entire view. If we look at all the custom styles in the SwiftUI framework, there is only one other style which provides a binding: `ToggleStyle`. `Toggle` has a genuine use case for this binding, because how a `Toggle` is switched on and off has many options for customization (rocker switch vs tap button). The gesture for choosing a rating is more universally defined, so it is not as necessary to provide customizability in this aspect. Further, limiting the type of interaction to a drag gesture helps with consistency across platforms and apps.
### Alternative 3
We considered a `RatingStyle` whose `makeBody` creates the appearance and behavior of *all* symbols in the rating view, instead of each symbol. The advantage of such a configuration allows for greater customization, at the loss of a framework provided gesture. If the user creates a custom style which includes all the symbols, they are responsible for handling how a value is selected based on the tap location and subsequent drag gestures. For example, such an implementation would look like:
```swift
struct StarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration) -> some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                Image(systemName: i < Int(configuration.value) ? "star.fill" : "star")
                    .onTapGesture {
                        configuration.value = Double(i + 1)
                    }
            }
        }
    }
}
```
`Rating` no longer has knowledge of the structure of the view (e.g. the custom style could use a `VStack` instead of an `HStack`), so it can't provide the logic for selecting a new value based on gestures in the view. If the user wants the same drag-to-rate gesture as the default implementation in their view, they have to implement it from scratch themselves. At that point, they aren't gaining anything by using a `Rating` view.
### Alternative 4
Another method for customizing the `Rating` view was considered, involving the use of a `@ViewBuilder` closure to define the appearance of each symbol. The `Rating` initializer would be:
```swift
struct Rating<Symbol>: View where Symbol: View {
    public init<V>(
        value: Binding<V>,
        spacing: CGFloat? = nil,
        count: Int = 5,
        @ViewBuilder symbol: (_ index: Int) -> Symbol
    ) where V: BinaryFloatingPoint
}
```

The `CircleRatingStyle` from before could then be implemented as:
```swift
Rating(value: $value) { index in
    Image(systemName: > index < Int(value) ? "circle.fill" : "circle")
}
```
While this approach addresses basic customization needs, it introduces limitations and complexities. Having only the `index` parameter limits the customization to the individual symbol level. If a user wants to apply a consistent style across multiple `Rating` views within the app, they're forced to implement this closure in every place, or to create a wrapper view that encapsulates this closure. This leads to more repetitive and verbose code, compared to applying one `.ratingStyle(_:)` modifier at the root of the view hierarchy.

Although the `@ViewBuilder` approach provides a straightforward method for customization, the `RatingStyle` protocol aligns more closely with SwiftUI's design philosophy, which emphasizes reusable components and consistent styling. `RatingStyle` presents a more structured and scalable method for customizing the appearance of rating views, which not only ensures consistency across the application but also with the SwiftUI framework.
### Alternative 5
Given there are over 2,000 SF Symbols which have a `.fill` counterpart (like `star` and `star.fill`), we considered offering an API to easily create a custom `RatingStyle`  using system images:
```swift
struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    var fillSystemImage: String
    func makeBody(configuration: Configuration, index: Int) -> some View
}
```
However, this creates a dependency on SF Symbols just for the convenience of implementing a simple rating, which is not worth the trade-off.

# To-do
- Support for animations
- Support for watchOS scrolling and tvOS scrolling interaction
- Gesture bug after view resizing
- Maximum value for symbol count

# Market Research
We explore the current space of star rating UIs to identify customization parameters that are important to developers.

- App Store
	- Individual rating
		- Integer star increments
		- Interactive version:
			- Blue filled star and blue bordered star
			- Tap to rate
			- Tap-and-drag to rate
			- Slightly different star shape
		- Non-interactive version:
			- Orange filled star and orange bordered star
	- Average rating
		- Non-interactive
		- One decimal precision increments
		- Star is precisely filled to represent floating point rating
		- Has label (for ex: 4.6) above rating in big font

Customization parameters:
- Individual star style
	- Color, shape, border, background, shadow, gradient
	- Fill precision, i.e. how draw a star filled to X%
- Wholistic rating style
	- Spacing between stars
	- Number of stars
	- Orientation of rating (vertical, horizontal, right-to-left, left-to-right)
	- Label above rating
	- Gradient across stars

# Useful Links
https://forums.swift.org/t/type-erasing-in-swift-anyview-behind-the-scenes/27952/9
