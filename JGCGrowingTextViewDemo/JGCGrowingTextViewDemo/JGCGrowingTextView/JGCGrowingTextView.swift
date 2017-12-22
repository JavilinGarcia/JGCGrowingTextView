//
//  JGCGrowingTextView.swift
//  JGCGrowingTextViewDemo
//
//  Created by Javier Garcia Castro on 22/12/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

@objc protocol JGCGrowingTextViewDelegate {
    func updateFrames(parentViewHeight: CGFloat)
}

class JGCGrowingTextView: UIView, UITextViewDelegate {


//    @IBOutlet weak var commentView: UIView!
//    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dismissKeyboardButton: UIButton!
    @IBOutlet weak var dismissKeyboardButtonHeightConstraint: NSLayoutConstraint!
    
    var textView: UITextView?
    var delegate: JGCGrowingTextViewDelegate?
    var view: UIView?
    var parentView: UIView?
//    var dismissKeyboardButton: UIButton?
//    var dismissKeyboardButtonHeightConstraint: NSLayoutConstraint?
//    var parentViewHeightConstraint: NSLayoutConstraint?
//    var parentViewBottomConstraint: NSLayoutConstraint?

    var kPreferredTextViewToKeyboardOffset: CGFloat = 0.0
    var keyboardFrame: CGRect = CGRect.null
    var keyboardIsShowing: Bool = false
    var originParentView: CGPoint = CGPoint.zero
    
    
    // Mark: - Initialize
    
    
    ////
    
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
    
    
    
    
    
    
    
    
    /////
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        layoutIfNeeded()
//
//    }
//
//    func xibSetup() {
//        view = loadViewFromNib()
//        // use bounds not frame or it'll be offset
//        view?.frame = bounds
//        // Make the view stretch with containing view
//        view?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
//        // Adding custom subview on top of our view (over any custom drawing > see note below)
//        addSubview(view!)
//    }
//
//    func loadViewFromNib() -> UIView {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: "JGCGrowingTextView", bundle: bundle)
//        // Assumes UIView is top level and only object in CustomView.xib file
//        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
//
//        return view
//    }
//
//    init() {
//        super.init(frame: CGRect.zero)
//        xibSetup()
//    }
//
//    convenience init(delegate:JGCGrowingTextViewDelegate, parentView: UIView, dismissButton: UIButton, dismissButtonHeightConstraint: NSLayoutConstraint, growingTVContainerHeighConstraint: NSLayoutConstraint, growingTVContainerBottomConstraint: NSLayoutConstraint) {
//        self.init()
//        self.delegate = delegate
//        self.parentView = parentView
//        self.dismissKeyboardButton = dismissButton
//        self.dismissKeyboardButtonHeightConstraint = dismissButtonHeightConstraint
//        self.parentViewBottomConstraint = growingTVContainerBottomConstraint
//        self.parentViewHeightConstraint = growingTVContainerHeighConstraint
//        initialize()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
    // MARK: - Private Methods
    
    func initialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.textView = UITextView.init(frame: frame)
        self.textView?.delegate = self
        addSubview(textView!)
        UIView.embedView(view: textView!)
        
        
//        self.parentView?.addSubview(self)
//        UIView.embedView(view: self)

//        self.addConstraintsToView(view:self, parentView:self.parentView!)
    }
    
    func addConstraintsToView(view: UIView, parentView: UIView) {
        
        let mainWindow: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: NSMutableArray = NSMutableArray.init()
        
        let metrics:[String:Any] = ["height":parentView.frame.height, "width":parentView.frame.width]
        
        constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "H:[view(width)]", options: [], metrics: metrics, views: ["view":view]))
        constraints.addObjects(from: NSLayoutConstraint.constraints(withVisualFormat: "V:[view(height)]", options: [], metrics: metrics, views: ["view":view]))
        
        constraints.add(NSLayoutConstraint.init(item: view, attribute: .centerY, relatedBy: .equal, toItem: parentView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        constraints.add(NSLayoutConstraint.init(item: view, attribute: .centerX, relatedBy: .equal, toItem: parentView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        view.superview?.addConstraints(constraints as NSArray as! [NSLayoutConstraint])
        
//        self.frame = CGRect.init(x: 0, y: 0, width: 320.0, height: self.frame.height)

    }
    
    
    //Keyboard methods
    
    @objc func keyBoardWillShow(notification: Notification) {
        self.keyboardIsShowing = true
        if let info = notification.userInfo {
            self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.originParentView = self.frame.origin
           // subo addItemView para que no oculte el teclado al textView
//            self.parentView?.frame.origin = CGPoint.init(x: (self.parentView?.frame.origin.x)!, y: (self.parentView?.frame.origin.y)! - ((self.parentView?.frame.size.height)! - self.keyboardFrame.origin.y))
                        self.arrangeViewOffsetFromKeyboard()
            //despliego el botton dismiss hasta el teclado
            self.dismissKeyboardButtonHeightConstraint?.constant = keyboardFrame.origin.y
        }
    }
    
    @objc func keyBoardWillHide(notification: Notification) {
        self.keyboardIsShowing = false
        self.returnViewToInitialFrame()
        self.frame.origin = self.originParentView
        //pliego el botton dismiss hasta arriba
        self.dismissKeyboardButtonHeightConstraint?.constant = 0
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
        
//        self.delegate?.updateFrames(parentViewHeight: newContainerViewFrame.height)
        self.heightConstraint?.constant = newContainerViewFrame.height
        self.frame = newContainerViewFrame
        
    }
    
    
    // MARK: - Public Methods

    func userDidTapDismissButton() {
        dismissKeyboardButtonHeightConstraint?.constant = 0
        self.endEditing(true)
    }
    
    //UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(self.keyboardIsShowing) {
            //            self.arrangeViewOffsetFromKeyboard()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textViewFixedWidth: CGFloat = self.textView!.frame.size.width
        let newSize: CGSize = self.textView!.sizeThatFits(CGSize.init(width: textViewFixedWidth, height: CGFloat(MAXFLOAT)))
        var newFrame: CGRect = self.textView!.frame
        let heightDifference = (self.textView?.frame.height)! - newSize.height
        
        if (abs(heightDifference) > 6 && (self.frame.origin.y + self.frame.origin.y + self.frame.height) < (self.keyboardFrame.origin.y - 20.0)) {
            newFrame.size = CGSize.init(width: fmax(newSize.width, textViewFixedWidth), height: newSize.height)
            newFrame.offsetBy(dx: 0.0, dy: heightDifference)
            
            updateParentView(heightDifference: heightDifference)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
}
