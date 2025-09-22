//
//  LocaleReference.swift
//  LocaleReference.swift
//
//  Created by Tom Lokhorst on 2016-04-24.
//

import Foundation

public enum LocaleReference: Hashable, Sendable {
    case none
    case base // Older projects use a "Base" locale
    case language(String)

    public var isNone: Bool {
        if case .none = self {
            return true
        }

        return false
    }

    public var isBase: Bool {
        if case .base = self {
            return true
        }

        return false
    }
}

public extension LocaleReference {
    init(url: URL) {
        if let localeComponent = url.pathComponents.dropLast().last, localeComponent.hasSuffix(".lproj") {
            let lang = localeComponent.replacingOccurrences(of: ".lproj", with: "")

            if lang == "Base" {
                self = .base
            } else {
                self = .language(lang)
            }
        } else {
            self = .none
        }
    }

    var localeDescription: String? {
        switch self {
        case .none:
            return nil

        case .base:
            return "Base"

        case let .language(language):
            return language
        }
    }

    func debugDescription(filename: String) -> String {
        switch self {
        case .none:
            return "'\(filename)'"
        case .base:
            return "'\(filename)' (Base)"
        case let .language(language):
            return "'\(filename)' (\(language))"
        }
    }
}
