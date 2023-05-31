//
//  SendRecipientSendRecipientViewController.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 31/05/2023.
//

import UIKit

class SendRecipientViewController: GenericViewController<SendRecipientView> {

  // MARK: - Module

  private let presenter: SendRecipientPresenterInput

  // MARK: - Init

  init(presenter: SendRecipientPresenterInput) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    presenter.viewDidLoad()
  }
}

// MARK: - SendRecipientViewInput

extension SendRecipientViewController: SendRecipientViewInput {
  func showCommentLengthWarning(text: NSAttributedString) {
    customView.commentLimitLabel.isHidden = false
    customView.commentLimitLabel.attributedText = text
  }
  
  func hideCommentLengthWarning() {
    customView.commentLimitLabel.isHidden = true
  }
}

// MARK: - Private

private extension SendRecipientViewController {
  func setup() {
    title = "Recipient"
    setupCloseButton { [weak self] in
      self?.presenter.didTapCloseButton()
    }
    
    customView.addressTextField.placeholder = "Address or name"
    customView.addressTextField.delegate = self
    
    customView.commentTextField.placeholder = "Comment"
    customView.commentTextField.delegate = self
    
    customView.addressTextField.scanQRButton.addTarget(
      self,
      action: #selector(didTapScanQRButton),
      for: .touchUpInside)
  }
  
  func addressDidChange(_ textView: UITextView) {
    
  }
  
  func commentDidChange(_ textView: UITextView) {
    customView.commentVisibilityLabel.isHidden = textView.text.isEmpty
    presenter.didChangeComment(text: textView.text)
  }
}

// MARK: - UITextViewDelegate

extension SendRecipientViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    if textView == customView.addressTextField.textView {
      addressDidChange(textView)
    }
    if textView == customView.commentTextField.textView {
      commentDidChange(textView)
    }
  }
  
  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    return true
  }
}

// MARK: - Actions

private extension SendRecipientViewController {
  @objc
  func didTapScanQRButton() {
    presenter.didTapScanQRButton()
  }
}
