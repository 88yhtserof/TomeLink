//
//  TabBarController.swift
//  TomeLink
//
//  Created by 임윤휘 on 3/29/25.
//

import UIKit

final class TabBarController: UITabBarController {
    
    enum Item: Int, CaseIterable {
        case library
        case search
        
        var index: Int {
            return rawValue
        }
        
        var title: String {
            switch self {
            case .library:
                return "나의 서재"
            case .search:
                return "도서 검색"
            }
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
        let archiveReportory = ArchiveRepository()
        
        let libraryViewModel = LibraryViewModel(favoriteRepository: favoriteRepository, readingRepository: readingRepository, archiveRepository: archiveReportory)
        let libraryViewController = LibraryViewController(viewModel: libraryViewModel)
        
        let nertworMonitor = NetworkMonitorManager.shared
        let useCase = DefaultObserveNetworkStatusUseCase(monitor: nertworMonitor)
        let searchViewModel =  SearchViewModel(networkStatusUseCase: useCase)
        let searchViewController = SearchViewController(viewModel: searchViewModel)
        
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
