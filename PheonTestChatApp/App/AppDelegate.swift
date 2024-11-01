//
//  AppDelegate.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 30/10/24.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return true }
        let vc = ChatRouter.createChatModule()
        window.rootViewController = vc
        window.makeKeyAndVisible()
        return true
    }
}

