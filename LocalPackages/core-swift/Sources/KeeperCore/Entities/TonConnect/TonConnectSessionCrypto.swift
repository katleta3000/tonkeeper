import Foundation
import TweetNacl
import TonSwift

struct TonConnectSessionCrypto {
  public let sessionId: String
  public let keyPair: KeyPair
  
  init() throws {
    let keyPair = try TweetNacl.NaclBox.keyPair()
    self.keyPair = KeyPair(publicKey: .init(data: keyPair.publicKey),
                           privateKey: .init(data: keyPair.secretKey))
    self.sessionId = keyPair.publicKey.hexString()
  }
  
  init(privateKey: PrivateKey) throws {
    let keyPair = try TweetNacl.NaclBox.keyPair(fromSecretKey: privateKey.data)
    self.keyPair = KeyPair(publicKey: .init(data: keyPair.publicKey),
                           privateKey: .init(data: keyPair.secretKey))
    self.sessionId = keyPair.publicKey.hexString()
  }
  
  func encrypt(message: Data, receiverPublicKey: Data) throws -> Data {
    let nonce = try createNonce()
    let encrypted = try TweetNacl.NaclBox.box(
      message: message,
      nonce: nonce,
      publicKey: receiverPublicKey,
      secretKey: keyPair.privateKey.data)
    return nonce + encrypted
  }
  
  func decrypt(message: Data, senderPublicKey: Data) throws -> Data {
    guard message.count >= .nonceLength else {
      return Data()
    }
    let nonce = message[0..<Int.nonceLength]
    let internalMessage = message[Int.nonceLength..<message.count]
    let decrypted = try TweetNacl.NaclBox.open(
      message: internalMessage,
      nonce: nonce,
      publicKey: senderPublicKey,
      secretKey: keyPair.privateKey.data)
    return decrypted
  }
}

private extension TonConnectSessionCrypto {
  func createNonce() throws -> Data {
    return try TweetNacl.NaclUtil.secureRandomData(count: .nonceLength)
  }
}

private extension Int {
  static let nonceLength = 24
}
