//
//  ChatViewController.swift
//  PheonTestChatApp
//
//  Created by Artemis Shlesberg on 30/10/24.
//
import UIKit

class ChatViewController: UIViewController, ChatViewProtocol, UITextViewDelegate {

    // MARK: - Properties
    var presenter: ChatPresenterProtocol?
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Message>!

    private let inputTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 20
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your message..."
        label.textColor = .systemGray5
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var inputFieldBottomConstraint: NSLayoutConstraint!
    private var inputTextViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chat"
        
        setupUI()
        setupCollectionView()
        setupDataSource()
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputTextView.delegate = self

        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(inputTextView)
        view.addSubview(placeholderLabel)
        view.addSubview(sendButton)

        inputFieldBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        inputTextViewHeightConstraint = inputTextView.heightAnchor.constraint(equalToConstant: 40)

        NSLayoutConstraint.activate([
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputFieldBottomConstraint,
            inputTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputTextViewHeightConstraint,
            
            placeholderLabel.leadingAnchor.constraint(equalTo: inputTextView.leadingAnchor, constant: 14),
            placeholderLabel.topAnchor.constraint(equalTo: inputTextView.topAnchor, constant: 8),
        ])
        
        adjustInputTextViewHeight()
        
        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalToConstant: inputTextViewHeightConstraint.constant),
            sendButton.heightAnchor.constraint(equalToConstant: inputTextViewHeightConstraint.constant),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sendButton.bottomAnchor.constraint(equalTo: inputTextView.bottomAnchor),
        ])
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: inputTextViewHeightConstraint.constant, weight: .bold, scale: .large)), for: .normal)
        inputTextView.layer.cornerRadius = inputTextViewHeightConstraint.constant / 2.0
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = false
            configuration.backgroundColor = .secondarySystemBackground
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: ChatMessageCell.reuseIdentifier)
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputTextView.topAnchor, constant: -8)
        ])
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Message>(collectionView: collectionView) { collectionView, indexPath, message in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath) as? ChatMessageCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: message)
            return cell
        }
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    // MARK: - Action Methods
    @objc private func sendMessage() {
        guard let text = inputTextView.text, !text.isEmpty else { return }
        inputTextView.text = ""
        placeholderLabel.isHidden = false
        sendButton.tintColor = .systemGray
        
        // Send the text to the presenter for processing
        presenter?.sendMessage(text)
        
        // Adjust height after sending
        adjustInputTextViewHeight()
    }

    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        adjustInputFieldForKeyboard(notification: notification, showing: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        adjustInputFieldForKeyboard(notification: notification, showing: false)
    }

    private func adjustInputFieldForKeyboard(notification: Notification, showing: Bool) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardHeight = keyboardFrame.height
        inputFieldBottomConstraint.constant = showing ? -keyboardHeight + view.safeAreaInsets.bottom - 8 : -16

        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Dismiss Keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !textView.text.isEmpty
        sendButton.tintColor = textView.text.isEmpty ? .systemGray : .systemBlue
        adjustInputTextViewHeight()
    }

    private func adjustInputTextViewHeight() {
        let size = CGSize(width: inputTextView.frame.width, height: .infinity)
        let estimatedSize = inputTextView.sizeThatFits(size)
        
        // Limit the maximum height to avoid overgrowing
        if estimatedSize.height <= 100 {
            inputTextViewHeightConstraint.constant = estimatedSize.height
            inputTextView.isScrollEnabled = false
        } else {
            inputTextView.isScrollEnabled = true
        }
    }

    // MARK: - ChatViewProtocol
    func displayMessage(_ message: Message) {
        var snapshot = dataSource.snapshot()
        
        if snapshot.sectionIdentifiers.isEmpty {
            snapshot.appendSections([0])
        }
        
        snapshot.appendItems([message], toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
