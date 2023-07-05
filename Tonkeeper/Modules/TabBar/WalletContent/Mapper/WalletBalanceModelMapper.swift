//
//  WalletBalanceModelMapper.swift
//  Tonkeeper
//
//  Created by Grigory on 2.7.23..
//

import Foundation
import WalletCore

final class WalletBalanceModelMapper {
  func map(pages: [WalletBalanceModel.Page]) -> [WalletContentPage] {
    return pages.map { page in
      let sections = page.sections.map { map(section: $0) }
      return WalletContentPage(title: page.title, sections: sections)
    }
  }
}

private extension WalletBalanceModelMapper {
  func map(section: WalletBalanceModel.Section) -> TokensListSection {
    switch section {
    case let .token(tokens):
      let cellModels = tokens.map { map(token: $0) }
      return .init(type: .token, items: cellModels)
    case let .collectibles(collectibles):
      let cellModels = collectibles.map { map(collectible: $0) }
      return .init(type: .collectibles, items: cellModels)
    }
  }
  
  func map(token: WalletBalanceModel.Token) -> TokenListTokenCell.Model {
    let image: Image
    switch token.image {
    case .ton: image = .image(.Icons.tonIcon28, backgroundColor: .Constant.tonBlue)
    case .oldWallet: image = .image(.Icons.tonIcon28, backgroundColor: .Button.tertiaryBackground)
    case let .url(url): image = .url(url)
    }
    
    return .init(image: image,
                 title: token.title,
                 shortTitle: token.shortTitle,
                 price: token.price,
                 priceDiff: nil,
                 amount: token.topAmount,
                 fiatAmount: token.bottomAmount)
  }
  
  func map(collectible: WalletBalanceModel.Collectible) -> TokensListCollectibleCell.Model {
    .init(image: .url(collectible.imageURL),
          title: collectible.title,
          subtitle: collectible.subtitle)
  }
}