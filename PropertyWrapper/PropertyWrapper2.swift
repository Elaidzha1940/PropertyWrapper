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
    
    var projectedValue: Binding<T?> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0} )
        
//        Binding {
//            wrappedValue
//        } set: { newValue in
//            wrappedValue = newValue
//        }
    }
    
//    init(_: T?, _ key: String) {
//        self.key = key
//        do {
//            let url = FileManager.documentsPath(key: key)
//            let data = try Data(contentsOf: url)
//            let object = try JSONDecoder().decode(T.self, from: data)
//            _value = State(wrappedValue: object)
//            print("Sucсess read")
//        } catch {
//            _value = State(wrappedValue: nil)
//            print("Error read: \(error)")
//        }
//    }
    
    init(_ key: KeyPath<FileManageValues, String>) {
        let keypath = FileManageValues.shared[ keyPath: key]
        
        let key = keypath
        self.key = key
        
        do {
            let url = FileManager.documentsPath(key: key)
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            print("Sucсess read")
        } catch {
            _value = State(wrappedValue: nil)
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

enum FileManageKeys: String {
    case userProfile
}

struct FileManageValues {
    static let shared = FileManageValues()
    
    private init() {}
    let userProfile = "user_profile"
}

struct PropertyWrapper2: View {
    // @Capitalized private var title: String = "Hoo"
    @Uppercased private var title: String = "Hoo"
    //@FileManagerCodableProperty("user_profile") private var userProfile: User?
//    @FileManagerCodableProperty(FileManageKeys.userProfile.rawValue) private var userProfile: User?
    @FileManagerCodableProperty(\.userProfile) private var userProfile: User?
    
    var body: some View {
        
        VStack(spacing: 30 ) {
            Button(title) {
                title = "hooooo"
            }
            SomeBindingView(userProfile: $userProfile)
        }
        .onAppear {
            print(NSHomeDirectory())
        }
    }
}

struct SomeBindingView: View {
    @Binding var userProfile: User?
    
    var body: some View {
        Button(userProfile?.name ?? "no value") {
            userProfile = User(name: "Eli", age: 69, isPremium: true)
        }
    }
}

#Preview {
    PropertyWrapper2()
}
