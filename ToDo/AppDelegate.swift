//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Domingo on 10/5/15.
//  Copyright (c) 2015 Universidad de Alicante. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let store = NSUbiquitousKeyValueStore.default

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if(store.synchronize()){
            print("Sincronización OK")
        }else{
            print("Problemas en la sincronización")
        }
        
        //Para ver cuando un valor cambia en otro dispositivo iCloud
        NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(muestraValoriCloud(notification:)),
                    name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                    object: nil)
        
        return true
    }
    
    @objc func muestraValoriCloud(notification: Notification){
            let valoriCloud = Int(store.longLong(forKey: "itemNum"))
            print("Recibida notificación del sistema con el valor: \(valoriCloud)")
            // Actualizamos el valor en el controller
            DispatchQueue.main.async {
                let application = UIApplication.shared
                
                if let controller = application.windows[0].rootViewController {
                    let miController: ToDoTableViewController = controller as! ToDoTableViewController
                    miController.getValueFromBackGround(itemNum: valoriCloud)
                }
            }
        }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let navigationController = self.window!.rootViewController as! UINavigationController
        let toDoTableViewController = navigationController.viewControllers[0] as! ToDoTableViewController
        toDoTableViewController.borraItems()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

