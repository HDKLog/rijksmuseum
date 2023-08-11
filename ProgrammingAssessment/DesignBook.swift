//
//  DesignBook.swift
//  WeatherApp
//
//  Created by Gari Sarkisiani on 01.09.21.
//

import UIKit

struct DesignBook {
    struct Image {
        struct ImageWrapper {
            let name: String
            func uiImage() -> UIImage {
                return UIImage(named: name)!
            }
        }


    }

    struct Color {
        struct ColorWrapper {
            let name: String
            func uiColor() -> UIColor {
                return UIColor(named: name)!
            }
        }

        struct Background {
            static let main = ColorWrapper(name: "color-background-main")
            static let list = ColorWrapper(name: "color-background-list")
            static let inverse = ColorWrapper(name: "color-background-inverse")
        }

        struct Foreground {
            static let highlited = ColorWrapper(name: "color-foreground-highlited")
            static let action = ColorWrapper(name: "color-foreground-action")
            static let element = ColorWrapper(name: "color-foreground-element")
            static let inverse = ColorWrapper(name: "color-foreground-inverse")
            static let light = ColorWrapper(name: "color-foreground-light")

            static let purple = ColorWrapper(name: "color-foreground-purple")
            static let orange = ColorWrapper(name: "color-foreground-orange")
            static let green = ColorWrapper(name: "color-foreground-green")
            static let blue = ColorWrapper(name: "color-foreground-blue")
            static let yellow = ColorWrapper(name: "color-foreground-yellow")
            static let red = ColorWrapper(name: "color-foreground-red")
        }
    }

    struct Layout {

        struct Sizes {
            struct Image {
                static let small: CGFloat = 125
                static let medium: CGFloat = 250
                static let large: CGFloat = 600
            }

            struct Text {
                struct Font {
                    static let small: CGFloat = 16
                    static let medium: CGFloat = 18
                    static let large: CGFloat = 22
                }

                struct Header {
                    static let small: CGFloat = 32
                    static let medium: CGFloat = 64
                    static let large: CGFloat = 128
                }
            }
        }

        struct Spacing {
            static let small: CGFloat = 5
            static let medium: CGFloat = 10
            static let large: CGFloat = 30
        }
    }
}
