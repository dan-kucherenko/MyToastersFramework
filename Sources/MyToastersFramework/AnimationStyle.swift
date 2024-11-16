import UIKit

public enum AppearanceAnimationStyle {
    case fadeIn
    case slideInFromTop
    case slideInFromBottom
    case slideInFromLeft
    case slideInFromRight
    case bounce
}

public enum DisappearanceAnimationStyle {
    case fadeOut
    case slideOutToTop
    case slideOutToBottom
    case slideOutToLeft
    case slideOutToRight
    case shrink
}

@MainActor
public extension AppearanceAnimationStyle {
    /// Applies the specified appearance animation style to a given view.
    ///
    /// This method animates the appearance of a `UIView` according to the selected `AppearanceAnimationStyle`,
    /// such as fading in, sliding in from various directions, or bouncing. The animation's duration and
    /// completion behavior can be customized.
    ///
    /// - Parameters:
    ///   - view: The `UIView` to which the appearance animation will be applied.
    ///           The view's initial state is set based on the animation style (e.g., hidden, offscreen).
    ///   - duration: The duration of the animation, in seconds.
    ///   - completion: A closure that gets called after the animation finishes.
    ///
    /// - Animation Styles:
    ///   - `fadeIn`: Gradually increases the view's alpha from 0 to 1.
    ///   - `slideInFromTop`: Moves the view from above the screen into its original position.
    ///   - `slideInFromBottom`: Moves the view from below the screen into its original position.
    ///   - `slideInFromLeft`: Moves the view from the left of the screen into its original position.
    ///   - `slideInFromRight`: Moves the view from the right of the screen into its original position.
    ///   - `bounce`: Scales the view down and animates it back to its original size with a bounce effect.
    ///
    /// - Example:
    /// ```swift
    /// AppearanceAnimationStyle.slideInFromBottom.apply(to: someView, duration: 0.5) {
    ///     print("Slide in from bottom animation complete!")
    /// }
    /// ```
    func apply(to view: UIView, duration: TimeInterval, completion: @escaping () -> Void) {
        view.alpha = 0
        switch self {
        case .fadeIn:
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 1
            }, completion: { _ in completion() })

        case .slideInFromTop:
            let originalFrame = view.frame
            view.frame.origin.y = -UIScreen.main.bounds.height / 4
            UIView.animate(withDuration: duration, animations: {
                view.frame = originalFrame
                view.alpha = 1
            }, completion: { _ in completion() })

        case .slideInFromBottom:
            let originalFrame = view.frame
            view.frame.origin.y = UIScreen.main.bounds.height
            UIView.animate(withDuration: duration, animations: {
                view.frame = originalFrame
                view.alpha = 1
            }, completion: { _ in completion() })

        case .slideInFromLeft:
            let originalFrame = view.frame
            view.frame.origin.x = -UIScreen.main.bounds.width
            UIView.animate(withDuration: duration, animations: {
                view.frame = originalFrame
                view.alpha = 1
            }, completion: { _ in completion() })

        case .slideInFromRight:
            let originalFrame = view.frame
            view.frame.origin.x = UIScreen.main.bounds.width
            UIView.animate(withDuration: duration, animations: {
                view.frame = originalFrame
                view.alpha = 1
            }, completion: { _ in completion() })

        case .bounce:
            view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                view.transform = .identity
                view.alpha = 1
            }, completion: { _ in completion() })
        }
    }
}

@MainActor
public extension DisappearanceAnimationStyle {
    /// Applies the specified disappearance animation style to a given view.
    ///
    /// This method animates the disappearance of a `UIView` according to the selected `DisappearanceAnimationStyle`,
    /// such as fading out, sliding out in various directions, or shrinking. The animation's duration and
    /// completion behavior can be customized.
    ///
    /// - Parameters:
    ///   - view: The `UIView` to which the disappearance animation will be applied.
    ///   - duration: The duration of the animation, in seconds.
    ///   - completion: A closure that gets called after the animation finishes.
    ///
    /// - Animation Styles:
    ///   - `fadeOut`: Gradually reduces the view's alpha to 0.
    ///   - `slideOutToTop`: Slides the view upward, out of the screen bounds, and fades it out.
    ///   - `slideOutToBottom`: Slides the view downward, out of the screen bounds, and fades it out.
    ///   - `slideOutToLeft`: Slides the view leftward, out of the screen bounds, and fades it out.
    ///   - `slideOutToRight`: Slides the view rightward, out of the screen bounds, and fades it out.
    ///   - `shrink`: Scales the view down to a small size and fades it out.
    ///
    /// - Example:
    /// ```swift
    /// DisappearanceAnimationStyle.fadeOut.apply(to: someView, duration: 0.5) {
    ///     print("Animation complete!")
    /// }
    /// ```
    func apply(to view: UIView, duration: TimeInterval, completion: @escaping () -> Void) {
        switch self {
        case .fadeOut:
            UIView.animate(withDuration: duration, animations: {
                view.alpha = 0
            }, completion: { _ in completion() })

        case .slideOutToTop:
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin.y = -UIScreen.main.bounds.height / 4
                view.alpha = 0
            }, completion: { _ in completion() })

        case .slideOutToBottom:
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin.y = UIScreen.main.bounds.height
                view.alpha = 0
            }, completion: { _ in completion() })

        case .slideOutToLeft:
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin.x = -UIScreen.main.bounds.width
                view.alpha = 0
            }, completion: { _ in completion() })

        case .slideOutToRight:
            UIView.animate(withDuration: duration, animations: {
                view.frame.origin.x = UIScreen.main.bounds.width
                view.alpha = 0
            }, completion: { _ in completion() })

        case .shrink:
            let originalBounds = view.bounds
            UIView.animate(withDuration: duration, animations: {
                view.bounds = CGRect(
                    x: originalBounds.origin.x,
                    y: originalBounds.origin.y,
                    width: originalBounds.width * 0.1,
                    height: originalBounds.height * 0.1
                )
                view.alpha = 0
            }, completion: { _ in completion() })
        }
    }
}
