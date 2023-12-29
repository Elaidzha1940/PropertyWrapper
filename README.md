In SwiftUI, a Property Wrapper is a Swift language feature that allows you to add a layer of custom behavior to properties. Property wrappers are used to augment the behavior of properties in a concise and reusable way.
============================================

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
