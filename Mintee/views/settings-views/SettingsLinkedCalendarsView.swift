//
//  SettingsLinkedCalendarsView.swift
//  Mintee
//
//  Created by Vincent Young on 8/23/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import SwiftUI

struct SettingsLinkedCalendarsView: View {
    
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
    
    var body: some View {
        
        GeometryReader { gr in
            if gr.size.width > 0 {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: getMockCollectionLayout(widthAvailable: gr.size.width).grid,
                              alignment: .center,
                              spacing: self.rowSpacing) {
                        Button(action: {
                            EventsCalendarManager.shared.requestAccess(completion: { accessGranted, error in
                                if !accessGranted {
                                    self.showingAlert = true
                                }
                            })
                        }, label: {
                            SettingsCard(icon: Image(systemName: "applelogo"), label: "Apple Calendar")
                                .frame(width: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth,
                                       height: getMockCollectionLayout(widthAvailable: gr.size.width).itemWidth * self.cardHeightMultiplier,
                                       alignment: .center)
                        })
                        .alert(isPresented: self.$showingAlert) {
                            Alert(title: Text("Access to Calendar is Restricted"),
                                  message: Text("To re-enable, please go to Settings and turn on Calendar Settings"),
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
