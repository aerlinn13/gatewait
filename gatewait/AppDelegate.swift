//
//  AppDelegate.swift
//  gatewait
//
//  Created by Danil on 09.10.2019.
//  Copyright © 2019 Danil Chernyshev. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        openRealm()
        print(Realm.Configuration.defaultConfiguration.fileURL)
        return true
    }
    
    func openRealm() {
    let bundlePath = Bundle.main.path(forResource: "db", ofType: "realm")!
    let defaultPath = Realm.Configuration.defaultConfiguration.fileURL!.path
    let fileManager = FileManager.default
        
    let config = Realm.Configuration(
        schemaVersion: 10,
        migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
            }
        })

    // Tell Realm to use this new configuration object for the default Realm
    Realm.Configuration.defaultConfiguration = config

    // Only need to copy the prepopulated `.realm` file if it doesn't exist yet
    if !fileManager.fileExists(atPath: defaultPath){
        print("use pre-populated database")
        do {
            try fileManager.copyItem(atPath: bundlePath, toPath: defaultPath)
            print("Copied")
        } catch {
            print(error)
        }
    }
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

