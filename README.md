# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a new Star Rating view. The aim is to provide a consistent rating experience across all Apple platforms, while also providing customizability for individualized apps.

<img width="133" alt="Screenshot 2023-12-07 at 11 02 58 PM" src="https://github.com/cook-jeremy/StarRatingAPI/assets/12803067/ae6806b4-7bd9-4196-a8d6-450aab83ad6a">

## Detailed Design
There's an important dichotomy in star rating views: interactive and non-interactive. Interactive star rating UIs typically provide the user the choice of selecting in integer or half-integer star increments, instead of a continuous range, because one can't easily or accurately submit a precise floating point rating on most platforms. For non-interactive star ratings, the view can display a floating point rating to some specified precision (e.g. one decimal place). These non-interactive star rating views typically show the average of many ratings. We'd like to accommodate to both of these typical use cases with one view: `Rating`. The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars.

The `Rating` View has only one required parameter: a binding to a type which conforms to `BinaryFloatingPoint`, representing the rating. It also offers several optional customization parameters, each with a default value:
- **Spacing:** The spacing between stars. The default spacing is that of `HStack`.
- **Count:** The number of stars, defaults to 5.

TODO:
- **Precision:** The increment precision between ratings. A value of 1 indicates integer ratings, 0.5 indicates half-integer ratings, etc. The default value is 1.

The initializer for the `Rating` View is structured as follows:
```swift
public struct Rating: View {
    public init<V>(
        value: Binding<V>,
        spacing: CGFloat? = nil,
        count: Int = 5
    ) where V: BinaryFloatingPoint
}
```

Aligning with the design philosophy of SwiftUI of separating functional and stylistic code, we introduce a `RatingStyle` protocol to customize the `Rating` view. To customize the `Rating` View, create a type conforming to the `RatingStyle` protocol:
```swift
protocol RatingStyle {
    associatedtype Body: View
    typealias Configuration = RatingStyleConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}
```

The `RatingStyleConfiguration` is defined as:
```swift
public struct RatingStyleConfiguration {
    @Binding public var value: Double { get nonmutating set }
    public var count: Int
    public var spacing: CGFloat
}
```

To define a custom rating style, create a type which conforms to `RatingStyle` by implementing the `makeBody(configuration:)` method. This method is responsible for generating the view for *all* the stars in the `Rating` View. Utilize the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's value, star count, and spacing. The implementation should return a view which has the appearance and behavior of all of the stars in the rating view.

For example, here's how to create a `CircleRatingStyle`, which uses circles instead of stars:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< configuration.count, id: \.self) { i in
                let isFilled = Double(i) < configuration.value
                Image(systemName: isFilled ? "circle.fill" : "circle")    
            }
        }
    }
}
```

To apply a custom style to ratings in a view hierarchy, use the following extension on `View`:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle
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
    public init(_ configuration: RatingStyleConfiguration)
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

Given there are over 2,000 SF Symbols which have a `.fill` counterpart (like `star` and `star.fill`), we offer an API to easily create a custom `RatingStyle`  using system images:
```swift
struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    var fillSystemImage: String
    func makeBody(configuration: Configuration) -> some View
}
```

## Alternatives Considered

Many star rating UIs are symmetric across each star, or can be easily drawn based on the star index. With this symmetry, we could simplify the customization to focus on *each* star, instead of all the stars. This tradeoff simplifies the styling of a star rating view, at the cost that each star is symmetric to one another and wholistic features which depend on multiple stars are harder or impossible to implement.

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

# Extras
To create a basic `Rating` View, you only need to provide a binding to a star rating value:
```swift
@State var value: Int = 3

var body: some View {
    Rating(value: $value)
}
```

For more control, you can set a constant integer rating (to disable user interaction), specify the spacing between stars, and define the number of stars:
```swift
Rating(value: .constant(3), spacing: 5, count: 10)
```


# Issues
We want the initializer for `Rating` to be generic over the value of the rating, so that we can create a rating for any floating point type: `Double`, `Float`, `Float80`, etc. However, `RatingStyle` should be agnostic to this detail, so that a rating style can be applied regardless of the underlying rating value type. This constraint means we can't use a generic parameter in `RatingStyleConfiguration` because then `RatingStyle` needs to know this type:
```swift
struct RatingStyleConfiguration<Value: BinaryFloatingPoint> {
    @Binding var value: Value
}

protocol RatingStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: RatingStyleConfiguration) -> Body // Reference to generic type RatingStyleConfiguration requires arguments in <...>
}
```
Generics are out, but it should still be easy to use the binding in `RatingStyleConfiguration`, so that the `makeBody` of a rating style can easily modify this value. 


We can't have:
```swift
struct Rating<Style: RatingStyle, Value: BinaryFloatingPoint>: View where Style.Value == Value
```
The `RatingStyle`'s `makeBody` method consumes a `RatingStyleConfiguration<Value>`, which stores a `@Binding` to the `Value` of the rating. Suppose we have two `Rating` views which use two different value types -- a `Float` and a `Double`-- and we want to apply a generic rating style to both.
```swift
VStack {
    Rating(value: .constant(Float(3.2)))
    Rating(value: .constant(Double(4.6)))
}
.ratingStyle(CircleRatingStyle())
```
The problem here is that we can't use an `@Environment` variable to store this rating style, because it depends on `Value`. We need `Value` to be an existential type for any of this to work.
