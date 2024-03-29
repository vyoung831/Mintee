//
//  TodayCollectionViewCell.swift
//  Mintee
//
//  Created by Vincent Young on 4/22/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import UIKit
import Firebase

class TodayCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    // Appearance
    let borderColor = UIColor.black.cgColor
    let borderWidth: CGFloat = 3
    let cornerRadius: CGFloat = 6
    private var completionMeterHeightConstraint = NSLayoutConstraint()
    
    // Subviews
    private var completionMeter = UIView()
    private var taskName = UILabel()
    private var target = UILabel()
    private var status = UILabel()
    private var editButton = UIButton(type: UIButton.ButtonType.system)
    private var setButton = UIButton(type: UIButton.ButtonType.system)
    
    enum meterStatus {
        case unsatisfactory
        case borderline
        case satisfactory
    }
    var completionMeterStatus: meterStatus = .satisfactory
    
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
        self.backgroundColor = UIColor(ThemeManager.getElementColor(.collectionItem, .system))
        
        let textColor = UIColor(ThemeManager.getElementColor(.collectionItemContent, .system))
        self.taskName.textColor = textColor
        self.target.textColor = textColor
        self.status.textColor = textColor
        setButton.setTitleColor(textColor, for: UIControl.State.normal)
        editButton.setTitleColor(textColor, for: UIControl.State.normal)        
    }
    
    // MARK: - UI updates
    
    public func setTaskName(taskName: String) {
        self.taskName.text = taskName
    }
    
    /**
     Deactivates, updates, and activates completionMeterHeightConstraint.
     completionMeter's height is constrained to represent the completion of instance against its minimum and/or maximum target(s).
     - parameter instance: TaskInstance whose completion (Float) is used to update completionMeter's constraints
     */
    public func updateAppearance(instance: TaskInstance) {
        
        guard let minOpInt = instance._targetSet?._minOperator,
              let maxOpInt = instance._targetSet?._maxOperator,
              let maxTarget = instance._targetSet?._max,
              let minTarget = instance._targetSet?._min else {
            // TO-DO: Implement presentation of completionMeter for Specific-type Tasks
            completionMeterHeightConstraint.isActive = false
            completionMeterHeightConstraint = NSLayoutConstraint(item: completionMeter,
                                                                 attribute: .height,
                                                                 relatedBy: .equal,
                                                                 toItem: self,
                                                                 attribute: .height,
                                                                 multiplier: instance._completion > 0 ? 1 : 0,
                                                                 constant: 0)
            completionMeterHeightConstraint.isActive = true
            completionMeter.backgroundColor = instance._completion > 0 ? .green : .red
            self.status.text = instance._completion > 0 ? "Done" : "To-do"
            return
        }
        
        guard let minOp = SaveFormatter.storedToEqualityOperator(minOpInt),
              let maxOp = SaveFormatter.storedToEqualityOperator(maxOpInt) else {
            
            var userInfo: [String : Any] = ["Message" : "TodayCollectionViewCell.updateAppearance() found invalid _minOperator or _maxOperator in a TaskInstance's TaskTargetSet"]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, instance._task.mergeDebugDictionary(userInfo: userInfo) )
            
            return
        }
        
        guard let completionMeterHeightPercentage = TodayCollectionViewCell.getCompletionMeterPercentage(minOp: minOp, maxOp: maxOp, minTarget: minTarget, maxTarget: maxTarget, completion: instance._completion) else {
            
            var userInfo: [String : Any] = ["Message" : "TodayCollectionViewCell.updateAppearance() received nil on call to TodayCollectionViewCell.getCompletionMeterPercentage()"]
            ErrorManager.recordNonFatal(.persistentStore_containedInvalidData, instance._task.mergeDebugDictionary(userInfo: userInfo) )
            
            return
        }
        
        // Update target
        target.text = TaskTargetSetView.getTargetString(minOperator: minOp,
                                                        maxOperator: maxOp,
                                                        minTarget: minTarget,
                                                        maxTarget: maxTarget)
        
        // Update status
        self.status.text = String(instance._completion.clean)
        
        // Update completionMeter
        completionMeterHeightConstraint.isActive = false
        completionMeterHeightConstraint = NSLayoutConstraint(item: completionMeter,
                                                             attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: self,
                                                             attribute: .height,
                                                             multiplier: CGFloat(completionMeterHeightPercentage),
                                                             constant: 0)
        completionMeterHeightConstraint.isActive = true
        self.completionMeterStatus = TodayCollectionViewCell.getCompletionMeterStatus(minOp: minOp, maxOp: maxOp, minTarget: minTarget, maxTarget: maxTarget, completion: instance._completion)
        updateCompletionMeterColor()
        
    }
    
    /**
     For a Recurring-type Task, returns the percentage of a TodayCollectionViewCell's height that its completionMeter should be constrained to
     Evaluates the completion of a TaskInstance against the minimum operator and maximum operator of its targetSet's values.
     - parameter minOp: The minimum value operator for the TaskInstances's minimum target
     - parameter maxOp: The maximum value operator for the TaskInstances's maximum target
     - parameter minTarget: The TaskInstance's minimum target
     - parameter maxTarget: The TaskInstance's maximum target
     - parameter completion: The TaskInstance's current completion
     - returns: (Optional) Float to set a TodayCollectionViewCell's completionMeterHeightConstraint to (in relation to the cell's height). Returns nil if min/max operator combo violates business logic.
     */
    static func getCompletionMeterPercentage(minOp: SaveFormatter.equalityOperator,
                                             maxOp: SaveFormatter.equalityOperator,
                                             minTarget: Float,
                                             maxTarget: Float,
                                             completion: Float) -> Float? {
        switch minOp {
        case .na:
            switch maxOp {
            case .eq:
                return nil
            case .na:
                return nil
            default:
                if maxTarget > 0 {
                    return completion <= 0 ? 0 : min(completion / maxTarget, 1)
                } else if maxTarget < 0 {
                    return completion >= 0 ? 0 : min(completion / maxTarget, 1)
                } else {
                    return 1
                }
            }
        case .eq:
            if minTarget > 0 {
                return completion <= 0 ? 0 : min(completion / minTarget, 1)
            } else if minTarget < 0 {
                return completion >= 0 ? 0 : min(completion / minTarget, 1)
            } else {
                return 1
            }
        default:
            switch maxOp {
            case .na:
                if minTarget > 0 {
                    return completion <= 0 ? 0 : min(completion / minTarget, 1)
                } else if minTarget < 0 {
                    return completion >= 0 ? 0 : min(completion / minTarget, 1)
                } else {
                    return 1
                }
            default:
                if completion <= minTarget {
                    return 0
                } else if completion < maxTarget {
                    return min( abs(completion - minTarget)/abs(maxTarget - minTarget), 1)
                } else {
                    return 1
                }
            }
        }
    }
    
    /**
     For the TodayCollectionViewCell of a recurring-type Task, returns the value of type meterStatus that the cell's completionMeterStatus should be set to.
     completionMeterStatus is used to determine what color to assign completionMeter's backgroundColor (light/dark mode is also factored into those decisions).
     - parameter minOp: The minimum value operator for the TaskInstances's minimum target
     - parameter maxOp: The maximum value operator for the TaskInstances's maximum target
     - parameter minTarget: The TaskInstance's minimum target
     - parameter maxTarget: The TaskInstance's maximum target
     - parameter completion: The TaskInstance's current completion
     - returns: meterStatus to set the cell's completionMeterStatus to
     */
    static func getCompletionMeterStatus(minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator, minTarget: Float, maxTarget: Float, completion: Float) -> meterStatus {
        
        var minSatisfied: Bool = true
        var maxSatisfied: Bool = true
        
        switch minOp {
        case .lt:
            if completion == minTarget { return .borderline }
            minSatisfied = (completion > minTarget); break
        case .lte:
            minSatisfied = (completion >= minTarget); break
        case .eq:
            return (completion == minTarget) ? .satisfactory : .unsatisfactory
        default:
            break
        }
        
        switch maxOp {
        case .lt:
            if completion == maxTarget { return .borderline }
            maxSatisfied = (completion < maxTarget); break
        case .lte:
            maxSatisfied = completion <= maxTarget; break
        case .eq:
            return (completion == maxTarget) ? .satisfactory : .unsatisfactory
        default:
            break
        }
        
        return (minSatisfied && maxSatisfied) ? .satisfactory : .unsatisfactory
    }
    
    /*
     Called when the collection of traits that describe this object's current environment changes.
     Makes call to update completionMeter's backgroundColor, in case userInterfaceStyle (light/dark mode) changed.
     */
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateCompletionMeterColor()
    }
    
    /**
     Updates the backgroundColor of completionMeter based on this object's existing completionMeterStatus and userInterfaceStyle (light/dark mode).
     */
    private func updateCompletionMeterColor() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            switch self.completionMeterStatus {
            case .borderline:
                self.completionMeter.backgroundColor = UIColor(hex: "ccc610ff"); break
            case .satisfactory:
                self.completionMeter.backgroundColor = UIColor(hex: "09b300ff"); break
            case .unsatisfactory:
                self.completionMeter.backgroundColor = UIColor(hex: "ad0c00ff"); break
            }
        case .light:
            switch self.completionMeterStatus {
            case .borderline:
                self.completionMeter.backgroundColor = .yellow; break
            case .satisfactory:
                self.completionMeter.backgroundColor = .green; break
            case .unsatisfactory:
                self.completionMeter.backgroundColor = UIColor(hex: "ff928aff"); break
            }
        default:
            break
        }
    }
    
    // MARK: - UI setup
    
    private func setUpCell() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = CGFloat(borderWidth)
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
        editButton.addTarget(self, action: #selector(editButtonPressed), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.rightAnchor).isActive = true
        
        // Set button
        setButton.setTitle("Set", for: UIControl.State.normal)
        setButton.addTarget(self, action: #selector(setButtonPressed), for: UIControl.Event.touchUpInside)
        self.contentView.addSubview(setButton)
        setButton.translatesAutoresizingMaskIntoConstraints = false
        setButton.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor).isActive = true
        setButton.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor).isActive = true
        
    }
    
    /**
     This function sets up all of completionMeter's autolayout constraints except for its height. This class expects that height constraint to be calculated when updateCompletionMeter() is called
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
