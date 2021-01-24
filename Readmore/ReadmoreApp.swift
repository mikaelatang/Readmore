//
//  ReadmoreApp.swift
//  Readmore
//
//  Created by Mikaela Tang on 2020-12-30.
//

import SwiftUI
import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct Testing_SwiftUI2App: App {

    // inject into SwiftUI life-cycle via adaptor !!!
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if Auth.auth().currentUser == nil {
                    ContentView(hasCurrentUser: false)
                }
                
                else {
                    ContentView(hasCurrentUser: true)
                }
            }
        }
    }
}
