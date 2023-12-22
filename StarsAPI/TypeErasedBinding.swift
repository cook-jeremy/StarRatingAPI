import Foundation
import SwiftUI

// We want to type erase Value here
struct MyBinding<Value: BinaryFloatingPoint> {
    @Binding var myValue: Value
}


struct AnyBinding1 {
    @Binding var value: Any
    
    init<V: BinaryFloatingPoint>(_ binding: Binding<V>) {
        self._value = Binding(get: {
            binding.wrappedValue as Any
        }, set: { newValue in
            if let newValue = newValue as? V {
                binding.wrappedValue = newValue
            }
        })
    }
}

struct AnyBinding {
    @Binding var value: Any
    
    init<V: BinaryFloatingPoint>(_ binding: Binding<V>) {
        self._value = Binding(get: {
            binding.wrappedValue
        }, set: { newValue in
            if let newValue = newValue as? V {
                binding.wrappedValue = newValue
            }
        })
    }
}
