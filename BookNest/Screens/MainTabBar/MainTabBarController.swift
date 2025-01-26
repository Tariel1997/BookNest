import UIKit
import SwiftUI

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let homePageVC = HomePageViewController()
        let homeNavigationController = UINavigationController(rootViewController: homePageVC)
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        
        let cartView = CartView()
        let cartHostingController = UIHostingController(rootView: cartView)
        cartHostingController.tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)
        
        let booksView = BooksView()
        let booksHostingController = UIHostingController(rootView: booksView)
        booksHostingController.tabBarItem = UITabBarItem(title: "Books", image: UIImage(systemName: "books.vertical"), tag: 2)
        
        let profileView = ProfileView()
        let profileHostingController = UIHostingController(rootView: profileView)
        profileHostingController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 3)
        
        viewControllers = [homeNavigationController, cartHostingController, booksHostingController, profileHostingController]
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        tabBar.isTranslucent = true
        tabBar.tintColor = UIColor(red: 241/255, green: 95/255, blue: 44/255, alpha: 1)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    func clearTabBarControllers() {
        viewControllers?.forEach { controller in
            if let navController = controller as? UINavigationController {
                navController.viewControllers.forEach { $0.removeFromParent() }
            }
            controller.removeFromParent()
            controller.view.removeFromSuperview()
        }
        viewControllers = nil
    }
}
