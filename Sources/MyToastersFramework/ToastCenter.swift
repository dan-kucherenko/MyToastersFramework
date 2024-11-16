import UIKit

/// A singleton class responsible for managing and displaying toast messages.
///
/// `ToastCenter` handles the queuing, displaying, and cancellation of toast notifications. By default, it ensures
/// that toasts are shown one at a time in the order they are added. Developers can customize its behavior,
/// such as enabling or disabling queuing or supporting accessibility features.
///
/// - Note: This class uses `OperationQueue` to manage toast operations and supports VoiceOver announcements.
///
/// - SeeAlso: `Toast`, `ToastView`
@MainActor
open class ToastCenter: NSObject {
    // MARK: Properties

    /// The queue that manages toast operations.
    ///
    /// - Note: The queue ensures that only one toast is shown at a time by setting `maxConcurrentOperationCount` to 1.
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    /// The currently displayed toast, if any.
    ///
    /// This property returns the first toast operation in the queue that is not cancelled or finished.
    open var currentToast: Toast? {
        return self.queue.operations.first { !$0.isCancelled && !$0.isFinished } as? Toast
    }

    /// If this value is `true` and the user is using VoiceOver,
    /// VoiceOver will announce the text in the toast when `ToastView` is displayed.
    public var isSupportAccessibility: Bool = true

    /// By default, queueing for toast is enabled.
    /// If this value is `false`, only the last requested toast will be shown.
    public var isQueueEnabled: Bool = true

    /// The shared singleton instance of `ToastCenter`.
    ///
    /// Use this instance to interact with the toast system
    public static let `default` = ToastCenter()

    // MARK: Initializing
    override init() {
        super.init()
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deviceOrientationDidChange),
            name: name,
            object: nil
        )
    }

    // MARK: Adding Toasts

    /// Adds a toast to the queue for display.
    ///
    /// - Parameter toast: The `Toast` instance to add to the queue.
    ///
    /// - Behavior:
    ///   - If `isQueueEnabled` is `false`, this method cancels all currently queued toasts before adding the new one.
    ///   - If `isQueueEnabled` is `true`, the toast will be added to the queue and shown in order.
    ///
    /// - Note: Toasts are added to an internal `OperationQueue` and displayed in sequence.
    open func add(_ toast: Toast) {
        if !isQueueEnabled {
            cancelAll()
        }
        self.queue.addOperation(toast)
    }

    // MARK: Cancelling Toasts
    /// Cancels all currently queued toasts.
    ///
    /// - Behavior:
    ///   - Stops all toast operations in the queue.
    ///   - Any toast currently being displayed will also be cancelled.
    open func cancelAll() {
        queue.cancelAllOperations()
    }

    // MARK: Notifications

    /// Handles device orientation changes.
    ///
    /// This method is called when the device orientation changes. It ensures that the layout of the toast view
    /// is updated to reflect the new orientation.
    ///
    /// - Note: Only the first toast in the queue (the currently displayed toast) will be affected.
    @objc
    func deviceOrientationDidChange() {
        if let lastToast = self.queue.operations.first as? Toast {
            lastToast.view.setNeedsLayout()
        }
    }
}
