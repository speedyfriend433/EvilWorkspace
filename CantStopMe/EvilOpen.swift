//
//  UncaughtInAppStoreReviewWorkspace.swift
//  EvilWorkspace
//
//  Created by fridakitten on 04.05.25.
//

import Foundation

var workspace: AnyObject! = nil
var selector: Selector! = nil

func EvilFind() -> Void {
    let workspaceClass = NSClassFromString("LSApplicationWorkspace") as! NSObject.Type
    let defaultWorkspaceSelector = NSSelectorFromString("defaultWorkspace")
    workspace = workspaceClass.perform(defaultWorkspaceSelector).takeUnretainedValue()
    selector = NSSelectorFromString("openApplicationWithBundleID:")
}

func EvilOpen(_ bundleid: String) -> Void {
    _ = workspace.perform(selector, with: bundleid)
}
