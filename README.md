# Star Rating API Proposal

## Introduction
This proposal introduces an API in the SwiftUI framework for a new Star Rating View. The aim is to provide a consistent rating experience across all Apple platforms. 

## Detailed Design
To begin, it's important to differentiate between two distinct types of star rating interfaces:
- **Interactive Integer Star Rating:** This is a user-interactive view where users can select a whole-number rating.
- **Non-Interactive Floating Point Star Rating:** This view is designed to display a floating point star rating view that represents the average of many ratings. This view is not meant for user interaction because a user can't easily or accurately submit a precise floating point rating on most platforms.

Recognizing the fundamental differences between these two types of star rating UIs, we propose the creation of two separate views. The first is an interactive view for integer ratings, named `Rating`, and the second is a non-interactive view for displaying average floating-point ratings, named `AverageRating`. In this proposal we will only cover the API for `Rating`. The name `Rating` was chosen over `StarRating` to emphasize the flexibility in customizing the appearance of the rating symbols beyond stars.
### `Rating` View
The `Rating` View has only one required parameter: a binding to the integer value representing the rating. It also offers several optional customization parameters, each with a default value:
- **Spacing Between Stars:**  Uses the default spacing of `HStack`.
- **Star Count:** Defaults to 5.
- **Star Style:** The default style uses the SF Symbols `star` and `star.filled`.

The `Rating` View is structured as follows:
```swift
public struct Rating: View {
    public init(
        value: Binding<Int>,
        spacing: CGFloat? = nil,
        count: Int = 5
    )
}
```

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

To customize the `Rating` View, create a type conforming to the `RatingStyle` protocol. This protocol is responsible for generating a view for each star in the `Rating` View.
```swift
protocol RatingStyle {
    associatedtype Body: View
    typealias Configuration = RatingStyleConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}
```

To define a custom rating style, implement the `makeBody(configuration:)` method. Utilize the `configuration` parameter—a `RatingStyleConfiguration` instance—to access the rating's star index and value. The implementation should return a view which has the appearance and behavior of one of the stars in a rating view. 

For example, here's how to create a `CircleRatingStyle`, which uses circles instead of stars:
```swift
struct CircleRatingStyle: RatingStyle {
    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: configuration.isFilled ? "circle.fill" : "circle")
            .onTapGesture {
                configuration.value = configuration.starIndex + 1
            }
    }
}
```
Note: The `starIndex` begins at 0. To align with the rating value, add 1 to the `starIndex`.

The `RatingStyleConfiguration` is defined as follows:
```swift
public struct RatingStyleConfiguration {
    public var starIndex: Int
    @Binding public var value: Int { get nonmutating set }
    public var count: Int
    public var isFilled: Bool { get }
}
```
 
This struct includes the index of the star in the rating, a binding to the rating's value, the total number of stars, and a property indicating whether a star is filled. To apply a custom style to ratings in a view hierarchy, use the following extension on `View`:
```swift
extension View {
    public func ratingStyle<S>(_ style: S) -> some View where S : RatingStyle
}
```

Apply this modifier to a `Rating` instance to define the appearance and behavior of individual stars. For instance, using the previously defined `CircleRatingStyle`:
```swift
Rating(value: $value)
    .ratingStyle(CircleRatingSyle())
```

The `ratingStyle(_:)` modifier is defined on View, so we can apply a style to any view hierarchy, allowing the style to propagate to all `Rating` Views within in. For example:
```swift
VStack {
    Rating(value: .constant(1))
    Rating(value: .constant(2))
    Rating(value: .constant(3))
}
.ratingStyle(.circle)
```

To facilitate easy creation of a `Rating` view based on a specific configuration, we've added the following initializer:
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

Given there are over 2,000 SF Symbols which have a `.fill` counterpart (like `star` and `star.fill`), we offer an API to easily create a custom `RatingStyle`  using a system image:
```swift
struct SystemImageRatingStyle: RatingStyle {
    var systemImage: String
    func makeBody(configuration: Configuration) -> some View
}
```

## Alternatives Considered
An alternative method for customizing the `Rating` view was considered, involving the use of `@ViewBuilder` closures to define the appearance of each star. This approach looks like the following:
```swift
struct Rating<Star>: View where Star: View {
    public init(value: Binding<Int>,
                spacing: CGFloat? = nil,
                count: Int = 5,
                @ViewBuilder starView: (Bool) -> Star
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


