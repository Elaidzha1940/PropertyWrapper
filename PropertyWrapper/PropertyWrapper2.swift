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
struct FileManagerCodableProperty<T:Codable>: DynamicProperty {
    @State private var value: T?
    let key: String
    
    var wrappedValue: T? {
        get {
            value
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
//    var projectedValue: Binding<String> {
//        Binding {
//            wrappedValue
//        } set: { newValue in
//            wrappedValue = newValue
//        }
//    }
    
    init(wrappedValue: T?, _ key: String) {
        self.key = key
        do {
            let url = FileManager.documentsPath(key: key)
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            value = object
            print("Sucсess read")
        } catch {
            value = wrappedValue
            print("Error read: \(error)")
        }
    }
    
    func save(newValue: T?) {
        do {
            let data = try JSONEncoder().encode(newValue)
            try data.write(to: FileManager.documentsPath(key: key))
            value = newValue
            print("Sucсess saved")
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct User: Codable {
    let name: String
    let age: Int
    let isPremium: Bool
}

struct PropertyWrapper2: View {
    // @Capitalized private var title: String = "Hoo"
    @Uppercased private var title: String = "Hoo"
    @FileManagerCodableProperty("user_profile") private var userProfile: User? = nil
    
    var body: some View {
        
        VStack {
            Button(title) {
                title = "hooooo"
            }
            
            Button(userProfile?.name ?? "no value") {
                userProfile = User(name: "Eli", age: 69, isPremium: true)
            }
        }
        .onAppear {
            print(NSHomeDirectory())
        }
    }
}

#Preview {
    PropertyWrapper2()
}
