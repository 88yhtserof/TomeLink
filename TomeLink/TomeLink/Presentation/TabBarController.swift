//
//  TabBarController.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import UIKit

final class TabBarController: UITabBarController {
    
    enum Item: String, CaseIterable {
        case library = "나의 서재"
        case search = "도서 검색"
        
        var title: String {
            return rawValue
        }
        
        var normalImage: String {
            switch self {
            case .library:
                return "books.vertical"
            case .search:
                return "magnifyingglass"
            }
        }
        
        var selectedImage: String {
            switch self {
            case .library:
                return "books.vertical.fill"
            case .search:
                return "magnifyingglass"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        configureTabBarAppearance()
    }
}

//MARK: - Configuration
private extension TabBarController {
    func configureViewControllers() {
        
        let favoriteRepository = FavoriteRepository()
        let readingRepository = ReadingRepository()
        let libraryViewModel = LibraryViewModel(favoriteRepository: favoriteRepository, readingRepository: readingRepository)
        let libraryViewController = LibraryViewController(viewModel: libraryViewModel)
        
        let searchViewController = SearchViewController()
        
        let viewControllers = [
            UINavigationController(rootViewController: libraryViewController),
            UINavigationController(rootViewController: searchViewController)
        ]
        
        zip(viewControllers, Item.allCases)
            .forEach{ viewController, item in
                viewController.delegate = self
                viewController.tabBarItem.title = item.title
                viewController.tabBarItem.image = UIImage(systemName: item.normalImage)
                viewController.tabBarItem.selectedImage = UIImage(systemName: item.selectedImage)
            }
        
        setViewControllers(viewControllers, animated: false)
    }
    
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.stackedLayoutAppearance.selected.iconColor = TomeLinkColor.title
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: TomeLinkColor.title]
        
        appearance.stackedLayoutAppearance.normal.iconColor = TomeLinkColor.subtitle
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: TomeLinkColor.subtitle]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

//MARK: - Navigation Delegate
extension TabBarController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.tabBar.isHidden = navigationController.viewControllers.count > 1
    }
}
