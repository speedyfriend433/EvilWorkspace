//
//  EvilWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 03.05.25.
//

import Foundation
import SwiftUI
import os

enum EvilMode {
    case stayAlive
    case restartNow
}

class EvilPersistenceManager {

    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EvilApp", category: "Persistence")
    private static var isLoopActive = false

    static func manageEvilProcess(mode: EvilMode, isEvil: Binding<Bool>) {

        guard let service = EvilWorkspaceService.shared else {
            log.error("❌ Cannot manage evil process: EvilWorkspaceService failed to initialize.")
            DispatchQueue.main.async {
                isEvil.wrappedValue = false
            }
            return
        }

        guard let currentBundleID = Bundle.main.bundleIdentifier else {
            log.error("❌ Cannot manage evil process: Could not get bundle identifier.")
            return
        }

        switch mode {
        case .stayAlive:
            guard !isLoopActive else {
                log.info("ℹ️ Persistence loop already active.")
                return
            }
            
            guard isEvil.wrappedValue else {
                log.info("ℹ️ StayAlive requested but isEvil is false. Not starting loop.")
                return
            }

            isLoopActive = true
            log.notice("▶️ Starting persistence loop...")

            DispatchQueue.global(qos: .background).async {
                while isEvil.wrappedValue {
                    log.debug("♻️ Persistence loop: Attempting relaunch of \(currentBundleID)")
                    service.openApplication(bundleID: currentBundleID)

                    let sleepInterval: TimeInterval = 15.0
                    Thread.sleep(forTimeInterval: sleepInterval)

                    if !isEvil.wrappedValue {
                         break
                    }
                }
                isLoopActive = false
                log.notice("⏹️ Persistence loop stopped.")
                 DispatchQueue.main.async {
                    if isEvil.wrappedValue {
                    }
                 }
            }

        case .restartNow:
            log.warning("🚀 Triggering force restart...")
            service.forceRestartOrSuspend()
        }
    }
}
