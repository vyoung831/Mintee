//
//  SetCountPopup.swift
//  Mu
//
//  Created by Vincent Young on 10/26/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct SetCountPopup: View {
    
    @State var count: String
    @State var errorMessage: String = ""
    
    var done: ((Float) -> Void)
    var cancel: (() -> Void)
    
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .center, spacing: 25) {
                
                if errorMessage.count > 0 {
                    Text(errorMessage)
                        .background(Color.red)
                }
                
                GeometryReader { gr in
                    HStack(alignment: .center, spacing: 10) {
                        Spacer()
                        
                        Button(action: {
                            if let countCast = Float(count){
                                count = String((countCast.rounded(.up) - 1).clean)
                            }
                        }, label: {
                            Image(systemName: "minus.circle")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(themeManager.panelContent)
                        })
                        
                        TextField("", text: self.$count)
                            .keyboardType( .decimalPad )
                            .frame(width: gr.size.width/2)
                            .padding(10)
                            .border(themeManager.textFieldBorder, width: 2)
                            .background(Color(UIColor.systemBackground))
                        
                        Button(action: {
                            if let countCast = Float(count){
                                count = String((countCast.rounded(.down) + 1).clean)
                            }
                        }, label: {
                            Image(systemName: "plus.circle")
                                .resizable()
                                .frame(width: 30, height: 30, alignment: .center)
                                .foregroundColor(themeManager.panelContent)
                        })
                        
                        Spacer()
                    }
                }
                
            }
            .padding(25)
            .background(themeManager.panel)
            .navigationTitle("Set Count")
            .navigationBarItems(leading:
                                    Button("Done", action: {
                                        if let valueToSave = Float(count){ done(valueToSave) }
                                        else { errorMessage = "Please remove invalid input" }
                                    })
                                    .foregroundColor(.accentColor),
                                trailing:
                                    Button("Cancel", action: {
                                        cancel()
                                    })
                                    .foregroundColor(.accentColor)
            )
            
        }
        .accentColor(themeManager.accent)
    }
}
