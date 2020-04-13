//
//  TodayView.swift
//  Mu
//
//  Created by Vincent Young on 4/8/20.
//  Copyright © 2020 Vincent Young. All rights reserved.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Today landing page")
            }
            .navigationBarTitle("Today")
            .navigationBarItems(trailing: HStack(alignment: .center, spacing: 10, content: {
                
                Button(action: {
                    print("Add button pressed")})
                {
                    Image(systemName: "plus.circle")
                }
                
                Button(action: {
                    print("Date button pressed")})
                {
                    Image(systemName: "calendar")
                }
                
            })
                .foregroundColor(.black)
                .scaleEffect(1.5)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
            )
        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}
