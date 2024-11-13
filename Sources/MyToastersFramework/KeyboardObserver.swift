//
//  KeyboardObserver.swift
//  Toaster
//
//  Created by SeongHo Hong on 28/08/2019.
//  Copyright © 2019 Suyeol Jeon. All rights reserved.
//

import UIKit

@MainActor
final class KeyboardObserver {
    
    static let shared = KeyboardObserver()
    
    private(set) var didKeyboardShow: Bool = false
    
    init() {
        let keyboardWillShowName = UIWindow.keyboardWillShowNotification
        let keyboardDidHideName = UIWindow.keyboardDidHideNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: keyboardWillShowName,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: keyboardDidHideName,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow() {
        didKeyboardShow = true
    }
    
    @objc private func keyboardDidHide() {
        didKeyboardShow = false
    }
}

