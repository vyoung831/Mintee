//
//  SettingsLinkedCalendarsView.swift
//  Mintee
//
//  Created by Vincent Young on 8/23/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI
import EventKit

struct SettingsLinkedCalendarsView: View {
    
    let enableCalendar_message: String = "To re-enable access, please go to Settings and turn on Mintee's Calendar permissions"
    let enableReminders_message: String = "To re-enable access, please go to Settings and turn on Mintee's Reminders permissions"
    let unlinkCalendar_message: String = "To unlink Mintee from Calendar, you must turn off access in Settings, then manually delete the \"Mintee\" Calendar."
    let unlinkReminders_message: String = "To unlink Mintee from Reminders, you must turn off access in Settings, then manually delete the \"Mintee\" Reminder list."
    
    @State var errorMessage: String = ""
    @State var alertTitle: String = ""
    @State var alertMessage: String = ""
    @State var showingAlert: Bool = false
    
    let rowSpacing: CGFloat = 20
    let idealItemWidth: CGFloat = 100
    let cardHeightMultiplier: CGFloat = 1.5
    
    /**
     Calls CollectionSizer.getVGridLayout with this View's idealItemWidth constant.
     - parameter totalWidth: Total width of View that can be used for sizing items, spacing, and left/right insets.
     - returns: Tuple containing array of GridItem with fixed item widths and spacing, itemWidth, and horizontal insets for the mock collection view.
     */
    private func getMockCollectionLayout(widthAvailable: CGFloat) -> ( grid: [GridItem], itemWidth: CGFloat, leftRightInset: CGFloat) {
        return CollectionSizer.getVGridLayout(widthAvailable: widthAvailable, idealItemWidth: self.idealItemWidth)
    }
    
    /**
     - parameter type: The type of EKCalendarItem to sync to the user's EKEventStore.
     */
    private func syncItems(_ type: EKEntityType) {
        do {
            switch type {
            case .event:
                try EventsCalendarManager.shared.syncEvents(); break
            case .reminder:
                try EventsCalendarManager.shared.syncReminders(); break
            @unknown default:
                break
            }
        } catch {
            self.errorMessage = ErrorManager.unexpectedErrorMessage
        }
    }
    
    var body: some View {
        
        GeometryReader { gr in
            if gr.size.width > 0 {
                ScrollView(.vertical, showsIndicators: true) {
                    if errorMessage.count > 0 { Text(errorMessage) }
                    LazyVGrid(columns: getMockCollectionLayout(widthAvailable: gr.size.width).grid, alignment: .center, spacing: self.rowSpacing) {
                        
                        Button(action: {
                            switch EventsCalendarManager.shared.storeAuthStatus(.event) {
                            case .authorized:
                                self.alertTitle = "Unlink Mintee"
                                self.alertMessage = unlinkCalendar_message
                                self.showingAlert = true; break
                            case .denied:
                                self.alertTitle = "Access to Calendar was Denied"
                                self.alertMessage = self.enableCalendar_message
                                self.showingAlert = true; break
                            case .restricted:
                                self.alertTitle = "Access to Calendar is Restricted"
                                self.alertMessage = self.enableCalendar_message
                                self.showingAlert = true; break
                            case .notDetermined:
                                EventsCalendarManager.shared.requestStoreAccess(type: .event, completion: { accessGranted, error in
                                    if accessGranted {
                                        syncItems(.event)
                                    }
                                })
                                break
                            @unknown default:
                                break
                            }
                        }, label: {
                            SettingsCard(icon: Image(systemName: "calendar"),
                                         label: "Apple Calendar",
                                         subtextIcon: EventsCalendarManager.shared.storeAuthStatus(.event) == .authorized ? Image(systemName: "checkmark") : nil)
                                .frame(width: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth,
                                       height: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth * self.cardHeightMultiplier,
                                       alignment: .center)
                        })
                        
                        Button(action: {
                            switch EventsCalendarManager.shared.storeAuthStatus(.reminder) {
                            case .authorized:
                                self.alertTitle = "Unlink Mintee"
                                self.alertMessage = unlinkReminders_message
                                self.showingAlert = true; break
                            case .denied:
                                self.alertTitle = "Access to Reminders was Denied"
                                self.alertMessage = enableReminders_message
                                self.showingAlert = true; break
                            case .restricted:
                                self.alertTitle = "Access to Reminders is Restricted"
                                self.alertMessage = enableReminders_message
                                self.showingAlert = true; break
                            case .notDetermined:
                                EventsCalendarManager.shared.requestStoreAccess(type: .reminder, completion: { accessGranted, error in
                                    if accessGranted {
                                        syncItems(.reminder)
                                    }
                                })
                                break
                            @unknown default:
                                break
                            }
                        }, label: {
                            SettingsCard(icon: Image(systemName: "list.bullet"),
                                         label: "Apple Reminders",
                                         subtextIcon: EventsCalendarManager.shared.storeAuthStatus(.reminder) == .authorized ? Image(systemName: "checkmark") : nil)
                                .frame(width: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth,
                                       height: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth * self.cardHeightMultiplier,
                                       alignment: .center)
                        })
                        
                    }
                    .alert(isPresented: self.$showingAlert) {
                        Alert(title: Text(alertTitle),
                              message: Text(alertMessage),
                              primaryButton: .default(Text("Settings"), action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                } else {
                                    let _ = ErrorManager.recordNonFatal(.urlCreationFailed,
                                                                        ["Message" : "SettingsLinkedCalendarView could not create a URL from UIApplication.openSettingsURLString",
                                                                         "UIApplication.openSettingsURLString" : UIApplication.openSettingsURLString])
                                }
                              }),
                              secondaryButton: .default(Text("Cancel"))
                        )
                    }
                }
                .padding(EdgeInsets(top: CollectionSizer.gridVerticalPadding,
                                    leading: getMockCollectionLayout(widthAvailable: gr.size.width).leftRightInset,
                                    bottom: CollectionSizer.gridVerticalPadding,
                                    trailing: getMockCollectionLayout(widthAvailable: gr.size.width).leftRightInset))
            }
        }
        .navigationTitle(Text("Linked calendars"))
    }
    
}
