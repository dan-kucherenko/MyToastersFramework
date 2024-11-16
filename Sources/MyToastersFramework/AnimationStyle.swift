//
//  AnimationStyle.swift
//  MyToastersFramework
//
//  Created by Daniil on 16.11.2024.
//

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
            UIView.animate(withDuration: duration, animations: {
                view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                view.alpha = 0
            }, completion: { _ in completion() })
        }
    }
}
