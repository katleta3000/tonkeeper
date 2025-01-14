import UIKit
import KeeperCore
import TKCore
import TKCoordinator
import TKUIKit

public final class ImportWatchOnlyWalletCoordinator: RouterCoordinator<NavigationControllerRouter> {
  
  public var didCancel: (() -> Void)?
  public var didImportWallet: (() -> Void)?
  
  private let walletsUpdateAssembly: WalletsUpdateAssembly
  private let customizeWalletModule: (_ name: String?) -> MVVMModule<UIViewController, CustomizeWalletModuleOutput, Void>
  
  init(router: NavigationControllerRouter,
       walletsUpdateAssembly: WalletsUpdateAssembly,
       customizeWalletModule: @escaping (_ name: String?) -> MVVMModule<UIViewController, CustomizeWalletModuleOutput, Void>) {
    self.walletsUpdateAssembly = walletsUpdateAssembly
    self.customizeWalletModule = customizeWalletModule
    super.init(router: router)
  }

  public override func start() {
    openWatchOnlyWalletAddressInput()
  }
}

private extension ImportWatchOnlyWalletCoordinator {
  func openWatchOnlyWalletAddressInput() {
    let module = WatchOnlyWalletAddressInputAssembly.module(controller: walletsUpdateAssembly.watchOnlyWalletAddressInputController())
    
    module.output.didInputWallet = { [weak self] resolvableAddress in
      self?.openCustomizeWallet(resolvableAddress: resolvableAddress)
    }
    
    router.push(viewController: module.view)
  }
  
  func openCustomizeWallet(resolvableAddress: ResolvableAddress) {
    let name: String?
    switch resolvableAddress {
    case .Domain(let domain, _):
      name = domain
    case .Resolved(_):
      name = nil
    }
    let module = customizeWalletModule(name)
    
    module.output.didCustomizeWallet = { [weak self] model in
      self?.importWallet(
        resolvableAddress: resolvableAddress,
        model: model
      )
    }
    
    if router.rootViewController.viewControllers.isEmpty {
      module.view.setupLeftCloseButton { [weak self] in
        self?.didCancel?()
      }
    } else {
      module.view.setupBackButton()
    }
    
    router.push(viewController: module.view)
  }
  
  func importWallet(resolvableAddress: ResolvableAddress,
                    model: CustomizeWalletModel) {
    let addController = walletsUpdateAssembly.walletAddController()
    let metaData = WalletMetaData(
      label: model.name,
      tintColor: model.tintColor,
      emoji: model.emoji)
    do {
      try addController.importWatchOnlyWallet(
        resolvableAddress: resolvableAddress,
        metaData: metaData
      )
      didImportWallet?()
    } catch {
      print("Log: Watch only wallet import failed")
    }
  }
}
