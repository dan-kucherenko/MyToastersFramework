import Testing
import Foundation
@testable import MyToastersFramework

@MainActor
struct ToastTests {
    @Test("Initial state")
    func testToastInitialization() throws {
        let toast = Toast(text: "Hello, world!")
        #expect(toast.text == "Hello, world!")
        #expect(toast.image == nil)
        #expect(toast.delay == 0)
        #expect(toast.duration == Delay.short)
        #expect(toast.appearanceAnimation == .fadeIn)
        #expect(toast.disappearanceAnimation == .fadeOut)
        #expect(toast.animationDuration == 0.3)
    }

    @Test("Init with attributed text")
    func testToastInitializationAttributedText() throws {
        let toast = Toast(attributedText: NSAttributedString(string: "Hello, world!"))
        #expect(toast.text == "Hello, world!")
        #expect(toast.image == nil)
        #expect(toast.delay == 0)
        #expect(toast.duration == Delay.short)
        #expect(toast.appearanceAnimation == .fadeIn)
        #expect(toast.disappearanceAnimation == .fadeOut)
        #expect(toast.animationDuration == 0.3)
    }

    @Test("Init with custom parameters")
    func testInitCustomParameters() throws {
        let toast = Toast(
            text: "Custom parameter string!",
            delay: 3,
            duration: 3,
            appearanceAnimation: .slideInFromTop,
            disappearanceAnimation: .slideOutToLeft,
            animationDuration: 0.4
        )
        #expect(toast.text == "Custom parameter string!")
        #expect(toast.image == nil)
        #expect(toast.delay == 3)
        #expect(toast.duration == 3)
        #expect(toast.appearanceAnimation == .slideInFromTop)
        #expect(toast.disappearanceAnimation == .slideOutToLeft)
        #expect(toast.animationDuration == 0.4)
    }

    @Test("Executing state")
    func testExecutingState() {
        let toast = Toast(text: "Test Toast")

        toast.isExecuting = true
        #expect(toast.isExecuting, "Toast should be executing when isExecuting is set to true")

        toast.isExecuting = false
        #expect(!toast.isExecuting, "Toast should not be executing when isExecuting is set to false")
    }

    @Test("Finished state")
    func testFinishedState() {
        let toast = Toast(text: "Test Toast")

        toast.isFinished = true
        #expect(toast.isFinished, "Toast should be finished when isFinished is set to true")

        toast.isFinished = false
        #expect(!toast.isFinished, "Toast should not be finished when isFinished is set to false")
    }
}
