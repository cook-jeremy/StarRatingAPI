# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a star rating view. For example:

<img width="133" alt="Screenshot 2023-12-07 at 11 02 58 PM" src="https://github.com/cook-jeremy/StarRatingAPI/assets/12803067/ae6806b4-7bd9-4196-a8d6-450aab83ad6a">

We call this new view `Rating`.  The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars. The aim is to provide a consistent rating experience across all Apple platforms, while also providing customizability for specific apps.

## Sandbox
TODO

## Detailed Design
The initializer for `Rating` has only one required parameter: a binding to the value of the rating, which must conform to the `BinaryFloatingPoint` protocol (e.g. `Float`, `Double`). The rest of the initialization parameters customize the holistic features of the `Rating`, and each has a default value:
- **Granularity:** The discrete step size by which symbols can be filled. A granularity of 1 indicates an integer step size, so each symbol can either be empty or completely filled. A granularity of 0.5 indicates a half-integer step size, so each symbol can be empty, half filled, or completely filled. A granularity of 0.25 indicates a quarter-integer step size, and so on. A granularity of 0 indicates an extremely small step size (the maximum precision of `CGFloat`), which gives the appearance of a continuous scale. The valid range of granularity is `0...1`, and the default is 1.
- **Spacing:** The spacing between symbols. The valid range of spacing is `0...`, and the default is that of `HStack`.
- **Count:** The number of symbols. The valid range of count is `1...100`, and the default is 5.

The API for the initializer of `Rating` is:
```swift
public struct Rating: View {
	public init<Value>(
        value: Binding<Value>,
        granularity: CGFloat = 1,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where Value: BinaryFloatingPoint
}
```

`Rating` provides a default gesture interaction for selecting a rating: the user can simply tap to update the rating value, or tap and drag to update the rating value. This is implemented as a drag gesture with a minimum drag distance of 0. The gesture works even if the user taps in between symbols, or drags out of bounds of the `Rating`. If the user taps in between two symbols, the resulting value is that of the leading symbol. For example, if the user taps between the second and third symbol, the value is updated to 2. If the user taps inside of a symbol, the resulting value is updated to the ceiling of the step size specified by the `granularity` parameter. For example, with a granularity of 0.5, if a user taps on the second symbol at 1/4 of the width of the symbol (i.e. a tap location of 1.25), the resulting value will update to 1.5. If the user drags out of bounds off the trailing edge of the view, the value will be updated to the maximum value. If the user drags out of bounds off the leading edge of the view, the value will be updated to the minimum value that is greater than zero (i.e. the granularity).

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
To define a custom rating style, create a type which conforms to `RatingStyle` by implementing the `makeBody(configuration:index:)` method. This method is responsible for drawing the symbol at index `index` in the `Rating` view. For example, a `Rating` with a `count` of 5 will call the `makeBody` method 5 times with indices 0, 1, 2, 3, and 4. Use the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's current value and count. The implementation should return a view which has the appearance and behavior of the symbol at index `index` in the rating with value `configuration.value`.

For example, here's a rating style that draws circle symbols instead of star symbols:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
		Image(systemName: index < Int(configuration.value) ? "circle.fill" : "circle")
    }
}
```

To apply a rating style to a `Rating`, the API provides a convenience method on `View`:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S: RatingStyle
}
```
This method will propagate the rating style to all `Rating` views within the view hierarchy. If we create a `circle` static variable for the `CircleRatingStyle` from earlier, we can apply the style to each `Rating` in the following view hierarchy:
```swift
VStack {
    Rating(value: .constant(3.2))
    Rating(value: .constant(4.6))
}
.ratingStyle(.circle)
```

To facilitate easy modification of an existing style rather than implementing an entirely new one, we provide an additional initializer for `Rating`:
```swift
extension Rating {
    public init(configuration: RatingStyleConfiguration, index: Int)
}
```
For example, the `RedBorderRatingStyle` below adds a red border to each rating symbol while retaining the rating's current style:
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
Apply the custom style closer to the rating than the modified style because the framework evaluates style view modifiers in order from outermost to innermost. If you apply the styles in the opposite order, the red border style doesn't have an effect, because the built-in styles override it completely.

We also offer an API to easily create a `RatingStyle` using system images:
```swift
struct SystemImageRatingStyle: RatingStyle {
    var systemName: String
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
		Image(systemName: index < Int(configuration.value) ? "\(systemName).fill" : systemName)
    }
}
```
There are over 2,000 SF Symbols which have a `.fill` counterpart (like `circle` and `circle.fill`), so only the name before the `.fill` needs to be provided. The `CircleRatingStyle` from earlier can be implemented as:
```swift
Rating(value: $value)
	.ratingStyle(SystemImageRatingStyle(systemName: "circle"))
```

## Alternatives Considered
### Alternative 1
The `RatingStyleConfiguration` casts the type of `Value` used in the initializer of `Rating` to a `Double`. This is because not much is gained....

