//
//  ChatInteractor.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 30/10/24.
//

import Foundation

// MARK: - Interactor Protocol
protocol ChatInteractorProtocol {
    func processMessage(_ message: String)
}

class ChatReverseInteractor: ChatInteractorProtocol {
    
    weak var presenter: ChatInteractorOutputProtocol?
    
    // MARK: - Reverse Message Function
    func processMessage(_ message: String) {
        Task {
            // Perform the reversal on a background thread
            let reversedMessage = await performReversal(on: message)
            
            // Send the result back to the presenter on the main thread
            DispatchQueue.main.async {
                self.presenter?.didReceiveMessage(reversedMessage)
            }
        }
    }
    
    private func performReversal(on message: String) async -> String {
        try? await Task.sleep(for: .seconds(0.5))
        return String(message.reversed())
    }
}

