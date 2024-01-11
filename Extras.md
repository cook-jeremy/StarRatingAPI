# To-do
- Support for holistic animations
- Support for watchOS scrolling and tvOS scrolling interaction
- Handle negative spacing. Calculate this as overlap, as it's the most likely intent

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
			- Can drag to zero
		- Non-interactive version:
			- Orange filled star and orange bordered star
	- Average rating
		- Non-interactive
		- One decimal precision increments
		- Star is precisely filled to represent floating point rating
		- Has label (for ex: 4.6) above rating in big font
- Books (very similar to app store)
- Maps
	- Trip advisor integrated ratings
		- All stars change color based on rating. For example a rating of 1/5 is bright orange, 2/5 slightly darker orange, ..., 5/5 dark orange
- Trip advisor app
	- Green circle ratings
	- Granularity of 0.5
- Google maps
	- Gray background, orange foreground (no border)
	- Granularity of 0.5
	- Jumping animation when selecting
	- Haptic feedback when tapping
	- Can select zero stars when dragging
	- Tapping on star again removes the rating
- Trust Pilot
	- Star with square backing, change color of all backings for rating
	- 0.5 granularity
- Groupon
	- Rounds to the nearest 0.5 granular star, whether that's up or down
- Netflix
	- Dislike thumb, like thumb, double like thumb

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


## Examples
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
