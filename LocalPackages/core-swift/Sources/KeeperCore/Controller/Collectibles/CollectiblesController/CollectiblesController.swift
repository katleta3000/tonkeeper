import Foundation

public final class CollectiblesController {
  
  public var didUpdateIsConnecting: ((Bool) -> Void)?
  public var didUpdateActiveWallet: (() -> Void)?
  public var didUpdateIsEmpty: ((Bool) -> Void)?

  private let walletsStore: WalletsStore
  private let backgroundUpdateStore: BackgroundUpdateStore
  private let nftsStore: NftsStore
  
  init(walletsStore: WalletsStore,
       backgroundUpdateStore: BackgroundUpdateStore,
       nftsStore: NftsStore) {
    self.walletsStore = walletsStore
    self.backgroundUpdateStore = backgroundUpdateStore
    self.nftsStore = nftsStore
  }
  
  public var wallet: Wallet {
    walletsStore.activeWallet
  }
  
  public func start() async {
    _ = walletsStore.addEventObserver(self) { observer, event in
      switch event {
      case .didUpdateActiveWallet:
        Task { await observer.didChangeActiveWallet() }
      default: break
      }
    }
    
    _ = await backgroundUpdateStore.addEventObserver(self) { observer, event in
      switch event {
      case .didUpdateState(let backgroundUpdateState):
        observer.handleBackgroundUpdateState(backgroundUpdateState)
      case .didReceiveUpdateEvent:
        break
      }
    }
    
    _ = await nftsStore.addEventObserver(self) { observer, event in
      switch event {
      case .nftsUpdate(let nfts, let walletAddress):
        guard let address = try? observer.wallet.address, address == walletAddress else { return }
        observer.didUpdateIsEmpty?(nfts.isEmpty)
      }
    }
    
    if let address = try? wallet.address {
      let nfts = await nftsStore.getNfts(walletAddress: address)
      didUpdateIsEmpty?(nfts.isEmpty)
    }
  }
  
  public func updateConnectingState() async {
    let state = await backgroundUpdateStore.state
    handleBackgroundUpdateState(state)
  }
}

private extension CollectiblesController {
  func didChangeActiveWallet() async {
    guard let address = try? wallet.address else { return }
    let walletNfts = await nftsStore.getNfts(walletAddress: address)
    didUpdateActiveWallet?()
    didUpdateIsEmpty?(walletNfts.isEmpty)
  }
  
  func handleBackgroundUpdateState(_ state: BackgroundUpdateState) {
    let isConnecting: Bool
    switch state {
    case .connecting:
      isConnecting = true
    case .connected:
      isConnecting = false
    case .disconnected:
      isConnecting = true
    case .noConnection:
      isConnecting = false
    }
    didUpdateIsConnecting?(isConnecting)
  }
}
