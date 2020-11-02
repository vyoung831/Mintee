//
//  TodayCollectionViewCell.swift
//  Mu
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
        guard let minOpInt = instance.targetSet?.minOperator,
              let maxOpInt = instance.targetSet?.maxOperator,
              let maxTarget = instance.targetSet?.max,
              let minTarget = instance.targetSet?.min else {
            // TO-DO: Implement presentation of completionMeter for Specific-type Tasks
            completionMeterHeightConstraint.isActive = false
            completionMeterHeightConstraint = NSLayoutConstraint(item: completionMeter,
                                                                 attribute: .height,
                                                                 relatedBy: .equal,
                                                                 toItem: self,
                                                                 attribute: .height,
                                                                 multiplier: instance.completion > 0 ? 1 : 0,
                                                                 constant: 0)
            completionMeterHeightConstraint.isActive = true
            completionMeter.backgroundColor = instance.completion > 0 ? .green : .red
            return
        }
        let minOp = SaveFormatter.getOperatorString(minOpInt)
        let maxOp = SaveFormatter.getOperatorString(maxOpInt)
        
        // Update target
        if minOp != .na && maxOp != .na { target.text = "\(minTarget.clean) \(minOp.rawValue) Target \(maxOp.rawValue) \(maxTarget.clean)" }
        if minOp != .na { target.text = "Target \(minOp.rawValue.replacingOccurrences(of: "<", with: ">")) \(minTarget.clean)" }
        if maxOp != .na { target.text = "\(maxOp.rawValue.replacingOccurrences(of: ">", with: "<")) \(maxTarget.clean)" }
        
        // Update status
        self.status.text = String(instance.completion.clean)
        
        // Update completionMeter
        completionMeterHeightConstraint.isActive = false
        completionMeterHeightConstraint = NSLayoutConstraint(item: completionMeter,
                                                             attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: self,
                                                             attribute: .height,
                                                             multiplier: CGFloat(TodayCollectionViewCell.getCompletionMeterPercentage(minOp: minOp, maxOp: maxOp, minTarget: minTarget, maxTarget: maxTarget, completion: instance.completion)),
                                                             constant: 0)
        completionMeterHeightConstraint.isActive = true
        completionMeter.backgroundColor = TodayCollectionViewCell.getCompletionMeterColor(minOp: minOp, maxOp: maxOp, minTarget: minTarget, maxTarget: maxTarget, completion: instance.completion)
        
    }
    
    /**
     For a Recurring-type Task, returns the percentage of a TodayCollectionViewCell's height that its completionMeter should be constrained to
     Evaluates the completion of a TaskInstance against the minimum operator and maximum operator of its targetSet's values.
     - parameter minOp: The minimum value operator for the TaskInstances's minimum target
     - parameter maxOp: The maximum value operator for the TaskInstances's maximum target
     - parameter minTarget: The TaskInstance's minimum target
     - parameter maxTarget: The TaskInstance's maximum target
     - parameter completion: The TaskInstance's current completion
     - returns: UIColor to set a TodayCollectionViewCell's completionMeter to
     */
    static func getCompletionMeterPercentage(minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator, minTarget: Float, maxTarget: Float, completion: Float) -> Float {
        switch minOp {
        case .na:
            switch maxOp {
            case .na:
                Crashlytics.crashlytics().log("TodayCollectionViewCell.getCompletionMeterPercentage accessed a TaskInstance whose targetSet had (minOperator == .na && maxOperator == .na)")
                exit(-1)
            default:
                return min(completion / maxTarget, 1)
            }
        default:
            switch maxOp {
            case .na:
                return min(completion / minTarget, 1)
            default:
                return min(completion / maxTarget, 1)
            }
        }
    }
    
    /**
     For a Recurring-type Task, returns the UIColor that a TodayCollectionViewCell's completionMeter's background should be set to.
     Red/green are used to represent the target not being met or being met, respectively.
     Yellow is returned if one of the operators is non-inclusvie and the current completion is equal to that target
     - parameter minOp: The minimum value operator for the TaskInstances's minimum target
     - parameter maxOp: The maximum value operator for the TaskInstances's maximum target
     - parameter minTarget: The TaskInstance's minimum target
     - parameter maxTarget: The TaskInstance's maximum target
     - parameter completion: The TaskInstance's current completion
     - returns: UIColor to set a TodayCollectionViewCell's completionMeter to
     */
    static func getCompletionMeterColor(minOp: SaveFormatter.equalityOperator, maxOp: SaveFormatter.equalityOperator, minTarget: Float, maxTarget: Float, completion: Float) -> UIColor {
        
        var minSatisfied: Bool = true
        var maxSatisfied: Bool = true
        
        switch minOp {
        case .lt:
            if completion == minTarget { return .yellow }
            minSatisfied = (completion > minTarget); break
        case .lte: minSatisfied = (completion >= minTarget); break
        case .eq: return (completion == minTarget) ? .green : .red
        default: break
        }
        
        switch maxOp {
        case .lt:
            if completion == maxTarget { return .yellow }
            maxSatisfied = (completion < maxTarget); break
        case .lte: maxSatisfied = completion <= maxTarget; break
        case .eq: return (completion == maxTarget) ? .green : .red
        default: break
        }
        
        return (minSatisfied && maxSatisfied) ? .green : .red
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
