# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a star rating view called `Rating`.  The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars. The aim is to provide a consistent rating experience across all Apple platforms, while also providing customizability for individualized apps.

<img width="133" alt="Screenshot 2023-12-07 at 11 02 58 PM" src="https://github.com/cook-jeremy/StarRatingAPI/assets/12803067/ae6806b4-7bd9-4196-a8d6-450aab83ad6a">

## Detailed Design
`Rating` has only one required parameter: a binding to the value of the rating, which must conform to `BinaryFloatingPoint`. There rest of the parameters customize the wholistic features of a `Rating`, and have a default value each:
- **Precision:** The increment precision for each star. For example, a precision of 1 indicates integer star ratings, and 0.5 indicates half-integer star ratings. A precision of 0 indicates the maximum precision of the type specified for the rating value. The default precision is 1.
- **Spacing:** The spacing between stars. The default spacing is that of `HStack`.
- **Count:** The number of stars. The default is 5.

The API initializer for `Rating` is:
```swift
public struct Rating<Value: BinaryFloatingPoint>: View {
	public init(
        value: Binding<Value>,
        precision: Value = 1,
        spacing: CGFloat? = nil,
        count: Int = 5
    )
}
```
This initializer provides customization for the wholistic features of a `Rating`. To specify a custom style for the drawing of the star symbols, we introduce a `RatingStyle` protocol, along with a `RatingStyleConfiguration` struct for accessing the rating's value, count, and spacing:
```swift
public protocol RatingStyle {
    @ViewBuilder func makeStar(
	    configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, 
	    index: Int
    ) -> any View
}

public struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    @Binding public var value: Value { get nonmutating set }
    public let spacing: CGFloat
    public let count: Int
}
```
To define a custom rating style, create a type which conforms to `RatingStyle` by implementing the `makeStar(configuration:index:)` method. This method is responsible for generating the view for the star at a specific `index` in the `Rating` View. Utilize the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's value, count, and spacing. The implementation should return a view which has the appearance and behavior of the star at `index` in the rating with value `configuration.value`. As to why the return type of `makeStar(configuration:index)` is erased to `any View`, refer to section [Type Erasure Trade-off in RatingStyle](#type-erasure-trade-off-in-ratingstyle).

For example, here's how to create a rating style which draws circles instead of stars:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> any View {
		Image(systemName: Int(configuration.value) > index ? "circle.fill" : "circle")
    }
}
```

Here's how to create a rating style which supports half-integer star ratings:
```swift
struct HalfStarRatingStyle: RatingStyle {
    func makeStar<V: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<V>, index: Int) -> any View {
		if configuration.value >= V(index + 1) {
			Image(systemName: "star.fill")
		} else if configuration.value + 0.5 >= V(index + 1) {
			Image(systemName: "star.leadinghalf.filled")
		} else {
			Image(systemName: "star")
		}
    }
}
```

To apply a rating style to a `Rating`, the API provides a convenience function on `View`, allowing the style to propagate to all `Rating` views within the hierarchy:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S: RatingStyle
}
```
A rating's style should apply regardless of the type of `Value` used in each `Rating<Value>` in a view hierarchy, because they deal with independent concerns: the style specifies how a rating is drawn, and the type of `Value` specifies how a rating's value is represented in memory. For example, the following `CircleRatingStyle` should apply to each `Rating`:
```swift
VStack {
    Rating(value: .constant(Float(3.2)))
    Rating(value: .constant(Double(4.6)))
}
.ratingStyle(CircleRatingStyle())
```
This implies the type of `Value` should be erased in `RatingStyleConfiguration`. However, erasing this type makes it harder to implement styles which

To facilitate easy modification of an existing style rather than implementing an entirely new one,
```swift
extension Rating {
    public init(_ configuration: RatingStyleConfiguration<Value>, index: Int)
}
```

This initializer is particularly useful for custom rating styles that aim to modify the existing style rather than implementing an entirely new one. For instance, the `RedBorderRatingStyle` below adds a red border to the rating while retaining the rating's current style:
```swift
struct RedBorderRatingStyle: RatingStyle {
    func makeStar(configuration: RatingStyleConfiguration<some BinaryFloatingPoint>, index: Int) -> some View {
        RatingStar(configuration, index: index)
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

### Alternative 4

# Type Erasure Trade-off in `RatingStyle`
In order for a rating's style to be agnostic to the type of its value, the `makeStar(configuration:index)` method of `RatingStyle` should be generic over `Value` in  `RatingStyleConfiguration<Value>`. To use the resulting `View`, we want to return an opaque type for `View`:
```swift
protocol RatingStyle {
    associatedtype Body: View
    @ViewBuilder func makeStar(
	    configuration: RatingStyleConfiguration<some BinaryFloatingPoint>,
	    index: Int
    ) -> Body
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
There is no single underlying type to infer `Dish` because it depends on the generic parameter `Ingredient` which is allowed to change with the caller. The only way around it is to type erase the parameter or the return value.

So we either need to type erase `RatingStyleConfiguration` over `Value`, or erase `some View` to `any View`.
## Erase `some View` to `any View`
This is the simpler of the two solutions. Our protocol becomes:
```swift
protocol RatingStyle {
    @ViewBuilder func makeBody<Value: BinaryFloatingPoint>(configuration: RatingStyleConfiguration<Value>) -> any View 
}
```
The cost of this is that view updates of `Rating` aren't as efficient because the type of our view hierarchy is erased.
## Erase `Value` in `RatingStyleConfiguration<Value>`
This requires erasing over our binding to value in `RatingStyleConfiguration`:
```swift
struct RatingStyleConfiguration {
    @Binding var value: any BinaryFloatingPoint
    
    init<V: BinaryFloatingPoint>(value binding: Binding<V>) {
        self._value = Binding {
            binding.wrappedValue
        } set: { newValue in
            if let newValue = newValue as? V {
                binding.wrappedValue = newValue
            }
        }
    }
}
```
However, now it's difficult to read/write to this binding in a custom `RatingStyle`, because we don't have easy access to the concrete type of the value to type cast a new value. One solution is to defer assignment of value to a function which knows the concrete type:
```swift
struct CircleRatingStyle: RatingStyle {
    var systemImage: String

    @ViewBuilder
    func makeBody(configuration: RatingStyleConfiguration) -> some View {
        HStack(spacing: configuration.spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = i < Int(configuration.value)
                Image(systemName: isFilled ? "\(systemImage).fill" : systemImage)
                    .onTapGesture {
                        configuration.setValue(i + 1)
                    }
            }
        }
    }
}

extension RatingStyleConfiguration {
    public func setValue(_ newValue: some BinaryFloatingPoint) {
        _setValue(to: newValue, value: self.value)
	}

    func _setValue<V: BinaryFloatingPoint>(to newValue: some BinaryFloatingPoint, value: V) {
        self.value = V(newValue)
    }
}
```

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

# Useful Links

https://forums.swift.org/t/type-erasing-in-swift-anyview-behind-the-scenes/27952/9
