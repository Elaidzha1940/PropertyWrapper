//  /*
//
//  Project: PropertyWrapper
//  File: PropertyWrapper2.swift
//  Created by: Elaidzha Shchukin
//  Date: 30.12.2023
//
//  */

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

@propertyWrapper
struct Uppercased: DynamicProperty {
    @State private var value: String
    
    var wrappedValue: String {
        get {
            value
        }
        nonmutating set {
            value = newValue.uppercased()
        }
    }
    
    init(wrappedValue: String) {
        self.value = wrappedValue.uppercased()
    }
}

@propertyWrapper
struct FileManagerCodableProperty: DynamicProperty {
    @State private var title: String
    let key: String
    
    var wrappedValue: String {
        get {
            title
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
    var projectedValue: Binding<String> {
        Binding {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }

    }
    
    init(wrappedValue: String, _ key: String) {
        self.key = key
        do {
            self.title = try String(contentsOf: FileManager.documentsPath(key: key), encoding: .utf8)
            print("Sucсess read")
        } catch {
            self.title = wrappedValue
            print("Error read: \(error)")
        }
    }
    
    
    
    func save(newValue: String) {
        do {
            // When atomically is set true, it means that the data will be written to a temporary file first.
            // When atomically is set false, the data is written directly to the specified file path.
            
            try newValue.write(to: FileManager.documentsPath(key: key), atomically: false, encoding: .utf8)
            title = newValue
            print("Sucсess saved")
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct PropertyWrapper2: View {
    // @Capitalized private var title: String = "Hoo"
    @Uppercased private var title: String = "Hoo"
    @FileManagerCodableProperty("user_profile") private var userProfile: String = "Test"
    
    var body: some View {
        
        VStack {
            Button(title) {
                title = "hooooo"
            }
            
            Button(userProfile) {
                userProfile = "Another Value"
            }
        }
    }
}

#Preview {
    PropertyWrapper2()
}
