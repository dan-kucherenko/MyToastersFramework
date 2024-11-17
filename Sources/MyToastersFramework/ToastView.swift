import UIKit
import SnapKit

/// A customizable view for displaying toast messages.
///
/// `ToastView` provides a lightweight and flexible way to display toast-style notifications.
/// The view includes customizable text, appearance, and layout properties, and is designed
/// to adapt to various screen sizes and orientations.
open class ToastView: UIView {

    // MARK: Properties

    weak var delegate: ToastViewDelegate?

    open var text: String? {
        get { return self.textLabel.text }
        set { self.textLabel.text = newValue }
    }

    open var attributedText: NSAttributedString? {
        get { return self.textLabel.attributedText }
        set { self.textLabel.attributedText = newValue }
    }

    open var image: UIImage? {
        get { return self.imageView.image }
        set {
            self.imageView.image = newValue
            self.imageView.isHidden = (newValue == nil)
            self.setNeedsLayout()
        }
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

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        return button
    }()

    private let timerBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 2
        return view
    }()

    /// Completion handler for the button's action.
    private var buttonAction: (() -> Void)?

    // MARK: Initializing
    public init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        self.addSubview(self.backgroundView)
        self.addSubview(self.imageView)
        self.addSubview(self.textLabel)
        self.addSubview(self.actionButton)
        self.addSubview(timerBar)

        self.actionButton.isUserInteractionEnabled = true
        self.actionButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
    }

    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
    }

    /// Configures the action button with a title and completion handler.
    /// - Parameters:
    ///   - title: The title of the button.
    ///   - action: The action to execute when the button is tapped.
    public func configureButton(title: String, action: @escaping () -> Void) {
        self.actionButton.setTitle(title, for: .normal)
        self.actionButton.isHidden = false
        self.buttonAction = action
        self.setNeedsLayout()
    }

    public func startTimerAnimation(duration: TimeInterval) {
        guard !actionButton.isHidden else { return }

        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
            self.timerBar.transform = CGAffineTransform(scaleX: 0.01, y: 1)
        } completion: { _ in
            self.timerBar.transform = .identity
        }
    }

    // MARK: Layout

    /// Updates the layout of the toast view and its subviews.
    ///
    /// This method calculates the size and position of the `textLabel` and `backgroundView`
    /// based on the screen's orientation, size, and safe area insets.
    override open func layoutSubviews() {
        super.layoutSubviews()

        let padding: CGFloat = 10
        let maxWidthRatio: CGFloat = 0.8

        let imageViewSize = imageView.image != nil ? CGSize(width: 40, height: 40) : .zero
        let textLabelSize = textLabel.sizeThatFits(
            CGSize(
                width: UIScreen.main.bounds.width * maxWidthRatio - imageViewSize.width - 3 * padding,
                height: CGFloat.greatestFiniteMagnitude
            )
        )

        let buttonSize = actionButton.isHidden ? .zero : actionButton.sizeThatFits(
            CGSize(
                width: CGFloat.greatestFiniteMagnitude,
                height: 30
            )
        )

        let toastWidth = min(
            UIScreen.main.bounds.width * maxWidthRatio,
            imageViewSize.width + textLabelSize.width + 3 * padding
        )
        let toastHeight = max(imageViewSize.height, textLabelSize.height) + 2 * padding

        applyConstraints(
            padding: padding,
            imageViewSize: imageViewSize,
            buttonSize: buttonSize,
            toastWidth: toastWidth,
            toastHeight: toastHeight
        )
    }

    /// Determines whether the toast view should handle touch events.
    ///
    /// Returns the view itself if it is user-interactable and the touch point is within its frame.
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return actionButton.isHidden ? nil : actionButton
        }
        return hitView
    }

    private func applyConstraints(
        padding: CGFloat,
        imageViewSize: CGSize,
        buttonSize: CGSize,
        toastWidth: CGFloat,
        toastHeight: CGFloat
    ) {
        backgroundView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.centerY.equalToSuperview()
            if imageViewSize != .zero {
                make.width.equalTo(imageViewSize.width)
                make.height.equalTo(imageViewSize.height)
            } else {
                make.width.height.equalTo(0)
            }
        }

        textLabel.snp.remakeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(imageViewSize != .zero ? padding : 0)
            make.trailing.lessThanOrEqualToSuperview().offset(-padding)
            make.centerY.equalToSuperview()
        }

        actionButton.snp.remakeConstraints { make in
            make.leading.equalTo(textLabel.snp.trailing).offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.centerY.equalToSuperview()
            if !actionButton.isHidden {
                make.width.equalTo(buttonSize.width)
                make.height.equalTo(buttonSize.height)
            } else {
                make.width.height.equalTo(0)
            }
        }

        timerBar.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(4)
            make.bottom.equalToSuperview().offset(-5)
        }

        if actionButton.isHidden {
            timerBar.isHidden = true
        } else {
            timerBar.isHidden = false
        }

        self.snp.remakeConstraints { make in
            make.width.equalTo(toastWidth)
            make.height.equalTo(toastHeight)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }
    }

    @objc
    private func buttonTapped() {
        self.buttonAction?()
        delegate?.toastViewDidRequestDismissal(self)
    }
}