We considered a `RatingStyleConfiguration` that's generic over the type `Value` used in the initializer of `Rating`, so that a custom style can decide how to draw a symbol using the original `BinaryFloatingPoint` type:
```swift
public protocol RatingStyle {
    @ViewBuilder func makeBody(
	    configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, 
	    index: Int
    ) -> any View
}

public struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    public var value: Value
    public let count: Int
}
```
However, not much is gained by keeping the concrete type of `Value` using generics. A rating's style applies regardless of the type of `Value` used in each `Rating` in the view hierarchy, because they deal with independent concerns: the style specifies how a rating is drawn, and the type of `Value` specifies how a rating's value is represented in memory. For example, the difference between drawing a rating symbol whose value type is `Double` (12-13 decimal digits of precision) vs `Float80` (19-20 decimal digits of precision) is minuscule and not visible when drawn.

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
Why an alternative gesture is not allowed...

Are these alternatives bad or future functionality?...

We considered providing a binding to the value of a rating in `RatingStyleConfiguration`, instead of a read-only value:
```swift
public struct RatingStyleConfiguration {
    @Binding var value: Double
    public let count: Int
}
```
This way a custom style can change the value of a rating, altering how a user interacts with the rating. However, the use cases of this are limited. The `makeBody` of `RatingStyle` creates the view for only one symbol, so the custom style can't create a new gesture which covers the entire view, only a new gesture on each symbol. One could add a `.onTapGesture` modifier on each symbol which updates the rating value to the tapped symbol. This would override the drag gesture provided by the framework, but only when the user taps on the symbols. If the user starts a drag in the space between the symbols, they will still be able to drag to change the value.

If we look at all the custom styles in the SwiftUI framework, there is only one other style which provides a binding: `ToggleStyle`. `Toggle` has a genuine use case for this binding, because how a `Toggle` is switched on and off has options for customization, for example a rocker switch vs a tap button. The gesture interaction for choosing a rating is more universally defined, so it is not necessary to provide customizability in this aspect. In fact, limiting the type of interaction to a drag gesture improves consistency across platforms and apps, so users are less confused when providing ratings in Apple apps and third party apps.
### Alternative 3
Loss of framework provided gesture and structure

We considered a `RatingStyle` whose `makeBody` creates the appearance and behavior of *all* symbols in the rating view, instead of each symbol. The advantage of such a configuration allows for greater customization, at the cost of greater complexity for the developer and the loss of a framework provided gesture. If the user creates a custom style which includes all the symbols, they are responsible for handling how a value is selected based on the interaction with the view. For example, such an implementation would look like:
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
`Rating` no longer has knowledge of the structure of the view. The custom style above could use a `VStack` instead of an `HStack`, so `Rating` can't provide the gesture logic for selecting a new value because it doesn't know the layout of the symbols in the view. If the user wants the same drag-to-rate gesture as the default implementation in their view, they have to implement it from scratch themselves. At that point, they aren't gaining much by using a `Rating` view.
### Alternative 4
We considered using a `@ViewBuilder` closure to define the appearance of each symbol. The `Rating` initializer would be:
```swift
struct Rating<Symbol>: View where Symbol: View {
    public init<Value>(
        value: Binding<Value>,
        spacing: CGFloat? = nil,
        count: Int = 5,
        @ViewBuilder symbol: (_ index: Int) -> Symbol
    ) where Value: BinaryFloatingPoint
}
```

The `CircleRatingStyle` from before could then be implemented as:
```swift
Rating(value: $value) { index in
    Image(systemName: index < Int(value) ? "circle.fill" : "circle")
}
```
While this approach addresses basic customization needs, it introduces limitations and complexities. If a user wants to apply a consistent style across multiple `Rating` views within the app, they're forced to implement this closure in every place, or to create a wrapper view that encapsulates this closure. This leads to more repetitive and verbose code, compared to applying one `.ratingStyle(_:)` modifier at the root of the view hierarchy. This approach also doesn't allow for styles to be composed, like the `.redBorder` and `.circle` rating styles from earlier.

Although the `@ViewBuilder` approach provides a straightforward method for customization, the `RatingStyle` protocol aligns more closely with SwiftUI's design philosophy, which emphasizes reusable components and consistent styling. `RatingStyle` presents a more structured and scalable method for customizing the appearance of rating views, which not only ensures consistency across the application but also with the SwiftUI framework.
# Examples
Here's a rating style which supports half-integer star ratings using SF Symbols:
```swift
struct HalfStarRatingStyle: RatingStyle {
    func makeBody(configuration: RatingStyleConfiguration, index: Int) -> some View {
		if index < Int(configuration.value) {
			Image(systemName: "star.fill")
		} else if CGFloat(index) <= configuration.value - 0.5 {
			Image(systemName: "star.leadinghalf.filled")
		} else {
			Image(systemName: "star")
		}
    }
}
```