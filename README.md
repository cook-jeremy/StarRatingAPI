# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a star rating view, called `Rating`.  The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars. The aim is to provide a consistent rating experience across all Apple platforms, while also providing ample customizability for individualized apps.

<img width="133" alt="Screenshot 2023-12-07 at 11 02 58 PM" src="https://github.com/cook-jeremy/StarRatingAPI/assets/12803067/ae6806b4-7bd9-4196-a8d6-450aab83ad6a">
## Detailed Design
The `Rating` View has only one required parameter: a binding to a type which conforms to `BinaryFloatingPoint`, representing the rating. It also offers several optional customization parameters, each with a default value:
- **Spacing:** The spacing between stars. The default spacing is that of `HStack`.
- **Count:** The number of stars, defaults to 5.
- **Precision:** The increment precision between ratings. A value of 1 indicates integer ratings, 0.5 indicates half-integer ratings, etc. The default value is 1.

The initializer for `Rating` is structured as follows:
```swift
public struct Rating<Value: BinaryFloatingPoint>: View {
    public init(
        value: Binding<Value>,
        precision: Value? = nil,
        spacing: CGFloat? = nil,
        count: Int = 5
    )
}
```
This initializer provides basic customization for the style of a `Rating`. For further customization, we introduce a `RatingStyle` protocol along with a convenience function on `View` for applying such a style to an entire view hierarchy:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle
}
```

A rating's style should be agnostic to the type of its value, because they deal with independent concerns. A rating's style specifies how a rating is drawn, and the type of a rating's value specifies how the value is represented in memory. For example, the following `CircleRatingStyle` should apply to each `Rating` regardless of the type used for it's value:
```swift
VStack {
    Rating(value: .constant(Float(3.2)))
    Rating(value: .constant(Double(4.6)))
}
.ratingStyle(CircleRatingStyle())
```
To support this, the `RatingStyle` protocol needs to use an opaque type for the value of the `RatingStyleConfiguration`, and return:


```swift
public protocol RatingStyle {
    @ViewBuilder func makeBody<Value: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<Value>) -> AnyView
}

public struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    @Binding public var value: Value { get nonmutating set }
    public var count: Int
    public var spacing: CGFloat
}
```
To define a custom rating style, create a type which conforms to `RatingStyle` by implementing the `makeBody(configuration:)` method. This method is responsible for generating the view for *all* the stars in the `Rating` View. Utilize the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's value, star count, and spacing. The implementation should return a view which has the appearance and behavior of all of the stars in the rating view. The return type of `makeBody(configuration:)` is `AnyView`, because 

For example, here's how to create a `CircleRatingStyle`, which uses circles instead of stars:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeBody<Value: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<Value>) -> any View {
		HStack(spacing: configuration.spacing) {
			ForEach(0 ..< configuration.count, id: \.self) { i in
				let isFilled = Value(i) < configuration.value
				Image(systemName: isFilled ? "circle.fill" : "circle")
			}
		}
    }
}
```

The `ratingStyle(_:)` modifier is defined on View, so we can apply a style to any view hierarchy, allowing the style to propagate to all `Rating` views within. Apply this modifier to a `Rating` instance or the surrounding view hierarchy to define the appearance and behavior of a rating view. For instance, using the previously defined `CircleRatingStyle`:
```swift
Rating(value: $value)
    .ratingStyle(CircleRatingSyle())
```

To facilitate easy creation of a `Rating` view based on a specific configuration, use the following initializer:
```swift
extension Rating {
    public init(_ configuration: RatingStyleConfiguration<Value>)
}
```
This initializer is particularly useful for custom rating styles that aim to modify the existing style rather than implementing an entirely new one. For instance, the `RedBorderRatingStyle` below adds a red border to the rating while retaining the rating's current style:
```swift
struct RedBorderRatingStyle: RatingStyle {
    func makeBody(configuration: Configuration) -> some View {
        Rating(configuration)
            .padding()
            .border(.red)
    }
}
```

## Alternatives Considered
Many star rating UIs are symmetric across each star, or can be easily drawn based on the star index. With this symmetry, we could simplify the customization to focus on *each* star, instead of all stars. This tradeoff simplifies the styling of a star rating view, at the cost that each star is symmetric to one another and wholistic features which depend on multiple stars are harder or impossible to implement.

