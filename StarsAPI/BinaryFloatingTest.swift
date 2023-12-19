import SwiftUI

struct FloatConfiguration {
    @Binding var value: Double
}

protocol FloatStyle {
    associatedtype Body: View
    func makeBody(configuration: FloatConfiguration) -> Body
}

struct TestFloatStyle: FloatStyle {
    func makeBody(configuration: FloatConfiguration) -> some View {
        Text("Add 1")
            .onTapGesture {
                configuration.value += 1
            }
    }
}

struct FloatStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: any FloatStyle = TestFloatStyle()
}

extension EnvironmentValues {
    var floatStyle: any FloatStyle {
        get { self[FloatStyleEnvironmentKey.self] }
        set { self[FloatStyleEnvironmentKey.self] = newValue }
    }
}

struct FloatStyleModifier<S: FloatStyle>: ViewModifier {
    var style: S
    func body(content: Content) -> some View {
        content.environment(\.floatStyle, style)
    }
}

extension View {
    func floatStyle<S>(_ style: S) -> some View where S : FloatStyle {
        return self.modifier(FloatStyleModifier(style: style))
    }
}

struct MyView {
    
    @Environment(\.floatStyle) var myStyle
    
    @Binding var value: Double
    
    init(value: Binding<Double>) {
        self._value = value
    }
    
    var body: some View {
        AnyView(myStyle.makeBody(configuration: .init(value: $value)))
    }
}
