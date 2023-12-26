//  /*
//
//  Project: PropertyWrapper
//  File: ContentView.swift
//  Created by: Elaidzha Shchukin
//  Date: 25.12.2023
//
//  */

import SwiftUI

struct FileManagerProperty {
    var title: String
    
    private var path: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "custom_title.txt")
    }
    
    mutating func load() {
        do {
            title = try String(contentsOf: path, encoding: .utf8)
            print("Sucсess read")
        } catch {
            print("Error read: \(error)")
        }
    }
}

struct PropertyWrapper: View {
    @State private var title: String = "Starting title"
    
    var body: some View {
        
        VStack(spacing: 40) {
            Text(title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            
            Button("Press me 1") {
                setTitle(newValue: "title 1")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
            
            Button("Press me 2") {
                setTitle(newValue: "title 2")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.mint)
        }
        .onAppear {
            
        }
    }
    private func setTitle(newValue: String) {
        let uppercased = newValue.uppercased()
        title = uppercased
        save(newValue: uppercased)
    }
    
    
    private var path: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "custom_title.txt")
    }
    
    private func save(newValue: String) {
        do {
            // When atomically is set true, it means that the data will be written to a temporary file first.
            // When atomically is set false, the data is written directly to the specified file path.
            
            try newValue.write(to: path, atomically: false, encoding: .utf8)
            print(NSHomeDirectory())
            print("Sucсess saved")
        } catch {
            print("Error saving: \(error)")
        }
    }
}


#Preview {
    PropertyWrapper()
}
