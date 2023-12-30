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
    
    init(_ key: KeyPath<FileManageValues, FileManageKeypath<T>>) {
        let keypath = FileManageValues.shared[ keyPath: key]
        
        let key = keypath.key
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

struct FileManageKeypath<T:Codable> {
    let key: String
    let type:  T.Type
}

struct FileManageValues {
    static let shared = FileManageValues()
    
    private init() {}
    let userProfile = FileManageKeypath(key: "user_profile", type: User.self)
}

import Combine

@propertyWrapper
struct FileManagerCodableStreamableProperty<T:Codable>: DynamicProperty {
    @State private var value: T?
    let key: String
    private let publisher: CurrentValueSubject<T?, Never>
    
    var wrappedValue: T? {
        get {
            value
        }
        nonmutating set {
            save(newValue: newValue)
        }
    }
    
    var projectedValue: CustomProjectedValue<T> {
        CustomProjectedValue(
            binding: Binding(
                get: { wrappedValue },
                set: { wrappedValue = $0 }),
            publisher: publisher)
    }
    
    init(_ key: String) {
        self.key = key
        
        do {
            let url = FileManager.documentsPath(key: key)
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            publisher = CurrentValueSubject(object)
            print("Sucсess read")
        } catch {
            _value = State(wrappedValue: nil)
            publisher = CurrentValueSubject(nil)
            print("Error read: \(error)")
        }
    }
    
    init(_ key: KeyPath<FileManageValues, FileManageKeypath<T>>) {
        let keypath = FileManageValues.shared[ keyPath: key]
        
        let key = keypath.key
        self.key = key
        
        do {
            let url = FileManager.documentsPath(key: key)
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(T.self, from: data)
            _value = State(wrappedValue: object)
            publisher = CurrentValueSubject(object)
            print("Sucсess read")
        } catch {
            _value = State(wrappedValue: nil)
            publisher = CurrentValueSubject(nil)
            print("Error read: \(error)")
        }
    }
    
    private func save(newValue: T?) {
        do {
            let data = try JSONEncoder().encode(newValue)
            try data.write(to: FileManager.documentsPath(key: key))
            value = newValue
            publisher.send(newValue)
            print("Sucсess saved")
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct CustomProjectedValue<T:Codable> {
    let binding: Binding<T?>
    let publisher: CurrentValueSubject<T?, Never>
    
    var stream: AsyncPublisher<CurrentValueSubject<T?, Never>> {
        publisher.values
    }
}

struct PropertyWrapper2: View {
    // @Capitalized private var title: String = "Hoo"
    @Uppercased private var title: String = "Hoo"
    //@FileManagerCodableProperty("user_profile") private var userProfile: User?
    //@FileManagerCodableProperty(FileManageKeys.userProfile.rawValue) private var userProfile: User?
    //@FileManagerCodableProperty(\.userProfile) private var userProfile: User?
    //@FileManagerCodableProperty(\.userProfile) private var userProfile
    @FileManagerCodableStreamableProperty(\.userProfile) private var userProfile
    
    var body: some View {
        
        VStack(spacing: 30 ) {
            Button(title) {
                title = "hooooo"
            }
            
            SomeBindingView(userProfile: $userProfile.binding)
            
            Button(userProfile?.name ?? "no value") {
                userProfile = User(name: "Elai", age: 888, isPremium: true)
            }
        }
        .onAppear {
            print(NSHomeDirectory())
        }
        .onReceive($userProfile.publisher, perform: { newValue in
            print("Recieved new value of: \(newValue)")
        })
        .task {
            for await newValue in $userProfile.stream {
                print("Stream new value of: \(newValue)")
            }
        }
    }
}

struct SomeBindingView: View {
    @Binding var userProfile: User?
    
    var body: some View {
        Button(userProfile?.name ?? "no value") {
            userProfile = User(name: "Eli", age: 88, isPremium: false)
        }
    }
}

#Preview {
    PropertyWrapper2()
}
