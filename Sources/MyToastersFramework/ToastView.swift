import UIKit

/// A customizable view for displaying toast messages.
///
/// `ToastView` provides a lightweight and flexible way to display toast-style notifications.
/// The view includes customizable text, appearance, and layout properties, and is designed
/// to adapt to various screen sizes and orientations.
open class ToastView: UIView {

    // MARK: Properties

    open var text: String? {
        get { return self.textLabel.text }
        set { self.textLabel.text = newValue }
    }

    open var attributedText: NSAttributedString? {
        get { return self.textLabel.attributedText }
        set { self.textLabel.attributedText = newValue }
    }

    // MARK: Appearance

    /// The background view's color.
    override open var backgroundColor: UIColor? {
        get { return self.backgroundView.backgroundColor }
        set { self.backgroundView.backgroundColor = newValue }
    }

    /// The background view's corner radius.
    open var cornerRadius: CGFloat {
        get { return self.backgroundView.layer.cornerRadius }
        set { self.backgroundView.layer.cornerRadius = newValue }
    }

    /// The inset of the text label.
    open var textInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

    /// The color of the text label's text.
    open var textColor: UIColor? {
        get { return self.textLabel.textColor }
        set { self.textLabel.textColor = newValue }
    }

    /// The font of the text label.
    open var font: UIFont? {
        get { return self.textLabel.font }
        set { self.textLabel.font = newValue }
    }

    /// The bottom offset from the screen's bottom in portrait mode.
    open var bottomOffsetPortrait: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
            // specific values
        case .phone: return 30
        case .pad: return 60
        case .tv: return 90
        case .carPlay: return 30
        case .mac: return 60
        case .vision: return 60
            // default values
        case .unspecified: fallthrough
        @unknown default: return 30
        }
    }()

    /// The bottom offset from the screen's bottom in landscape mode.
    open var bottomOffsetLandscape: CGFloat = {
        switch UIDevice.current.userInterfaceIdiom {
            // specific values
        case .phone: return 20
        case .pad: return 40
        case .tv: return 60
        case .carPlay: return 20
        case .mac: return 40
        case .vision: return 40
            // default values
        case .unspecified: fallthrough
        @unknown default: return 20
        }
    }()

    /// If this value is `true` and SafeArea is available,
    /// `safeAreaInsets.bottom` will be added to the `bottomOffsetPortrait` and `bottomOffsetLandscape`.
    /// Default value: false
    open var useSafeAreaForBottomOffset: Bool = false

    /// The width ratio of toast view in window, specified as a value from 0.0 to 1.0.
    /// Default value: 0.875
    open var maxWidthRatio: CGFloat = (280.0 / 320.0)

    /// The shape of the layer’s shadow.
    open var shadowPath: CGPath? {
        get { return self.layer.shadowPath }
        set { self.layer.shadowPath = newValue }
    }

    /// The color of the layer’s shadow.
    open var shadowColor: UIColor? {
        get { return self.layer.shadowColor.flatMap { UIColor(cgColor: $0) } }
        set { self.layer.shadowColor = newValue?.cgColor }
    }

    /// The opacity of the layer’s shadow.
    open var shadowOpacity: Float {
        get { return self.layer.shadowOpacity }
        set { self.layer.shadowOpacity = newValue }
    }

    /// The offset (in points) of the layer’s shadow.
    open var shadowOffset: CGSize {
        get { return self.layer.shadowOffset }
        set { self.layer.shadowOffset = newValue }
    }

    /// The blur radius (in points) used to render the layer’s shadow.
    open var shadowRadius: CGFloat {
        get { return self.layer.shadowRadius }
        set { self.layer.shadowRadius = newValue }
    }

    // MARK: UI
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = {
            switch UIDevice.current.userInterfaceIdiom {
            case .phone: return .systemFont(ofSize: 12)
            case .pad: return .systemFont(ofSize: 16)
            case .tv: return .systemFont(ofSize: 20)
            case .carPlay: return .systemFont(ofSize: 12)
            case .mac: return .systemFont(ofSize: 16)
            case .vision: return .systemFont(ofSize: 16)
            case .unspecified: fallthrough
            @unknown default: return .systemFont(ofSize: 12)
            }
        }()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: Initializing
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        self.addSubview(self.backgroundView)
        self.addSubview(self.textLabel)
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }

    // MARK: Layout

    /// Updates the layout of the toast view and its subviews.
    ///
    /// This method calculates the size and position of the `textLabel` and `backgroundView`
    /// based on the screen's orientation, size, and safe area insets.
    override open func layoutSubviews() {
        super.layoutSubviews()

        let containerSize = ToastWindow.shared.frame.size
        let constraintSize = CGSize(
            width: containerSize.width * maxWidthRatio - self.textInsets.left - self.textInsets.right,
            height: CGFloat.greatestFiniteMagnitude
        )
        let textLabelSize = self.textLabel.sizeThatFits(constraintSize)

        self.textLabel.frame = CGRect(
            x: self.textInsets.left,
            y: self.textInsets.top,
            width: textLabelSize.width,
            height: textLabelSize.height
        )

        self.backgroundView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right,
            height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
        )

        var xCoordinate: CGFloat
        var yCoordinate: CGFloat
        var width: CGFloat
        var height: CGFloat

        // Obtain interface orientation from UIWindowScene
        let interfaceOrientation = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.interfaceOrientation ?? .portrait

        if interfaceOrientation.isPortrait || !ToastWindow.shared.shouldRotateManually {
            width = containerSize.width
            height = containerSize.height
            yCoordinate = self.bottomOffsetPortrait
        } else {
            width = containerSize.height
            height = containerSize.width
            yCoordinate = self.bottomOffsetLandscape
        }

        if useSafeAreaForBottomOffset {
            yCoordinate += ToastWindow.shared.safeAreaInsets.bottom
        }

        let backgroundViewSize = self.backgroundView.frame.size
        xCoordinate = (width - backgroundViewSize.width) * 0.5
        yCoordinate = height - (backgroundViewSize.height + yCoordinate)

        self.frame = CGRect(
            x: xCoordinate,
            y: yCoordinate,
            width: backgroundViewSize.width,
            height: backgroundViewSize.height
        )
    }

    /// Determines whether the toast view should handle touch events.
    ///
    /// Returns the view itself if it is user-interactable and the touch point is within its frame.
    override open func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
        if let superview = self.superview {
            let pointInWindow = self.convert(point, to: superview)
            let contains = self.frame.contains(pointInWindow)
            if contains && self.isUserInteractionEnabled {
                return self
            }
        }
        return nil
    }
}
