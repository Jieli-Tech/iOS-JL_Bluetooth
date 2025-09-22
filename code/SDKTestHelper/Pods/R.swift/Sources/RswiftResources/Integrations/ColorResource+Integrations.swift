//
//  ColorResource+Integrations.swift
//  ColorResource+Integrations.swift
//
//  Created by Tom Lokhorst on 2017-06-06.
//

import Foundation

#if canImport(SwiftUI)
    import SwiftUI

    @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, visionOS 1, *)
    public extension Color {
        /**
         Creates a color from this resource (`R.color.*`).

         - parameter resource: The resource you want the color of (`R.color.*`)
         */
        init(_ resource: ColorResource) {
            self.init(resource.name, bundle: resource.bundle)
        }
    }
#endif

#if os(iOS) || os(tvOS) || os(visionOS)
    import UIKit

    public extension ColorResource {
        /**
         Returns the color from this resource (`R.color.*`) that is compatible with the trait collection.

         - parameter resource: The resource you want the color of (`R.color.*`)
         - parameter traitCollection: Traits that describe the desired color to retrieve, pass nil to use traits that describe the main screen.

         - returns: A color that exactly or best matches the desired traits with the given resource (`R.color.*`), or nil if no suitable color was found.
         */
        //    @available(*, deprecated, message: "Use UIColor(resource:) initializer instead")
        func callAsFunction(compatibleWith traitCollection: UITraitCollection? = nil) -> UIColor? {
            UIColor(named: name, in: bundle, compatibleWith: traitCollection)
        }
    }

    public extension UIColor {
        /**
         Returns the color from this resource (`R.color.*`) that is compatible with the trait collection.

         - parameter resource: The resource you want the color of (`R.color.*`)
         - parameter traitCollection: Traits that describe the desired color to retrieve, pass nil to use traits that describe the main screen.

         - returns: A color that exactly or best matches the desired traits with the given resource (`R.color.*`), or nil if no suitable color was found.
         */
        convenience init?(resource: ColorResource, compatibleWith traitCollection: UITraitCollection? = nil) {
            self.init(named: resource.name, in: resource.bundle, compatibleWith: traitCollection)
        }
    }
#endif
