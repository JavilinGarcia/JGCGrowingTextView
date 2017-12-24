//
//  ViewController.swift
//  JGCGrowingTextViewDemo
//
//  Created by Javier Garcia Castro on 22/12/17.
//  Copyright © 2017 Javier Garcia Castro. All rights reserved.
//

import UIKit

class ViewController: UIViewController, JGCGrowingTextViewDelegate {

    @IBOutlet weak var growingTextViewContainer: UIView!
    @IBOutlet weak var growingTVHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var growingTVBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var growingDismissButton: UIButton!
    @IBOutlet weak var growingDismissButtonHeightConstraint: NSLayoutConstraint!
    
    var growingTextView: JGCGrowingTextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGrowingTextView()
    }

    // MARK: - Private Methods
    
    //Add calendarView
    func addGrowingTextView() {
        var frame = growingTextViewContainer.frame
        frame.size.width = UIScreen.main.bounds.size.width - 40.0
        
        growingTextView = JGCGrowingTextView.init(frame: frame, delegate: self)
        
        growingTextViewContainer.addSubview(growingTextView!)
        UIView.embedView(view: growingTextView!)
    }
    
    // MARK: - User Actions

    @IBAction func userDidTapDismissKeyboardButton (_ sender: Any) {
        growingTextView!.userDidTapDismissButton()
    }
    
    // MARK: - JGCGrowingTextViewDelegate
    
    func updateFrames(parentViewHeight: CGFloat) {
        growingTVHeightConstraint.constant = parentViewHeight
    }
    
    func updateGrowingBottomConstraint(constraintValue: CGFloat) {
        growingTVBottomConstraint.constant = constraintValue
    }
}

