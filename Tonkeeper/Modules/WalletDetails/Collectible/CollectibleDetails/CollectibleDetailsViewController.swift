//
//  CollectibleDetailsCollectibleDetailsViewController.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 21/08/2023.
//

import UIKit

class CollectibleDetailsViewController: GenericViewController<CollectibleDetailsView> {

  // MARK: - Module

  private let presenter: CollectibleDetailsPresenterInput
  
  // MARK: - ImageLoader
  
  private var imageLoader = NukeImageLoader()

  // MARK: - Init

  init(presenter: CollectibleDetailsPresenterInput) {
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

// MARK: - CollectibleDetailsViewInput

extension CollectibleDetailsViewController: CollectibleDetailsViewInput {
  func updateTitle(_ title: String?) {
    navigationItem.title = title
  }
  
  func updateView(model: CollectibleDetailsView.Model) {
    customView.configure(model: model)
  }
}

// MARK: - Private

private extension CollectibleDetailsViewController {
  func setup() {
    customView.collectibleView.imageLoader = imageLoader
    setupSwipeButton { [weak self] in
      self?.presenter.didTapSwipeButton()
    }
    customView.detailsView.didTapOpenInExplorer = { [weak self] in
      self?.presenter.didTapOpenInExplorerButton()
    }
  }
}