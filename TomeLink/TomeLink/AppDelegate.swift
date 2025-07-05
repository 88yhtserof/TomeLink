//
//  AppDelegate.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import UIKit
import CoreData
import UserNotifications

import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureNavigationBarAppearance()
        
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        registerForRemoteNotifications(application: application)
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

//MARK: - Appearance
extension  AppDelegate {
    
    func configureNavigationBarAppearance() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backgroundColor = TomeLinkColor.background
        appearance.shadowColor = .clear
        appearance.backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().tintColor = TomeLinkColor.title
        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.left")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.left")
        
    }
}

//MARK: - Notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func registerForRemoteNotifications(application: UIApplication) {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error requesting authorization: \(error)")
                return
            }
            
            if success {
                print("Successfully registered for remote notifications.")
            } else {
                print("Failed to register for remote notifications.")
            }
        }
        
        application.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        print("Foreground notification: \(userInfo)")
        
        if let isbn = userInfo["isbn"] as? String {
            print("Notification type: \(isbn)")
            
            // 알림 저장
          }
        
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Background: User tapped notification: \(userInfo)")
        
        if let isbn = userInfo["isbn"] as? String {
            print("isbn: \(isbn)")
            let networkMonitor = NetworkMonitorManager.shared
            let networkStatusUseCase = DefaultObserveNetworkStatusUseCase(monitor: networkMonitor)
            let searchUseCase = SearchUseCase(searchRepository: LiveSearchRepository())
            let notificationUseCase = NotificationUseCase(notificationRepository: LiveNotificationRepository(), notificationTopicsSubscribe: NotificationTopicsSubscribeManager())
            let notiListViewModel = NotiListViewModel(isbn: isbn, networkStatusUseCase: networkStatusUseCase, searchUseCase: searchUseCase, notificationUseCase: notificationUseCase)
            let notiListViewController = NotiListViewController(viewModel: notiListViewModel)
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootVC = window.rootViewController,
               let tabBarVC = rootVC as? TabBarController,
               let mainVC =  tabBarVC.viewControllers?.first,
               let naviVC = mainVC as? UINavigationController {
                naviVC.pushViewController(notiListViewController, animated: true)
            }
            
        }
        completionHandler()
    }
}

//MARK: - Firebase Messaging Delegate

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM registration token: \(fcmToken ?? "")")
    }
}
