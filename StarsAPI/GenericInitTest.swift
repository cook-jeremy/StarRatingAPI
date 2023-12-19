//import SwiftUI
//
//
//
//
//struct MyStruct<Value: BinaryFloatingPoint>: View {
//    
//    @Binding var value: any BinaryFloatingPoint
//    
//    init(n: Binding<Value>) {
//        self._value = Binding<any BinaryFloatingPoint>(get: {
//            n.wrappedValue
//        }, set: { newValue in
//            if let newValue = newValue as? Value {
//                n.wrappedValue = newValue
//            }
//        })
//    }
//    
//    var body: some View {
//        Text("\(Double(value))")
//        
//        Button {
//            value += Value(2.0)
//        } label: {
//            Text("Add 2")
//        }
//
//    }
//}
//
//
//struct TestStruct: View {
//    @State private var b: Double = 2.0
//    
//    var body: some View {
//        MyStruct(n: $b)
//            .onTapGesture {
//                b += 0.5
//            }
//    }
//}
//
//#Preview {
//    TestStruct()
//        .padding()
//}
