//
//  Modifiers.swift
//  Mintee
//
//  Created by Vincent Young on 10/14/21.
//  Copyright © 2021 Vincent Young. All rights reserved.
//

import Foundation
import SwiftUI

struct MinteeAlertPresenter: ViewModifier {
    
    @State var isPresentingAlert: Bool = false
    @State var errorAlert_message: String = ""
    
    let taskSaveFailed_observer = NotificationCenter.default.publisher(for: .taskSaveFailed)
    let taskUpdateFailed_observer = NotificationCenter.default.publisher(for: .taskUpdateFailed)
    let taskDeleteFailed_observer = NotificationCenter.default.publisher(for: .taskDeleteFailed)
    let analysisSaveFailed_observer = NotificationCenter.default.publisher(for: .analysisSaveFailed)
    let analysisUpdateFailed_observer = NotificationCenter.default.publisher(for: .analysisUpdateFailed)
    let analysisDeleteFailed_observer = NotificationCenter.default.publisher(for: .analysisDeleteFailed)
    let analysisReorderFailed_observer = NotificationCenter.default.publisher(for: .analysisReorderFailed)
    let editAnalysis_initFailed_observer = NotificationCenter.default.publisher(for: .editAnalysis_initFailed)
    let editTask_initFailed_observer = NotificationCenter.default.publisher(for: .editTask_initFailed)
    let persistentStore_loadFailed_observer = NotificationCenter.default.publisher(for: .persistentStore_loadFailed)
    
    func updateErrorMessage(_ message: String) {
        self.isPresentingAlert = true
        self.errorAlert_message = message
    }
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: self.$isPresentingAlert) {
                Alert(title: Text("Title"), message: Text("Message"), dismissButton: .cancel(Text("Ok")))
            }
            .onReceive(taskSaveFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when saving the Task. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(taskUpdateFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when updating the Task. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(taskDeleteFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when deleting the Task. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(analysisSaveFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when saving the Analysis. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(analysisUpdateFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when updating the Analysis. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(analysisDeleteFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when deleting the Analysis. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(analysisReorderFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when saving the Analysis reordering. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(editAnalysis_initFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when trying to read the Task. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(editTask_initFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when trying to read the Analysis. We'll fix this as soon as we can. Please try again later.") }
            .onReceive(persistentStore_loadFailed_observer) { _ in updateErrorMessage("We're very sorry. Something went wrong when trying to load previously saved data. We'll fix this as soon as we can. Please try again later.") }
    }
}
