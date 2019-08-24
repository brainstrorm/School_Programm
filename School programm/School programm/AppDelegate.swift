//
//  AppDelegate.swift
//  School programm
//
//  Created by Nikola on 22/07/2019.
//  Copyright © 2019 jonyvee. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Если пользователь авторизован, отправляем его на главный экран в зависимости от роли
        if User.root.userId != "" {
            loginToRole(roleType: User.root.role!)
        }
        window?.makeKeyAndVisible()
        
        return true
    }
    
    
    override init() {
        
        // Требованеие от firebase, чтобы прописывать в init
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    
    func switchToPupilMainView() {
        self.window?.endEditing(true)
        let storyboard = UIStoryboard.init(name: "Pupil", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "pupil")
        self.window?.rootViewController = nav
    }
    
    func switchToTeacherMainView() {
        self.window?.endEditing(true)
        let storyboard = UIStoryboard.init(name: "Teacher", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "teacher")
        self.window?.rootViewController = nav
    }
    
    func switchToParentMainView() {
        self.window?.endEditing(true)
        let storyboard = UIStoryboard.init(name: "Parent", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "parent")
        self.window?.rootViewController = nav
    }
    
    func switchToAdminMainView() {
        self.window?.endEditing(true)
        let storyboard = UIStoryboard.init(name: "Administrator", bundle: nil)
        let nav = storyboard.instantiateViewController(withIdentifier: "administrator")
        self.window?.rootViewController = nav
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

