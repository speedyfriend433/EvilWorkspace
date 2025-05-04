//
//  UncaughtInAppStoreReviewWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 04.05.25.
//

//
//  EvilWorkspaceService.swift
//  EnhancedEvilApp
//
//  Created by fridakitten [Enhanced]
//

import Foundation
import UIKit

class EvilWorkspaceService {

    static let shared = EvilWorkspaceService()

    private let workspace: AnyObject?
    private let openSelector: Selector?
    private let suspendSelector: Selector?

    private init?() {
        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") as? NSObject.Type else {
            print("❌ [EvilWorkspaceService] Failed to find LSApplicationWorkspace class.")
            return nil
        }

        let defaultWorkspaceSelectorName = "defaultWorkspace"
        let openAppSelectorName = "openApplicationWithBundleID:"
        let suspendSelectorName = "_terminateWithStatus:"
        let defaultWorkspaceSel = NSSelectorFromString(defaultWorkspaceSelectorName)
        let openAppSel = NSSelectorFromString(openAppSelectorName)
        let suspendSel = NSSelectorFromString(suspendSelectorName)

        guard let workspaceInstance = workspaceClass.perform(defaultWorkspaceSel)?.takeUnretainedValue() else {
            print("❌ [EvilWorkspaceService] Failed to get default workspace instance (perform returned nil or failed).")
            return nil
        }

        self.workspace = workspaceInstance
        self.openSelector = openAppSel
        self.suspendSelector = suspendSel

        print("✅ [EvilWorkspaceService] Successfully initialized with workspace access.")
    }

    @discardableResult
    func openApplication(bundleID: String) -> Bool {
        guard let ws = workspace, let selector = openSelector else {
            print("⚠️ [EvilWorkspaceService] Workspace or open selector not available.")
            return false
        }

        _ = ws.perform(selector, with: bundleID)
        return true
    }

    func forceRestartOrSuspend() {
        guard let suspendSel = suspendSelector else {
             print("⚠️ [EvilWorkspaceService] Suspend selector not available.")
             let originalSuspendSelector = #selector(NSXPCConnection.suspend)
             DispatchQueue.global(qos: .userInitiated).async {
                 print("☢️ [EvilWorkspaceService] Attempting forced suspend via UIControl/NSXPCConnection (Original Method)...")
                 let control = UIControl()
                 control.sendAction(originalSuspendSelector, to: UIApplication.shared, for: nil)
             }
             return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            print("☢️ [EvilWorkspaceService] Attempting forced termination via _terminateWithStatus: ...")
            if UIApplication.shared.responds(to: suspendSel) {
                UIApplication.shared.perform(suspendSel, with: 0)
            } else {
                print("⚠️ [EvilWorkspaceService] UIApplication does not respond to _terminateWithStatus:")
                 let originalSuspendSelector = #selector(NSXPCConnection.suspend)
                 print("☢️ [EvilWorkspaceService] Falling back to forced suspend via UIControl/NSXPCConnection...")
                 let control = UIControl()
                 control.sendAction(originalSuspendSelector, to: UIApplication.shared, for: nil)
            }
        }
    }
}
