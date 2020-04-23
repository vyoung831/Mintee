//
//  TaskCardCollectionViewCell.swift
//  Mu
//
//  This UICollectionViewCell handles the presentation of Task cards in TodayViewController's collectionView
//
//  Created by Vincent Young on 4/5/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit

class TaskCardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    // Appearance constants
    let borderColor = UIColor.black.cgColor
    let borderWidth: CGFloat = 3
    let cornerRadius: CGFloat = 6
    
    // Subviews
    var completionMeter: UIView!
    var taskName: UILabel!
    var target: UILabel!
    var status: UILabel!
    var editButton: UIButton!
    var setButton: UIButton!
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UI setup
    
    private func setupCell() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor
        self.layer.borderWidth = CGFloat(borderWidth)
        setupSubviews()
    }
    
    private func setupSubviews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        setupLabels()
        setupButtons()
        setupCompletionMeter()
    }
    
    /**
     Setup the cell's labels that display the Task name, target, and current status
     */
    private func setupLabels() {
        
        // Target label
        target = UILabel()
        target.adjustsFontSizeToFitWidth = true
        target.textAlignment = NSTextAlignment.left
        target.text = "Target <= 45"
        
        self.contentView.addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false
        target.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        target.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        target.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Status label
        status = UILabel()
        status.lineBreakMode = NSLineBreakMode.byTruncatingTail
        status.textAlignment = NSTextAlignment.left
        status.text = "15 minutes"
        
        self.contentView.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        status.bottomAnchor.constraint(equalTo: target.topAnchor).isActive = true
        status.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        status.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Task name label
        taskName = UILabel()
        taskName.lineBreakMode = NSLineBreakMode.byTruncatingTail
        taskName.textAlignment = NSTextAlignment.left
        taskName.text = "Video games"
        
        self.contentView.addSubview(taskName)
        taskName.translatesAutoresizingMaskIntoConstraints = false
        taskName.bottomAnchor.constraint(equalTo: status.topAnchor).isActive = true
        taskName.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        taskName.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
    }
    
    /**
     Setup the cell's buttons and their target methods. Each button's target methods should have been set by TodayViewController by closure
     */
    private func setupButtons() {
        
        // Edit button
        editButton = UIButton(type: UIButton.ButtonType.system)
        editButton.setTitle("Edit", for: UIControl.State.normal)
        editButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: UIControl.Event.touchUpInside)
        
        self.contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Set button
        setButton = UIButton(type: UIButton.ButtonType.system)
        setButton.setTitle("Set", for: UIControl.State.normal)
        setButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
        setButton.addTarget(self, action: #selector(setButtonPressed), for: UIControl.Event.touchUpInside)
        
        self.contentView.addSubview(setButton)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        setButton.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
    }
    
    /**
     Setup the completion meter
     */
    private func setupCompletionMeter() {
        
        // Initialize completionMeter, using completionPercentage to set y-position and heigh
        let completionPercentage: CGFloat = 1/3
        completionMeter = UIView()
        completionMeter.backgroundColor = .green
        completionMeter.layer.cornerRadius = cornerRadius
        
        self.addSubview(completionMeter)
        completionMeter.translatesAutoresizingMaskIntoConstraints = false
        completionMeter.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: completionPercentage, constant: 0).isActive = true
        completionMeter.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        completionMeter.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        completionMeter.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        self.sendSubviewToBack(completionMeter)
        
    }
    
}
