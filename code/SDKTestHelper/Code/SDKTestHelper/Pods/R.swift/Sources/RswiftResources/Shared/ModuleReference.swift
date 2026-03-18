//
//  ModuleReference.swift
//  ModuleReference.swift
//
//  Created by Mathijs Kadijk on 11-12-15.
//

import Foundation

public enum ModuleReference: Hashable, Sendable {
    case host
    case stdLib
    case custom(name: String)

    public init(name: String?, fallback: ModuleReference = .host) {
        let cleaned = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        self = cleaned.isEmpty ? fallback : .custom(name: cleaned)
    }

    public var isCustom: Bool {
        switch self {
        case .custom:
            return true
        default:
            return false
        }
    }

    public var name: String? {
        if case let .custom(name) = self {
            return name
        } else {
            return nil
        }
    }
}

public extension ModuleReference {
    static var uiKit: ModuleReference { .custom(name: "UIKit") }
    static var appKit: ModuleReference { .custom(name: "AppKit") }
    static var coreText: ModuleReference { .custom(name: "CoreText") }
    static var foundation: ModuleReference { .custom(name: "Foundation") }
    static var rswiftResources: ModuleReference { .custom(name: "RswiftResources") }
}
