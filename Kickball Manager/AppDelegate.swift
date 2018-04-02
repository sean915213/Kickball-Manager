//
//  AppDelegate.swift
//  Kickball Manager
//
//  Created by Sean G Young on 10/20/17.
//  Copyright © 2017 Sean G Young. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import SGYSwiftUtility

//protocol TestProt { }
//extension TestProt {
//    func update<T>(property: KeyPath<Self, T?>, named name: String, completion: ((Error?) -> Void)? = nil) {
//
//        //        let p = \FirebaseTokenProtocol.firPathURL
//        //        p
//
//        let value: Any = self[keyPath: property] ?? "WTF?"
//        print("&& TEST VAL: \(value)")
////        let coal: Any? = value ?? "WTF?"
////        print("&& COAL: \(coal)")
////        firDocument.updateData([name: value], completion: completion)
//    }
//}
//
//class TestClass: TestProt {
//
//    var test: String?
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow? = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.backgroundColor = UIColor.white
        return win
    }()
    
    private let logger = Logger(source: "AppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        let cl = TestClass()
//        cl.update(property: \.test, named: "test")
//
//        print("&& FINISHED TEST")
//
//        return true;
        
        
        
        // Configure Firebase
        FirebaseApp.configure()
        
//        try! FUIAuth.defaultAuthUI()!.signOut()
        
        // Check for authorized user
        if let user = FUIAuth.defaultAuthUI()?.auth!.currentUser {
            // Continue
            continueAuth(with: user)
        } else {
            performSignIn()
        }
       
        return true
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    // MARK: Other Logic
    
    private func proceed(with user: KMUser) {
        // TODO: Assuming teams already exist.  Need a real initial flow.
        user.teamsCollection.getObjects { (teams: [Team]?, snapshot, error) in
            let team = teams!.first!
            let controller = TeamController(user: user, team: team)
            self.show(controller: UINavigationController(rootViewController: controller))
        }
        
//        let team = Team(name: "NEWER TEAM", owner: user)
//        try! user.firTeamsCollection.addObject(object: team, completion: { (error) in
//            print("&& FINISHED CREATING TEAM W/ ERROR: \(error)")
//        })
    }
    
    private func show(controller: UIViewController) {
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
    }
    
    // MARK: Auth Logic
    
    private func continueAuth(with user: User) {
        // Get user's document
        KMUser.globalCollection.document(user.uid).getDocument(completion: { (document, error) in
            guard document?.exists == true else {
                // Create
                self.logger.logInfo("New Firebase user [\(user.uid)] not found. Creating.")
                self.createNativeUser(for: user)
                return
            }
            // Proceed with launch
            self.proceed(with: KMUser(firToken: user.uid))
            // Seed players
            Mock.seedPlayers(forUser: KMUser(firToken: user.uid))
            print("&& SEEDED PLAYERS")
        })
    }
    
    private func createNativeUser(for firUser: User) {
        // Create document
        KMUser.globalCollection.document(firUser.uid).setData([:]) { (error) in
            if let error = error {
                fatalError("HANDLE THIS: \(error)")
            }
            // Proceed
            self.proceed(with: KMUser(firToken: firUser.uid))
        }
    }
    
    
    private func performSignIn() {
        // Setup Auth
        let authUI = FUIAuth.defaultAuthUI()
        authUI!.delegate = self
        // Assign providers
        let providers: [FUIAuthProvider] = [ FUIGoogleAuth() ]
        authUI!.providers = providers
        // Present controller
        let authViewController = authUI!.authViewController()
        show(controller: authViewController)
    }
    
    // MARK: FirebaseAuthUI Delegate Implementation
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("&& AUTH SIGNED IN WITH USER: \(user), ERROR: \(error)")
        guard let user = user else {
            // TODO: Show alert? Retry?
            fatalError("HANDLE THIS: \(error)")
        }
        // Continue through auth pipeline
        continueAuth(with: user)
    }
}

