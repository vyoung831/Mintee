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
    
    @State var errorMessage: String = ""
    @State var alertTitle: String = ""
    @State var alertMessage: String = "To re-enable access, please go to Settings and turn on Mintee's Calendar permissions"
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
     Groups fetched Tasks by `name` and adds events for them to the user's Calendar or Reminders.
     - parameter type: The type (calendar event or reminder) of event to add to the user's Calendar.
     */
    private func addEKEvents(_ type: EKEntityType) {
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
                                addEKEvents(.event)
                                break
                            case .denied:
                                self.alertTitle = "Access to Calendar was Denied"
                                self.showingAlert = true; break
                            case .restricted:
                                self.alertTitle = "Access to Calendar is Restricted"
                                self.showingAlert = true; break
                            case .notDetermined:
                                EventsCalendarManager.shared.requestStoreAccess(type: .event, completion: { accessGranted, error in
                                    if accessGranted {
                                        addEKEvents(.event)
                                    }
                                })
                                break
                            @unknown default:
                                break
                            }
                        }, label: {
                            SettingsCard(icon: Image(systemName: "calendar"),
                                         label: "Apple Calendar",
                                         subtextIcon: Image(systemName: "checkmark"),
                                         subtext: EventsCalendarManager.shared.storeAuthStatus(.event) == .authorized ? "Linked" : nil )
                                .frame(width: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth,
                                       height: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth * self.cardHeightMultiplier,
                                       alignment: .center)
                        })
                        
                        Button(action: {
                            switch EventsCalendarManager.shared.storeAuthStatus(.reminder) {
                            case .authorized:
                                addEKEvents(.reminder)
                                break
                            case .denied:
                                self.alertTitle = "Access to Reminders was Denied"
                                self.showingAlert = true; break
                            case .restricted:
                                self.alertTitle = "Access to Reminders is Restricted"
                                self.showingAlert = true; break
                            case .notDetermined:
                                EventsCalendarManager.shared.requestStoreAccess(type: .reminder, completion: { accessGranted, error in
                                    if accessGranted {
                                        addEKEvents(.reminder)
                                    }
                                })
                                break
                            @unknown default:
                                break
                            }
                        }, label: {
                            SettingsCard(icon: Image(systemName: "list.bullet"),
                                         label: "Apple Reminders",
                                         subtextIcon: Image(systemName: "checkmark"),
                                         subtext: EventsCalendarManager.shared.storeAuthStatus(.reminder) == .authorized ? "Linked" : nil )
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
