import UIKit

public class Delay: NSObject {
    private override init() {}
    public static let short: TimeInterval = 2.0
    public static let long: TimeInterval = 3.5
}

open class Toast: Operation, @unchecked Sendable {

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
    public init(text: String?, delay: TimeInterval = 0, duration: TimeInterval = Delay.short) {
        self.delay = delay
        self.duration = duration
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
        self.isExecuting = true

        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.alpha = 0
            ToastWindow.shared.addSubview(self.view)

            UIView.animate(
                withDuration: 0.5,
                delay: self.delay,
                options: .beginFromCurrentState,
                animations: {
                    self.view.alpha = 1
                },
                completion: { _ in
                    if ToastCenter.default.isSupportAccessibility {
                        UIAccessibility.post(notification: .announcement, argument: self.view.text)
                        UIView.animate(
                            withDuration: self.duration,
                            animations: {
                                self.view.alpha = 1.0001
                            },
                            completion: { _ in
                                self.finish()
                                UIView.animate(
                                    withDuration: 0.5,
                                    animations: {
                                        self.view.alpha = 0
                                    },
                                    completion: { _ in
                                        self.view.removeFromSuperview()
                                    }
                                )
                            }
                        )
                    }}
            )
        }
    }

    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
