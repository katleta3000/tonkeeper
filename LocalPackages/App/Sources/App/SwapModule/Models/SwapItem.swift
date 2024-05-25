import KeeperCore
import BigInt

struct SwapPair {
  struct Item {
    let token: Token
    let amount: BigUInt
  }
  let send: SwapPair.Item
  let receive: SwapPair.Item?
}

enum SwapField {
  case send
  case receive

  mutating func inverse() {
    switch self {
    case .send:
      self = .receive
    case .receive:
      self = .send
    }
  }
}
