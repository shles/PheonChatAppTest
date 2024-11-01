//
//  ChatPresenter.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 30/10/24.
//
import Foundation

// MARK: - View Protocol
protocol ChatViewProtocol: AnyObject {
    func displayMessage(_ message: Message)
}

// MARK: - Presenter Protocol
protocol ChatPresenterProtocol {
    func sendMessage(_ text: String)
}

// MARK: - Interactor Output Protocol
protocol ChatInteractorOutputProtocol: AnyObject {
    func didReceiveMessage(_ message: String)
}

// MARK: - ChatPresenter
class ChatPresenter: ChatPresenterProtocol {
    
    weak var view: ChatViewProtocol?
    var interactor: ChatInteractorProtocol
    var router: ChatRouterProtocol
    
    // MARK: - Initializer
    init(view: ChatViewProtocol, interactor: ChatInteractorProtocol, router: ChatRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - Handle Message Sending
    func sendMessage(_ text: String) {
        // Send text to interactor for processing
        interactor.processMessage(text)
        
        // Display the original message immediately in the chat
        let userMessage = Message(text: text, isUserMessage: true)
        view?.displayMessage(userMessage)
    }
}

// MARK: - ChatInteractor Output Extension
extension ChatPresenter: ChatInteractorOutputProtocol {
    func didReceiveMessage(_ message: String) {
        let responseMessage = Message(text: message, isUserMessage: false)
        view?.displayMessage(responseMessage)
    }
}

