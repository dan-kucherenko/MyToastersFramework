import UIKit

/// A custom window for displaying toast notifications.
///
/// `ToastWindow` acts as a dedicated window to manage and display toast messages at the highest window level.
/// It integrates seamlessly with the application and handles layout updates, keyboard events, and rotation.
///
/// - Note: Use `ToastWindow.shared` to access the singleton instance.
open class ToastWindow: UIWindow {

    // MARK: - Public Property
    public static let shared: ToastWindow = {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })

        let frame = windowScene?.screen.bounds ?? UIScreen.main.bounds
        let mainWindow = windowScene?.windows.first { $0.isKeyWindow }

        return ToastWindow(frame: frame, mainWindow: mainWindow)
    }()

    /// The root view controller of the `ToastWindow`.
    ///
    /// - If `isShowing` is `true`, this will return `nil`.
    /// - If `isStatusBarOrientationChanging` is `true`, this will also return `nil`.
    /// - Otherwise, it will return the root view controller of the main application window.
    override open var rootViewController: UIViewController? {
        get {
            guard !self.isShowing else {
                isShowing = false
                return nil
            }
            guard !self.isStatusBarOrientationChanging else { return nil }
            guard let firstWindow = UIApplication.shared.delegate?.window else { return nil }
            return firstWindow is ToastWindow ? nil : firstWindow?.rootViewController
        }
        set { /* Do nothing */ }
    }

    override open var isHidden: Bool {
        willSet {
            isShowing = true
        }
        didSet {
            isShowing = false
        }
    }

    /// Don't rotate manually if the application:
    ///
    /// - is running on iPad
    /// - is running on iOS 9
    /// - supports all orientations
    /// - doesn't require full screen
    /// - has launch storyboard
    ///
    var shouldRotateManually: Bool {
        let iPad = UIDevice.current.userInterfaceIdiom == .pad
        let application = UIApplication.shared
        let window = application.delegate?.window ?? nil
        let supportsAllOrientations = application.supportedInterfaceOrientations(for: window) == .all

        let info = Bundle.main.infoDictionary
        let requiresFullScreen = (info?["UIRequiresFullScreen"] as? NSNumber)?.boolValue == true
        let hasLaunchStoryboard = info?["UILaunchStoryboardName"] != nil

        if iPad && supportsAllOrientations && !requiresFullScreen && hasLaunchStoryboard {
            return false
        }
        return true
    }

    // MARK: - Private Property

    /// Will not return `rootViewController` while this value is `true`. Or the rotation will be fucked in iOS 9.
    private var isStatusBarOrientationChanging = false

    /// Will not return `rootViewController` while this value is `true`. Needed for iOS 13.
    private var isShowing = false

    /// Returns original subviews. `ToastWindow` overrides `addSubview()` to add a subview to the
    /// top window instead itself.
    private var originalSubviews = NSPointerArray.weakObjects()

    private weak var mainWindow: UIWindow?

    // MARK: - Initializing
    public init(frame: CGRect, mainWindow: UIWindow?) {
        super.init(frame: frame)
        self.mainWindow = mainWindow
        self.isUserInteractionEnabled = false
        self.gestureRecognizers = nil
        self.windowLevel = .init(rawValue: .greatestFiniteMagnitude)
        self.backgroundColor = .clear
        self.isHidden = false

        self.handleRotate()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIWindow.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidHide),
            name: UIWindow.keyboardDidHideNotification,
            object: nil
        )
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented: please use ToastWindow.shared")
    }

    @objc private func deviceOrientationDidChange() {
        self.handleRotate() // Update your view orientation
    }

    // MARK: - Public method
    
    /// Adds a subview to the `ToastWindow`.
    ///
    /// The subview is also added to the top-most window in the application.
    ///
    /// - Parameter view: The subview to be added.
    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        self.originalSubviews.addPointer(Unmanaged.passUnretained(view).toOpaque())
        self.topWindow()?.addSubview(view)
    }

    /// Ensures the main application window becomes the key window after `ToastWindow`.
    open override func becomeKey() {
        super.becomeKey()
        mainWindow?.makeKey()
    }

}

// MARK: - Private methods
private extension ToastWindow {
    @objc
    func statusBarOrientationWillChange() {
        self.isStatusBarOrientationChanging = true
    }

    @objc
    func statusBarOrientationDidChange() {
        if UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.interfaceOrientation != nil {
            self.handleRotate()
        }
        self.isStatusBarOrientationChanging = false
    }

    @objc
    func applicationDidBecomeActive() {
        if UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.interfaceOrientation != nil {
            self.handleRotate()
        }
    }

    @objc
    func keyboardWillShow() {
        guard let topWindow = self.topWindow(),
              let subviews = self.originalSubviews.allObjects as? [UIView] else { return }
        for subview in subviews {
            topWindow.addSubview(subview)
        }
    }

    @objc
    func keyboardDidHide() {
        guard let subviews = self.originalSubviews.allObjects as? [UIView] else { return }
        for subview in subviews {
            super.addSubview(subview)
        }
    }

    func handleRotate() {
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let window = windowScene.windows.first {

            let orientation = windowScene.interfaceOrientation

            if orientation.isPortrait || !self.shouldRotateManually {
                self.frame.size.width = window.bounds.size.width
                self.frame.size.height = window.bounds.size.height
            } else {
                self.frame.size.width = window.bounds.size.height
                self.frame.size.height = window.bounds.size.width
            }
        }
    }

    func angleForOrientation(_ orientation: UIInterfaceOrientation) -> Double {
        switch orientation {
        case .landscapeLeft: return -.pi / 2
        case .landscapeRight: return .pi / 2
        case .portraitUpsideDown: return .pi
        default: return 0
        }
    }

    /// Returns top window that isn't self
    func topWindow() -> UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first(
            where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene,
           let window = windowScene.windows.last(where: {
               // Use `window` here
               // https://github.com/devxoul/Toaster/issues/152
               KeyboardObserver.shared.didKeyboardShow || $0.isOpaque
           }), window !== self {
            return window
        }
        return nil
    }
}
