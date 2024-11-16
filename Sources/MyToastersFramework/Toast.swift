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

    /// The text displayed by the toast.
    @MainActor
    public var text: String? {
        get { return self.view.text }
        set { self.view.text = newValue }
    }

    /// The attributed text displayed by the toast.
    @MainActor
    public var attributedText: NSAttributedString? {
        get { return self.view.attributedText }
        set { self.view.attributedText = newValue }
    }

    @MainActor
    public var image: UIImage? {
        get { return self.view.image }
        set { self.view.image = newValue }
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

    /// The view representing the toast.
    @MainActor
    public lazy var view: ToastView = ToastView()

    // MARK: Initializing

    /// Initializer.
    /// Initializes a `Toast` instance with text.
    ///
    /// - Parameters:
    ///   - text: The text to be displayed in the toast.
    ///   - delay: The delay before showing the toast. Defaults to `0`.
    ///   - duration: The duration the toast remains visible. Defaults to `Delay.short`.
    ///   - appearanceAnimation: The animation style for showing the toast. Defaults to `.fadeIn`.
    ///   - disappearanceAnimation: The animation style for hiding the toast. Defaults to `.fadeOut`.
    ///   - animationDuration: The duration of the animations. Defaults to `0.3`.
    @MainActor
    public init(
        text: String?,
        image: UIImage? = nil,
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

        self.text = text
        self.image = image
    }

    /// Initializes a `Toast` instance with attributed text.
    ///
    /// - Parameters:
    ///   - attributedText: The attributed text to be displayed in the toast.
    ///   - delay: The delay before showing the toast. Defaults to `0`.
    ///   - duration: The duration the toast remains visible. Defaults to `Delay.short`.
    ///   - appearanceAnimation: The animation style for showing the toast. Defaults to `.fadeIn`.
    ///   - disappearanceAnimation: The animation style for hiding the toast. Defaults to `.fadeOut`.
    ///   - animationDuration: The duration of the animations. Defaults to `0.3`.
    @MainActor
    public init(
        attributedText: NSAttributedString?,
        image: UIImage? = nil,
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

        self.attributedText = attributedText
        self.image = image
    }

    // MARK: Showing

    /// Shows the toast by adding it to the `ToastCenter` queue.
    ///
    /// This method should be called on the main thread.
    @MainActor
    public func show() {
        ToastCenter.default.add(self)
    }

    // MARK: Cancelling

    /// Cancels the toast operation and removes the toast view from its parent.
    ///
    /// This method ensures the toast finishes its lifecycle cleanly by removing its view and marking the operation
    /// as finished.
    open override func cancel() {
        super.cancel()

        Task { @MainActor in
            self.finish()
            self.view.removeFromSuperview()
        }
    }

    // MARK: Operation Subclassing

    /// Starts the operation by preparing and displaying the toast.
    ///
    /// Ensures the toast is executed on the main thread. If the operation is already running, canceled, or finished,
    /// it won't be started again.
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

    /// The main execution logic of the operation.
    ///
    /// - Adds the toast view to the `ToastWindow`.
    /// - Executes the appearance animation.
    /// - Waits for the toast's visibility duration.
    /// - Executes the disappearance animation and removes the view from its parent.
    override open func main() {
        guard !isCancelled else { finish(); return }

        DispatchQueue.main.async {
            ToastWindow.shared.addSubview(self.view)

            self.appearanceAnimation.apply(to: self.view, duration: self.animationDuration) { [weak self] in
                guard let self = self else { return }
                guard !self.isCancelled else {
                    // If canceled, remove the view and finish
                    self.view.removeFromSuperview()
                    self.finish()
                    return
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) { [weak self] in
                    guard let self = self else { return }
                    guard !self.isCancelled else {
                        self.view.removeFromSuperview()
                        self.finish()
                        return
                    }

                    self.disappearanceAnimation.apply(to: self.view, duration: self.animationDuration) {
                        self.view.removeFromSuperview()
                        self.finish()
                    }
                }
            }
        }
    }

    /// Marks the toast operation as finished.
    ///
    /// Updates the `isExecuting` and `isFinished` states to properly conclude the operation.
    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
