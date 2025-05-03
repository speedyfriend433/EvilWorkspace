//
//  EvilWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 03.05.25.
//

import Foundation
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

enum EvilEnum {
    case stayalive
    case restart
}

func EvilWorkspace(mode: EvilEnum) {
    
    @AppStorage("isEvil") var isEvil: Bool = false
    
    guard let workspace = LSApplicationWorkspace.default() else { return }
    
    pthread_dispatch {
        while true {
            workspace.openApplication(withBundleID: Bundle.main.bundleIdentifier)
            if !isEvil, mode == .stayalive { return }
        }
    }
    
    switch mode {
    case .restart:
        pthread_dispatch {
            Thread.sleep(forTimeInterval: 0.2)
            exit(0)
        }
        break
    case .stayalive:
        break
    }
}
