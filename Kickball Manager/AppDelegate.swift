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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow? = {
        let win = UIWindow(frame: UIScreen.main.bounds)
        win.backgroundColor = UIColor.white
//        win.makeKeyAndVisible()
        return win
    }()
    
    private let logger = Logger(source: "AppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        FirebaseApp.configure()
        // Check for authorized user
        if let user = FUIAuth.defaultAuthUI()?.auth!.currentUser {
            // Continue
            continueAuth(with: user)
            
//            print("&& USER EXISTS: \(user.displayName), EMAIL: \(user.email)")
//            window!.rootViewController = PlayerViewController()
//            window!.makeKeyAndVisible()
        } else {
            performSignIn()
        }
        
//        let defaultStore = FirestoreHelper.store
        
//        let player = Player(firstName: "first", lastName: "last", throwing: 2, running: 1, kicking: 13)
//        let encoder = JSONEncoder()
//        let json = try! encoder.encode(player)
//
//        let dict = try! JSONSerialization.jsonObject(with: json, options: []) as! [String: Any]
        
        // Add a new document with a generated ID
//        var ref: DocumentReference? = nil
//        ref = defaultStore.collection("users").addDocument(object: player) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
//        print("&& DOC AFTER ADD: \(ref), ID?: \(ref?.documentID)")
        
//        defaultStore.collection("users").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//
//                let objects: [Player] = querySnapshot!.getObjects()
//                print("&& TYPED OBJECTS?: \(objects)")
//            }
//        }
        
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
        print("&& GOT TO PROCEED WITH USER: \(user)")
        let controller = PlayerViewController(user: user)
        show(controller: controller)
    }
    
    private func show(controller: UIViewController) {
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
    }
    
    // MARK: Auth Logic
    
    private func continueAuth(with user: User) {
        // Get user's document
        KMUser.firCollection.document(user.uid).getDocument(completion: { (document, error) in
            guard document?.exists == true else {
                // Create
                self.logger.logInfo("New Firebase user [\(user.uid)] not found. Creating.")
                self.createNativeUser(for: user)
                return
            }
            // Proceed with launch
            self.proceed(with: KMUser(firToken: user.uid))
        })
        
//        // Get user's Firebase identifying token
//        user.getIDToken(completion: { (token, error) in
//            guard let token = token else {
//                // TODO: SIGN OUT?
//                print("&& FAILED TO GET TOKEN WITH ERROR: \(error)")
//                fatalError("Handle this")
//            }
//            // Retrieve user document
//            Firestore.firestore().collection("users").document(token).getDocument(completion: { (document, error) in
//                guard document?.exists == true else {
//                    // Create
//                    self.logger.logInfo("New Firebase user [\(user.email ?? "<no email>")] not found. Creating.")
//                    self.createNativeUser(with: token)
//                    return
//                }
//                // Proceed with launch
//                self.proceed(with: KMUser(firToken: token))
//            })
//        })
    }
    
    private func createNativeUser(for firUser: User) {
        // Create document
        KMUser.firCollection.document(firUser.uid).setData([:]) { (error) in
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

