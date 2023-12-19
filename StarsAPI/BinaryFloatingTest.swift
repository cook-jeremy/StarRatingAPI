import SwiftUI



struct Configuration<Value: BinaryFloatingPoint> {
    var value: Value
}

protocol Style {
    func makeBody(configuration: Configuration<some BinaryFloatingPoint>) -> AnyView
}

struct MyStyle: Style {
    func makeBody(configuration: Configuration<some BinaryFloatingPoint>) -> AnyView {
        AnyView(Text("Hi"))
    }
}


//struct FloatConfiguration<Value: BinaryFloatingPoint> {
//    @Binding var value: Value
//}
//
//protocol FloatStyle {
//    associatedtype Body: View
//    func config(configuration: FloatConfiguration<some BinaryFloatingPoint>) -> Body
//}
//
//struct TestFloatStyle: FloatStyle {
//    func config(configuration: FloatConfiguration<some BinaryFloatingPoint>) -> some View {
//        configuration.value += 2
//        return Text("HI")
//    }
//}

//struct FloatStyleEnvironmentKey: EnvironmentKey {
//    static let defaultValue: any FloatStyle = TestFloatStyle()
//}
//
//extension EnvironmentValues {
//    var floatStyle: any FloatStyle {
//        get { self[FloatStyleEnvironmentKey.self] }
//        set { self[FloatStyleEnvironmentKey.self] = newValue }
//    }
//}
//
//struct FloatStyleModifier<S: FloatStyle>: ViewModifier {
//    var style: S
//    func body(content: Content) -> some View {
//        content.environment(\.floatStyle, style)
//    }
//}
//
//extension View {
//    func floatStyle<S>(_ style: S) -> some View where S : FloatStyle {
//        return self.modifier(FloatStyleModifier(style: style))
//    }
//}
//
//struct MyView {
//    
//    @Environment(\.floatStyle) var myStyle
//    
//    @Binding var value: Double
//    
//    init(value: Binding<Double>) {
//        self._value = value
//    }
//    
//    var body: some View {
//        AnyView(myStyle.makeBody(configuration: .init(value: $value)))
//    }
//}
