//
//  EvilWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 03.05.25.
//

import Foundation
import SwiftUI
import os

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
    
    pthread_dispatch {
        while true {
            EvilOpen(Bundle.main.bundleIdentifier!)
            if !isEvil, mode == .stayalive { return }
        }
    }
    
    switch mode {
    case .restart:
        pthread_dispatch {
            //
            // IDK, why yet, but calling this from a background thread which makes this 100% reliable reincarnation method.
            //
            UIControl().sendAction(#selector(NSXPCConnection.suspend),
                                           to: UIApplication.shared, for: nil)
        }
        break
    case .stayalive:
        break
    }
}
