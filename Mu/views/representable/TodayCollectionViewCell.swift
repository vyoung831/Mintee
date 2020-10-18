//
//  TodayCollectionViewCell.swift
//  Mu
//
//  Created by Vincent Young on 4/22/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit

class TodayCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    // Appearance
    let borderColor = UIColor.black.cgColor
    let borderWidth: CGFloat = 3
    let cornerRadius: CGFloat = 6
    private var completionPercentage: CGFloat = 0
    private var completionMeterHeightConstraint = NSLayoutConstraint()
    
    // Subviews
    private var completionMeter = UIView()
    private var taskName = UILabel()
    private var target = UILabel()
    private var status = UILabel()
    private var editButton = UIButton(type: UIButton.ButtonType.system)
    private var setButton = UIButton(type: UIButton.ButtonType.system)
    
    // MARK: - Closures
    
    // Closure to call when editButton is pressed. Should be set by the UICollectionViewDataSource
    var handleEditButtonPressed: (()->())?
    
    // Closure to call when setButton is pressed. Should be set by the UICollectionViewDataSource
    var handleSetButtonPressed: (()->())?
    
    /**
     Call the handleEditButtonPressed closure if it was set
     */
    @objc func editButtonPressed() {
        handleEditButtonPressed?()
    }
    
    /**
     Call the handleSetButtonPressed closure if it was set
     */
    @objc func setButtonPressed() {
        handleSetButtonPressed?()
    }
    
    // MARK: - Initializers
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpCell()
        observeNotificationCenter()
    }
    
    // MARK: - UI update notifications and handling
    
    private func observeNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChanged, object: nil)
    }
    
    @objc func updateTheme(){
        self.layer.borderColor = UIColor(ThemeManager.shared.collectionItemBorder).cgColor
    }
    
    // MARK: - UI updates
    
    public func setTaskName(taskName: String) {
        self.taskName.text = taskName
    }
    
    public func updateTaskStatus(newTarget: String, newStatus: CGFloat) {
        target.text = newTarget
        status.text = String(Float(newStatus))
    }
    
    /**
     This function replaces the completion meter's old height constraint with one with the updated completion percentage.
     */
    public func updateCompletionMeter(newCompletionPercentage: CGFloat) {
        completionPercentage = newCompletionPercentage
        removeConstraint(completionMeterHeightConstraint)
        completionMeterHeightConstraint = NSLayoutConstraint(item: completionMeter,
                                                             attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: self.contentView,
                                                             attribute: .height,
                                                             multiplier: completionPercentage,
                                                             constant: 0)
        completionMeterHeightConstraint.isActive = true
    }
    
    // MARK: - UI setup
    
    private func setUpCell() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = CGFloat(borderWidth)
        self.backgroundColor = .white
        setUpSubviews()
        updateTheme()
    }
    
    private func setUpSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setUpLabels()
        setUpButtons()
        setUpCompletionMeter()
    }
    
    /**
     This function sets up the cell's labels that display the Task name, target, and current status
     */
    private func setUpLabels() {
        
        // Target label
        target.adjustsFontSizeToFitWidth = true
        target.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false
        target.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        target.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        target.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Status label
        status.lineBreakMode = NSLineBreakMode.byTruncatingTail
        status.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        status.bottomAnchor.constraint(equalTo: target.topAnchor).isActive = true
        status.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        status.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Task name label
        taskName.textColor = .black
        taskName.lineBreakMode = NSLineBreakMode.byTruncatingTail
        taskName.textAlignment = NSTextAlignment.left
        self.contentView.addSubview(taskName)
        taskName.translatesAutoresizingMaskIntoConstraints = false
        taskName.bottomAnchor.constraint(equalTo: status.topAnchor).isActive = true
        taskName.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        taskName.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
    }
    
    /**
     This function sets up the cell's buttons and their target methods. Each button's target methods should have been set with a closure provided by the UICollectionViewDataSource
     */
    private func setUpButtons() {
        
        // Edit button
        editButton.setTitle("Edit", for: UIControl.State.normal)
        editButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Set button
        setButton.setTitle("Set", for: UIControl.State.normal)
        setButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        setButton.addTarget(self, action: #selector(setButtonPressed), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(setButton)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        setButton.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
    }
    
    /**
     This function sets up all of completionMeter's autolayout constraints except for its height. This class expects that height constraint to be calculated when updateCompletionPercentage()
     */
    private func setUpCompletionMeter() {
        completionMeter.layer.cornerRadius = cornerRadius
        self.addSubview(completionMeter)
        completionMeter.translatesAutoresizingMaskIntoConstraints = false
        completionMeter.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        completionMeter.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        completionMeter.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.sendSubviewToBack(completionMeter)
    }
    
}
