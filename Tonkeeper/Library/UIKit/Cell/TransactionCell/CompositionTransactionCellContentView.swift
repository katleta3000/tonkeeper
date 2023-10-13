//
//  CompositionTransactionCellContentView.swift
//  Tonkeeper
//
//  Created by Grigory on 6.8.23..
//

import UIKit

protocol CompositionTransactionCellContentViewDelegate: AnyObject {
  func compositionTransactionCellContentView(
    _ compositionTransactionCell: CompositionTransactionCellContentView,
    didSelectTransactionAt index: Int
  )
  func compositionTransactionCellContentView(
    _ compositionTransactionCell: CompositionTransactionCellContentView,
    didSelectNFTAt index: Int
  )
}

final class CompositionTransactionCellContentView: UIView, ContainerCollectionViewCellContent {
  struct Model {
    let transactionContentModels: [TransactionCellContentView.Model]
  }
  
  var transactionContentViews = [TransactionCellContentView]()
  
  weak var delegate: CompositionTransactionCellContentViewDelegate?
  
  weak var imageLoader: ImageLoader? {
    didSet { transactionContentViews.forEach { $0.imageLoader = imageLoader } }
  }
  
  func prepareForReuse() {
    transactionContentViews.forEach { $0.prepareForReuse() }
  }

  func configure(model: Model) {
    var views = [TransactionCellContentView]()
    for (index, transactionView) in transactionContentViews.enumerated() {
      guard index < model.transactionContentModels.count else {
        transactionView.removeFromSuperview()
        continue
      }
      views.append(transactionView)
    }
    model.transactionContentModels.enumerated().forEach { index, transactionModel in
      let view: TransactionCellContentView
      if index < views.count {
        view = views[index]
      } else {
        view = TransactionCellContentView()
        view.delegate = self
        view.addTarget(
          self,
          action: #selector(didTapTransaction(sender:)),
          for: .touchUpInside)
        view.imageLoader = imageLoader
        views.append(view)
        addSubview(view)
      }
      
      view.configure(model: transactionModel)
      view.isSeparatorVisible = index < model.transactionContentModels.count - 1
    }
    transactionContentViews = views
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()

    var y: CGFloat = 0
    transactionContentViews.forEach { view in
      let size = view.sizeThatFits(.init(width: bounds.size.width, height: 0))
      view.frame.origin = .init(x: 0, y: y)
      view.frame.size = size
      y = view.frame.maxY
    }
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let height = transactionContentViews.reduce(CGFloat(0)) { partialResult, view in
      return partialResult + view.sizeThatFits(size).height
      
    }
    return CGSize(width: size.width, height: height)
  }
  
  @objc
  private func didTapTransaction(sender: TransactionCellContentView) {
    guard let index = transactionContentViews.firstIndex(of: sender) else { return }
    delegate?.compositionTransactionCellContentView(self, didSelectTransactionAt: index)
  }
}

extension CompositionTransactionCellContentView: TransactionCellContentViewDelegate {
  func transactionCellDidTapNFTView(_ transactionCell: TransactionCellContentView) {
    guard let index = transactionContentViews.firstIndex(of: transactionCell) else { return }
    delegate?.compositionTransactionCellContentView(self, didSelectNFTAt: index)
  }
}