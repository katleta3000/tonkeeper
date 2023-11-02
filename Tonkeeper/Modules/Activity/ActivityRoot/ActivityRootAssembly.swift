//
//  ActivityRootAssembly.swift
//  Tonkeeper
//
//  Created by Grigory on 20.7.23..
//

import Foundation
import WalletCore

struct ActivityRootAssembly {
  static func module(output: ActivityRootModuleOutput?,
                     activityController: ActivityController,
                     activityListController: ActivityListController) -> Module<ActivityRootViewController, ActivityRootModuleInput> {
    
    let presenter = ActivityRootPresenter(activityController: activityController)
    
    let emptyModule = ActivityEmptyAssembly.module(output: presenter)
    let listModule = ActivityListAssembly.module(
      activityListController: activityListController,
      transactionBuilder: ActivityListTransactionBuilder(
        accountEventActionContentProvider: ActivityListAccountEventActionContentProvider()
      ),
      output: presenter
    )
    
    let viewController = ActivityRootViewController(presenter: presenter,
                                                    emptyViewController: emptyModule.view,
                                                    listViewController: listModule.view)
    
    presenter.viewInput = viewController
    presenter.output = output
    presenter.emptyInput = emptyModule.input
    presenter.listInput = listModule.input
    
    return Module(view: viewController, input: presenter)
  }
}