Another method for customizing the `Rating` view was considered, involving the use of a `@ViewBuilder` closure to define the appearance of each star. The `Rating` initializer would be:
```swift
struct Rating<Star>: View where Star: View {
    public init<V>(
        value: Binding<V>,
        spacing: CGFloat? = nil,
        count: Int = 5,
        @ViewBuilder starView: (_ isFilled: Bool) -> Star
    ) where V: BinaryFloatingPoint
}
```

The `CircleRatingStyle` from before could then be implemented as:
```swift
Rating(value: $value) { isFilled in
    Image(systemName: isFilled ? "circle.fill" : "circle")
}
```

While this approach addresses basic customization needs, it introduces limitations and complexities:
- **Limited Customization:** Having only the `isFilled` parameters limits the customization to the individual star level. It does not easily allow for broader styling such as animations or interactions that span multiple stars. 
- **Scalability:** If a user wants to apply a consistent style across multiple `Rating` views within the app, they're forced to implement this closure in every place, or to create a wrapper view and use that everywhere. This leads to more repetitive and verbose code, compared to applying one `.ratingStyle(_:)` modifier at the root of the view hierarchy.
- **Mixing of Functional and Stylistic Aspects:** Using `@ViewBuilder` directly in the `Rating` initializer intertwines the functional and stylistic code, leading to less maintainable and less readable code.

Therefore, although the `@ViewBuilder` approach provides a straightforward method for customization, the `RatingStyle` protocol aligns more closely with SwiftUI's design philosophy, which emphasizes reusable components and consistent styling. `RatingStyle` presents a more structured and scalable method for customizing the appearance of rating views, which not only ensures consistency across the application but also with the broader SwiftUI framework.

### Alternative 2
For ease of use, we considered a `RatingStyle` who's `makeBody(configuration:)` creates the appearance and behavior of of *each* star, instead of all stars. The advantage of such a configuration allows for easier creation of styles which are symmetric for each star.
### Alternative 3
Given there are over 2,000 SF Symbols which have a `.fill` counterpart (like `star` and `star.fill`), we offer an API to easily create a custom `RatingStyle`  using system images:
```swift
struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    var fillSystemImage: String
    func makeBody(configuration: Configuration) -> some View
}
```
However, this creates a dependency on SF Symbols just for the convenience of implementing a simple rating, which is not worth the trade-off.

# Type Erasure trade-off in `RatingStyle`
In order for a rating's style to be agnostic to the type of its value, the `makeBody` of `RatingStyle` should be generic over the parameter `RatingStyleConfiguration<Value>`. Then to use the resulting `View`, we want to return an opaque type for `View`.
```swift
protocol RatingStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody<Value: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<Value>) -> Body 
}
```
This protocol compiles fine, however, it's impossible to create a concrete type which conforms to this protocol. Associated type inference can only infer an opaque result type for a non-generic requirement, because the opaque type can be parameterized by the function's own generic arguments. For example, consider:
```swift
protocol Recipe {
	associatedtype Dish: Recipe
	func makeDish<Ingredient: Recipe>(ingredient: Ingredient) -> Dish
}

struct Chef: Recipe {
	func makeDish<Ingredient: Recipe>(ingredient: Ingredient) -> some Recipe {
		return x
	}
}
```
There is no single underlying type to infer `Dish` because it depends on the generic parameter `Ingredient` which is allowed to change with the caller.

In our case, it seems likely that the return type `some View` of `makeBody` will be independent of the type of the `Value` used in `RatingStyleConfiguration`. The style of the rating is independent of the type `Float` or `Double` used for the rating value. 


So we either need to type erase `RatingStyleConfiguration` over `Value`, or erase `some View` to `any View`.
## Erase `some View` to `any View`

## Erase `Value` in `RatingStyleConfiguration<Value>`


# Market Research
Before diving into the design, we first explore the current space of star rating UIs to identify customization parameters that are important to developers.

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

We'd like to accommodate to all of these typical use cases with one view: `Rating`, and two styles: