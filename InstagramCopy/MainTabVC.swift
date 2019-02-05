//
//  MainTabVC.swift
//  InstagramCopy
//
//  Created by Didar Naurzbayev on 2/4/19.
//  Copyright © 2019 Didar Naurzbayev. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()


        //delegate
        self.delegate = self
        
        // configure view controller
        configureViewControllers()
        
        // user validation
        checkIfUserIsLoggedIn()
        
    }
    
    //func to create VC that exists within TabBarVC
    func configureViewControllers(){
        //home feed controller
        let feedVC = constructNavController(unselectedImage: UIImage(named: "home_unselected.png")!, selectedImage: UIImage(named: "home_selected.png")!, rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        // search feed controller
        let searchVC = constructNavController(unselectedImage: UIImage(named: "search_unselected.png")!, selectedImage: UIImage(named: "search_selected.png")!, rootViewController: SearchVC())
        
        // select image controller
        let uploadPostVC = constructNavController(unselectedImage: UIImage(named: "plus_unselected.png")!, selectedImage: UIImage(named: "plus_unselected.png")!)
        
        // notification controller
        let notificationVC = constructNavController(unselectedImage:  UIImage(named: "like_selected.png")!, selectedImage: UIImage(named: "like_selected.png")!, rootViewController: NotificationsVC())
        
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: UIImage(named: "profile_unselected.png")!, selectedImage: UIImage(named: "profile_selected.png")!, rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controllers to be added to tab controller
        viewControllers = [feedVC, searchVC, uploadPostVC, notificationVC, userProfileVC]
        // tab bar tint color
        tabBar.tintColor = .black
    }
    
    
    //construct navigation controller
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        //construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.image = selectedImage
        navController.navigationBar.tintColor = .black
        
        //return nav controller
        return navController
    }

    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    
    
    
    
    
    
}
