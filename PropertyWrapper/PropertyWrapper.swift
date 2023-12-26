//  /*
//
//  Project: PropertyWrapper
//  File: PropertyWrapper.swift
//  Created by: Elaidzha Shchukin
//  Date: 25.12.2023
//
//  */

import SwiftUI

extension FileManager {
    
    static func documentsPath(key: String) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "\(key).txt")
    }
}

@propertyWrapper
struct FileManagerProperty: DynamicProperty {
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
    
    init(key: String) {
        self.key = key
        do {
            self.title = try String(contentsOf: FileManager.documentsPath(key: key), encoding: .utf8)
            print("Sucсess read")
        } catch {
            self.title = "Starting text"
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

struct PropertyWrapper: View {
    //    @State private var title: String = "Starting title"
    //    var fileManagerProperty = FileManagerProperty(title: FileManager.debugDescription())
    @AppStorage("title_key") private var title3 = ""
    @FileManagerProperty(key: "custom_title_1") private var title: String
    @FileManagerProperty(key: "custom_title_2") private var title2: String
    
    var body: some View {
        
        VStack(spacing: 40) {
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Text(title2)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            
            
            Button("Press me 1") {
                title = "title 1"
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
            
            Button("Press me 2") {
                title = "title 2"
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
        }
    }
}


#Preview {
    PropertyWrapper()
}
