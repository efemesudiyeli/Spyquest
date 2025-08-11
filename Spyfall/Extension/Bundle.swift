//
//  Bundle.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 11.08.2025.
//
import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

