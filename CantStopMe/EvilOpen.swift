//
//  UncaughtInAppStoreReviewWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 04.05.25.
//

import Foundation

func EvilOpen(_ bundleID: String) -> Void {
    let workspaceClass = NSClassFromString("LSApplicationWorkspace") as! NSObject.Type
    let defaultWorkspaceSelector = NSSelectorFromString("defaultWorkspace")
    let workspace = workspaceClass.perform(defaultWorkspaceSelector)?.takeUnretainedValue() as! NSObject
    let openAppSelector = NSSelectorFromString("openApplicationWithBundleID:")
    workspace.perform(openAppSelector, with: bundleID)
}
