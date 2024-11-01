//
//  ChatMessageCell.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 31/10/24.
//

import Foundation

import UIKit

class ChatMessageCell: UICollectionViewCell {
    static let reuseIdentifier = "ChatMessageCell"
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .rounded(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    private var bubbleViewLeadingConstraint: NSLayoutConstraint!
    private var bubbleViewTrailingConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bubbleView.addSubview(messageLabel)
        
        contentView.addSubview(bubbleView)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
        
        bubbleViewLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleViewTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.text
        messageLabel.textAlignment = message.isUserMessage ? .right : .left
        bubbleView.backgroundColor = message.isUserMessage ? .label : .systemBackground
        messageLabel.textColor = message.isUserMessage ? .systemBackground : .label
        
        bubbleViewLeadingConstraint.isActive = !message.isUserMessage
        bubbleViewTrailingConstraint.isActive = message.isUserMessage
        
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, message.isUserMessage ? .layerMinXMaxYCorner : .layerMaxXMaxYCorner ]
    }
}
