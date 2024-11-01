//
//  UIFont+Extension.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 31/10/24.
//


import UIKit

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}
