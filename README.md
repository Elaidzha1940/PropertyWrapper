Custom Property Wrappers. 
============================================

In SwiftUI, a Property Wrapper is a Swift language feature that allows you to add a layer of custom behavior to properties. Property wrappers are used to augment the behavior of properties in a concise and reusable way.

import SwiftUI

@propertyWrapper
struct Capitalized: DynamicProperty {

    @State private var value: String
    
    var wrappedValue: String {
        get {
            value
        }
        nonmutating set {
            value = newValue.capitalized
        }
    }
    init(wrappedValue: String) {
        self.value = wrappedValue.capitalized
    }
}

struct PropertyWrapper2: View {
    @Capitalized private var title: String = "Hoo"
    
    var body: some View {
        VStack {
            Button(title) {
                title = "hooooo"
            }
        }
    }
}

#Preview {
    PropertyWrapper2()
}
