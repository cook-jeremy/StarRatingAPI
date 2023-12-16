import SwiftUI

protocol MyStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody() -> Body
}

struct CustomStyle: MyStyle {
    @ViewBuilder
    func makeBody() -> some View {
        Text("Hi")
    }
}


let style: any MyStyle = CustomStyle()
func testStyle<S: MyStyle>(_ style: S) -> some View {
    style.makeBody()
}

//let result = testStyle(style)

struct TestStyle: View {
    
    @Environment(\.myStyle) var myStyle
    
    @ViewBuilder
    func drawMyStyle(_ style: some MyStyle) -> some View {
        style.makeBody()
    }
    
    func wrapAgain(_ myView: AnyView) -> some View {
        return myView
    }
    
    var body: some View {
        AnyView(myStyle.makeBody())
    }
}
let s = TestStyle()


struct MyStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: any MyStyle = CustomStyle()
}

extension EnvironmentValues {
    var myStyle: any MyStyle {
        get { self[MyStyleEnvironmentKey.self] }
        set { self[MyStyleEnvironmentKey.self] = newValue }
    }
}


//
//struct AnyMyStyle: MyStyle {
//    private let _makeBody: () -> Content
//
//    init<S>(_ style: S) where S: MyStyle {
//        self._makeBody = style.makeBody
//    }
//
//    func makeBody() -> Content {
//        return _makeBody()
//    }
//}
