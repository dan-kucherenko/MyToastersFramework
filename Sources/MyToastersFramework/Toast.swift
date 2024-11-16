import UIKit

public class Delay: NSObject {
    private override init() {}
    public static let short: TimeInterval = 2.0
    public static let long: TimeInterval = 3.5
}

open class Toast: Operation, @unchecked Sendable {
    public var appearanceAnimation: AppearanceAnimationStyle = .fadeIn
    public var disappearanceAnimation: DisappearanceAnimationStyle = .fadeOut
    public var animationDuration: TimeInterval = 0.3

    // MARK: Properties
    @MainActor
    public var text: String? {
        get { return self.view.text }
        set { self.view.text = newValue }
    }

    @MainActor
    public var attributedText: NSAttributedString? {
        get { return self.view.attributedText }
        set { self.view.attributedText = newValue }
    }

    public var delay: TimeInterval
    public var duration: TimeInterval

    private var _executing = false
    override open var isExecuting: Bool {
        get {
            return self._executing
        }
        set {
            self.willChangeValue(forKey: "isExecuting")
            self._executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }

    private var _finished = false
    override open var isFinished: Bool {
        get {
            return self._finished
        }
        set {
            self.willChangeValue(forKey: "isFinished")
            self._finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }

    // MARK: UI
    @MainActor
    public lazy var view: ToastView = ToastView()

    // MARK: Initializing

    /// Initializer.
    /// Instantiates `self.view`, so must be called on main thread.
    public init(
        text: String?,
        delay: TimeInterval = 0,
        duration: TimeInterval = Delay.short,
        appearanceAnimation: AppearanceAnimationStyle = .fadeIn,
        disappearanceAnimation: DisappearanceAnimationStyle = .fadeOut,
        animationDuration: TimeInterval = 0.3
    ) {
        self.delay = delay
        self.duration = duration
        self.appearanceAnimation = appearanceAnimation
        self.disappearanceAnimation = disappearanceAnimation
        self.animationDuration = animationDuration
        super.init()

        Task { @MainActor in
            self.text = text
        }
    }

    @MainActor
    public init(attributedText: NSAttributedString?, delay: TimeInterval = 0, duration: TimeInterval = Delay.short) {
        self.delay = delay
        self.duration = duration
        super.init()

        self.attributedText = attributedText
    }

    // MARK: Showing
    @MainActor
    public func show() {
        ToastCenter.default.add(self)
    }

    // MARK: Cancelling
    open override func cancel() {
        super.cancel()

        Task { @MainActor in
            self.finish()
            self.view.removeFromSuperview()
        }
    }

    // MARK: Operation Subclassing
    override open func start() {
        let isRunnable = !self.isFinished && !self.isCancelled && !self.isExecuting
        guard isRunnable else { return }
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.start()
            }
            return
        }
        main()
    }

    override open func main() {
        guard !isCancelled else { finish(); return }

        DispatchQueue.main.async {
            // Add the toast view to the ToastWindow
            ToastWindow.shared.addSubview(self.view)

            // Apply appearance animation
            self.appearanceAnimation.apply(to: self.view, duration: self.animationDuration) { [weak self] in
                guard let self = self else { return }
                guard !self.isCancelled else {
                    // If canceled, remove the view and finish
                    self.view.removeFromSuperview()
                    self.finish()
                    return
                }

                // Keep the toast visible for the duration
                DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) { [weak self] in
                    guard let self = self else { return }
                    guard !self.isCancelled else {
                        // If canceled during duration, remove the view and finish
                        self.view.removeFromSuperview()
                        self.finish()
                        return
                    }

                    // Apply disappearance animation
                    self.disappearanceAnimation.apply(to: self.view, duration: self.animationDuration) {
                        // Remove the view and mark the operation as finished
                        self.view.removeFromSuperview()
                        self.finish()
                    }
                }
            }
        }
    }

    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
