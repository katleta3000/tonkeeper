import Foundation
import TonAPI
import BigInt
import TonSwift

public final class SwapAvailableTokenController {

  private let wallet: Wallet
  private let jettonService: JettonService
  private let balanceService: BalanceService
  private let ratesStore: RatesStore
  private let tonRatesStore: TonRatesStore
  private let swapAvailableTokenMapper: SwapAvailableTokenMapper
  private let currencyStore: CurrencyStore
  private let amountFormatter: AmountFormatter

  init(wallet: Wallet,
       jettonService: JettonService,
       balanceService: BalanceService,
       ratesStore: RatesStore,
       tonRatesStore: TonRatesStore,
       swapAvailableTokenMapper: SwapAvailableTokenMapper,
       currencyStore: CurrencyStore,
       amountFormatter: AmountFormatter) {
    self.wallet = wallet
    self.jettonService = jettonService
    self.balanceService = balanceService
    self.ratesStore = ratesStore
    self.tonRatesStore = tonRatesStore
    self.swapAvailableTokenMapper = swapAvailableTokenMapper
    self.currencyStore = currencyStore
    self.amountFormatter = amountFormatter
  }

  public func receiveTokenList(exclude excludeToken: Token?) async -> [AvailableTokenModelItem] {
    async let availableJettons = try? jettonService.loadAvailable(wallet: wallet)
    async let walletBalance = try? balanceService.getBalance(wallet: wallet)
    let activeCurrency = await currencyStore.getActiveCurrency()
    var availableTokens = [AvailableTokenModelItem]()
    var alreadyAddedTokens = Set<Address>()
    if let balance = await walletBalance?.balance {
      let rates = ratesStore.getRates(jettons: balance.jettonsBalance.compactMap { $0.item.jettonInfo })

      // Add TON
      if excludeToken != .ton {
        availableTokens.append(swapAvailableTokenMapper.mapTon(
          balance: balance.tonBalance,
          rates: rates.ton, currency: activeCurrency)
        )
      }

      // Add jettons from balances
      var excludeTokenAddress: Address? = nil
      if case let .jetton(item) = excludeToken {
        excludeTokenAddress = item.walletAddress
      }

      let tokensOnBalance = swapAvailableTokenMapper.mapJettons(
        jettonsBalance: balance.jettonsBalance,
        jettonsRates: rates.jettonsRates,
        currency: activeCurrency,
        excludeTokenAddress: excludeTokenAddress
      )
      tokensOnBalance.forEach {
        if case let .jetton(item) = $0.token {
          alreadyAddedTokens.insert(item.jettonInfo.address)
        }
      }
      availableTokens.append(contentsOf: tokensOnBalance)
    }

    availableTokens.append(contentsOf: receivePredefinedTokenList(excludeAddresses: alreadyAddedTokens))
    // Add some random whitelisted jettons from blockchain
//    if let jettons = await availableJettons {
//      availableTokens.append(
//        contentsOf: jettons.compactMap {
//          $0.verification == .whitelist ?
//          AvailableTokenModelItem(
//            token: .jetton(.init(jettonInfo: $0, walletAddress: $0.address)),
//            amount: "0",
//            convertedAmount: "0"
//          ) : nil
//        }
//      )
//    }
    return availableTokens
  }

  private func receivePredefinedTokenList(excludeAddresses: Set<Address>) -> [AvailableTokenModelItem] {
    var tokens: [Token?] = SwapAvailableTokenFactory.make()
    return tokens.compactMap {
      if let token = $0, case let .jetton(item) = token, !excludeAddresses.contains(item.jettonInfo.address) {
        return AvailableTokenModelItem(token: token, amount: "0", convertedAmount: "0")
      }
      return nil
    }
  }
}
