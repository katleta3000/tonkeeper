import UIKit

public extension UIView {

    static func spring(
        duration: TimeInterval = 1.0,
        damping: CGFloat = 0.5,
        velocity: CGFloat = 0.5,
        alphaDuration: TimeInterval = 0.4,
        _ animate: @escaping () -> Void,
        alphaAnimation: (() -> Void)? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.allowUserInteraction],
            animations: animate
        )

        UIView.animate(
            withDuration: alphaDuration,
            delay: 0,
            options: [.overrideInheritedDuration, .curveEaseOut],
            animations: alphaAnimation ?? {}, completion: completion
        )
    }

  func bounce(scale: CGFloat = 1.15) {
    UIView.transition(
        with: self,
        duration: 0.2, options: [.transitionCrossDissolve, .overrideInheritedDuration]) {
          self.transform = CGAffineTransformMakeScale(scale, scale)
        } completion: { _ in
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.2, options: [.overrideInheritedDuration], animations: {
                    self.transform = CGAffineTransform.identity
            })
        }
    }

    func shrink(down: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState]) {
            if down {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            } else {
                self.transform = .identity
            }
        }
    }
}
