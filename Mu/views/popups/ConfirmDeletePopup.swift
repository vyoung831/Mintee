//
//  ConfirmDeletePopup.swift
//  Mu
//
//  Created by Vincent Young on 6/10/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct ConfirmDeletePopup: View {
    
    // MARK: - Properties
    
    let hstackSpacing: CGFloat = 25
    let vstackSpacing: CGFloat = 25
    let vstackPadding: CGFloat = 25
    let buttonWidth: CGFloat = 75
    
    var deleteMessage: String
    var deleteList: [String]
    var delete: () -> ()
    @Binding var isBeingPresented: Bool
    
    var body: some View {
        
        VStack(alignment: .center, spacing: vstackSpacing) {
            
            // MARK: - Header and messages
            
            Group {
                Text("Confirm Delete")
                    .font(.headline)
                
                Text(self.deleteMessage)
                    .multilineTextAlignment(.center)
                
                if self.deleteList.count > 0 {
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(0 ..< self.deleteList.count, id: \.self) { idx in
                            Text(self.deleteList[idx])
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            
            // MARK: - Yes/No buttons
            GeometryReader { geometry in
                HStack(alignment: .center, spacing: self.hstackSpacing) {
                    
                    Button(action: {
                        self.isBeingPresented = false
                        self.delete()
                    }, label: {
                        Text("Yes")
                            .frame(width: min((geometry.size.width - self.hstackSpacing)/2,75))
                            .padding(.all, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                    })
                    
                    Button(action: {
                        self.isBeingPresented = false
                    }, label: {
                        Text("No")
                            .frame(width: min((geometry.size.width - self.hstackSpacing)/2,75))
                            .padding(.all, 10)
                            .background(Color.init("default-button-colors"))
                            .foregroundColor(Color.init("default-button-text-colors"))
                            .cornerRadius(5)
                    })
                    
                }
            }
        }
        .padding(vstackPadding)
    }
}
