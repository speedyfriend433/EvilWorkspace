//
//  ContentView.swift
//  CantStopMe
//
//  Created by fridakitten on 03.05.25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isEvil") var isEvil: Bool = false
    
    init() {
        EvilFind()
        if isEvil {
            EvilWorkspace(mode: .stayalive)
        }
    }
    
    var body: some View {
        VStack {
            Text("Evil")
                .foregroundColor(.red)
                .font(.system(size: 40)) +
            Text("Workspace")
                .foregroundColor(.white)
                .font(.system(size: 40))
            Spacer()
            Button(isEvil ? "Dont be Evil" : "Be Evil") {
                if !isEvil {
                    EvilWorkspace(mode: .stayalive)
                }
                isEvil = !isEvil
            }
            .foregroundColor(isEvil ? .red : .blue)
            Spacer().frame(height: 50)
            Button("Restart App") {
                EvilWorkspace(mode: .restart)
            }
            .disabled(isEvil)
            Spacer()
            Text("PID: \(String(getpid()))")
            Text("Discovered by.SeanIsTethered")
        }
        .padding()
    }
}
