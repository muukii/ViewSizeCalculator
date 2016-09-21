// ViewSizeCalculator.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

public struct ViewSizeCalculator<T: UIView> {
    
    public let sourceView: T
    public let calculateTargetView: UIView
    public let cache: NSCache<NSString, NSValue> = NSCache<NSString, NSValue>()
    
    fileprivate let widthConstraint: NSLayoutConstraint
    fileprivate let heightConstraint: NSLayoutConstraint
    
    public init(sourceView: T, calculateTargetView: (T) -> UIView) {
        
        self.sourceView = sourceView
        self.calculateTargetView = calculateTargetView(sourceView)
        
        self.widthConstraint = NSLayoutConstraint(
            item: self.calculateTargetView,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 0,
            constant: 0
        )
        
        self.heightConstraint = NSLayoutConstraint(
            item: self.calculateTargetView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 0,
            constant: 0
        )
    }
    
    public func calculate(
        width: CGFloat?,
        height: CGFloat?,
        cacheKey: String,
        closure: (T) -> Void) -> CGSize {
        
        let combinedCacheKey = cacheKey + "|" + "\(width):\(height)"
        
        if let size = cache.object(forKey: combinedCacheKey as NSString)?.cgSizeValue {
            return size
        }
        
        if let width = width {
            widthConstraint.isActive = true
            widthConstraint.constant = width
        }
        else {
            widthConstraint.isActive = false
        }
        
        if let height = height {
            heightConstraint.isActive = true
            heightConstraint.constant = height
        }
        else {
            heightConstraint.isActive = false
        }
        
        closure(sourceView)
        
        let size = calculateTargetView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        cache.setObject(NSValue(cgSize: size), forKey: combinedCacheKey as NSString)
        
        return size
    }
}