//  /*
//
//  Project: PropertyWrapper
//  File: ContentView.swift
//  Created by: Elaidzha Shchukin
//  Date: 25.12.2023
//
//  */

import SwiftUI

extension FileManager {
    
    static func documentsPath() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "custom_title.txt")
    }
}

struct FileManagerProperty: DynamicProperty {
    @State var title: String
    
    init(title: String) {
        do {
            self.title = try String(contentsOf: FileManager.documentsPath(), encoding: .utf8)
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
            
            try newValue.write(to: FileManager.documentsPath(), atomically: false, encoding: .utf8)
            title = newValue
            print("Sucсess saved")
        } catch {
            print("Error saving: \(error)")
        }
    }
}

struct PropertyWrapper: View {
    //    @State private var title: String = "Starting title"
    var fileManagerProperty = FileManagerProperty(title: FileManager.debugDescription())
    
    var body: some View {
        
        VStack(spacing: 40) {
            Text(fileManagerProperty.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            
            Button("Press me 1") {
                fileManagerProperty.save(newValue: "title 1")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
            
            Button("Press me 2") {
                fileManagerProperty.save(newValue: "title 2")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
        }
    }
}


#Preview {
    PropertyWrapper()
}
