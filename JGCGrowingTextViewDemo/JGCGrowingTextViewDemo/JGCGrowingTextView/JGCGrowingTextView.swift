//
//  JGCGrowingTextView.swift
//  JGCGrowingTextViewDemo
//
//  Created by Javier Garcia Castro on 22/12/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

@objc protocol JGCGrowingTextViewDelegate {
    @objc optional func updateFrames(parentViewHeight: CGFloat)
    @objc optional func updateGrowingBottomConstraint(constraintValue: CGFloat)
}

class JGCGrowingTextView: UIView, UITextViewDelegate {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var dismissKeyboardButton: UIButton!
    @IBOutlet weak var dismissKeyboardButtonHeightConstraint: NSLayoutConstraint!
    
    var textView: UITextView?
    var delegate: JGCGrowingTextViewDelegate?
    var view: UIView?
    var parentView: UIView?

    var kPreferredTextViewToKeyboardOffset: CGFloat = 0.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    var originParentView: CGPoint = CGPoint.zero
    
    // Mark: - Initialize
    
    convenience init(frame: CGRect, delegate:JGCGrowingTextViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        initialize()
    }

    // MARK: - Private Methods
    
    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.textView = UITextView.init(frame: frame)
        self.textView?.delegate = self
        addSubview(textView!)
        UIView.embedView(view: textView!)
    }
    
    //Keyboard methods
    
    @objc func keyBoardWillShow(notification: Notification) {
        self.keyboardIsShowing = true
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.originParentView = self.frame.origin
            
            //despliego el botton dismiss hasta el teclado
            self.dismissKeyboardButtonHeightConstraint?.constant = keyboardFrame.origin.y
            
            //Si ya hay texto
            if self.origin.y + self.size.height > keyboardFrame.origin.y {
                updateParentView(heightDifference: (self.frame.height + self.frame.origin.y) - keyboardFrame.height - 40.0)
                let range = NSMakeRange(textView!.text.count - 1, 0)
                textView!.scrollRangeToVisible(range)
            }
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        self.keyboardIsShowing = false
        self.returnViewToInitialFrame()
        self.frame.origin = self.originParentView
        
        //pliego el botton dismiss hasta arriba
        self.dismissKeyboardButtonHeightConstraint?.constant = 0
        
        let textViewFixedWidth: CGFloat = self.textView!.frame.size.width
        let newSize: CGSize = self.textView!.sizeThatFits(CGSize.init(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame: CGRect = self.textView!.frame
        let heightDifference = (self.textView?.frame.height)! - newSize.height

        newFrame.size = CGSize.init(width: fmax(newSize.width, textViewFixedWidth), height: newSize.height)
        newFrame.offsetBy(dx: 0.0, dy: heightDifference)

        updateParentView(heightDifference: heightDifference)
    }
    
    func arrangeViewOffsetFromKeyboard() {
        let theApp: UIApplication = UIApplication.shared
        let windowView: UIView? = theApp.delegate!.window!
        let textFieldLowerPoint: CGPoint = CGPoint.init(x: self.frame.origin.x, y: self.frame.origin.y + self.frame.size.height)
        let convertedTextViewLowerPoint: CGPoint = self.convert(textFieldLowerPoint, to: windowView)
        let targetTextViewLowerPoint: CGPoint = CGPoint.init(x: self.frame.origin.x, y: self.keyboardFrame.origin.y - kPreferredTextViewToKeyboardOffset)
        let targetPointOffset: CGFloat = targetTextViewLowerPoint.y - convertedTextViewLowerPoint.y
        let adjustedViewFrameCenter: CGPoint = CGPoint.init(x: self.center.x, y: self.center.y + targetPointOffset)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.center = adjustedViewFrameCenter
        })
    }
    
    func returnViewToInitialFrame() {
        let initialViewRect: CGRect = CGRect.init(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        if (!initialViewRect.equalTo(self.frame)) {
            UIView.animate(withDuration: 0.2, animations: {
                self.frame = initialViewRect
            })
        }
    }
    
    func updateParentView(heightDifference: CGFloat) {
        var newContainerViewFrame: CGRect = self.frame
        let containerViewHeight = self.frame.size.height
        let newContainerViewHeight = containerViewHeight - heightDifference
        let containerViewHeightDifference = containerViewHeight - newContainerViewHeight
        newContainerViewFrame.size = CGSize.init(width: self.frame.size.width, height: newContainerViewHeight)
        newContainerViewFrame.offsetBy(dx: 0.0, dy: containerViewHeightDifference)
        
        self.heightConstraint?.constant = newContainerViewFrame.height
        self.frame = newContainerViewFrame
    }
    
    // MARK: - Public Methods

    func userDidTapDismissButton() {
        textViewDidEndEditing(self.textView!)
        self.superview?.endEditing(true)
    }
    
    //UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(self.keyboardIsShowing) {
//            self.arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewFixedWidth: CGFloat = textView.frame.size.width
        let newSize: CGSize = textView.sizeThatFits(CGSize.init(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame: CGRect = textView.frame
        let heightDifference = (textView.frame.height) - newSize.height
        
        if newSize.height > self.keyboardFrame.origin.y {
            updateParentView(heightDifference: 0.0)
        }
        else if (abs(heightDifference) > 6 && (self.frame.origin.y + self.frame.height) < (self.keyboardFrame.origin.y - 20.0)) {
            newFrame.size = CGSize.init(width: fmax(newSize.width, textViewFixedWidth), height: newSize.height)
            newFrame.offsetBy(dx: 0.0, dy: heightDifference)
            
            updateParentView(heightDifference: heightDifference)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
}
