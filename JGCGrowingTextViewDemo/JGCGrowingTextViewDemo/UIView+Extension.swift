//
//  UIView+Extension.swift
//  JGCGrowingTextViewDemo
//
//  Created by Javier Garcia Castro on 22/12/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

let leftPoint = CGPoint.init(x: 0, y: 0)
let rightPoint = CGPoint.init(x: 1, y: 0)
let topPoint = CGPoint.init(x: 0, y: 0)
let bottomPoint = CGPoint.init(x: 0, y: 1)

extension UIView {
    
    // MARK: - Inspenctables Properties
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // MARK: - Public Properties
    
    var width:CGFloat {
        get {
            return frame.size.width
        }
        set {
            var aframe:CGRect = self.frame
            aframe.size.width = width
            self.frame = aframe
        }
    }
    
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var aframe:CGRect = self.frame
            aframe.size.height = height
            self.frame = aframe
        }
    }
    
    var x:CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var aframe:CGRect = self.frame
            aframe.origin.x = x
            self.frame = aframe
        }
    }
    
    var y:CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var aframe:CGRect = self.frame
            aframe.origin.y = y
            self.frame = aframe
        }
    }
    
    var size:CGSize {
        get {
            return self.frame.size
        }
        set {
            var aframe:CGRect = self.frame
            aframe.size = size
            self.frame = aframe
        }
    }
    
    var origin:CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var aframe:CGRect = self.frame
            aframe.origin = origin
            self.frame = aframe
        }
    }
    
    var maxX:CGFloat {
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }
    
    var maxY:CGFloat {
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }
    
    // MARK: - Class Methods
    
    class func embedView(view: UIView) {
        
        let views = ["view": view]
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        
        view.superview!.addConstraints(widthConstraints)
        view.superview!.addConstraints(heightConstraints)
    }
    
    class func embedViewWithMargin(view: UIView, margin: CGFloat) {
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:NSMutableArray = NSMutableArray()
        
        constraints.add([NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[view]-margin-|", options: [], metrics: ["margin":margin], views: ["view":view])])
        
        constraints.add([NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[view]-margin-|", options: [], metrics: ["margin":margin], views: ["view":view])])
        
        view.superview?.addConstraints(constraints as Array as! [NSLayoutConstraint])
    }
    
    class func embedViewWithSize(view: UIView, size: CGSize) {
        
        let views = ["view": view]
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view(width)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": size.width], views: views)
        
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view(height)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["height": size.height], views: views)
        
        view.superview!.addConstraints(widthConstraints)
        view.superview!.addConstraints(heightConstraints)
    }
    
    class func setBackgroundGradient(mainView: UIView, startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        
        mainView.backgroundColor = .clear
        
        let grad:CAGradientLayer = CAGradientLayer()
        grad.frame = mainView.frame
        grad.startPoint = startPoint
        grad.endPoint = endPoint
        grad.colors = [startColor, endColor]
        
        mainView.layer.insertSublayer(grad, at: 0)
    }
    
    class func setBackgroundGradientToRight(mainView: UIView, startColor: UIColor, endColor: UIColor) {
        setBackgroundGradient(mainView: mainView, startColor: startColor, endColor: endColor, startPoint: leftPoint, endPoint: rightPoint)
    }
    
    class func setBackgroundGradientToLeft(mainView: UIView, startColor: UIColor, endColor: UIColor) {
        setBackgroundGradient(mainView: mainView, startColor: startColor, endColor: endColor, startPoint: rightPoint, endPoint: leftPoint)
    }
    
    class func setBackgroundGradientToTop(mainView: UIView, startColor: UIColor, endColor: UIColor) {
        setBackgroundGradient(mainView: mainView, startColor: startColor, endColor: endColor, startPoint: bottomPoint, endPoint: topPoint)
    }
    
    class func setBackgroundGradientToBottom(mainView: UIView, startColor: UIColor, endColor: UIColor) {
        setBackgroundGradient(mainView: mainView, startColor: startColor, endColor: endColor, startPoint: topPoint, endPoint: bottomPoint)
    }
    
    // MARK: - Menu Image Header
    
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
}

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
    
    func substring(to: Int) -> String {
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: to))
    }
    
    var length: Int {
        return self.characters.count
    }
}


