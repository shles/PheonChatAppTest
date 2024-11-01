//
//  ChatRouter.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 30/10/24.
//

import Foundation
import UIKit

protocol ChatRouterProtocol {
    static func createChatModule() -> UIViewController
}

class ChatRouter: ChatRouterProtocol {
    
    // MARK: - VIPER Module Creation
    
    static func createChatModule() -> UIViewController {
        let view = ChatViewController()
        let interactor = ChatReverseInteractor()
        let router = ChatRouter()
        let presenter = ChatPresenter(view: view,
                                      interactor: interactor,
                                      router: router)
        
        view.presenter = presenter
        interactor.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
