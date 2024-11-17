import Testing
import UIKit
@testable import MyToastersFramework

@MainActor
struct ToastWindowTests {
    @Test
    func testSharedInstance() {
        let window1 = ToastWindow.shared
        let window2 = ToastWindow.shared
        #expect(window1 === window2)
    }

    @Test("Test Initialization Properties")
    func testInitialization() {
        let mainWindow = UIWindow(frame: UIScreen.main.bounds)
        let toastWindow = ToastWindow(frame: UIScreen.main.bounds, mainWindow: mainWindow)

        #expect(toastWindow.isUserInteractionEnabled == false)
        #expect(toastWindow.gestureRecognizers == [])
        #expect(toastWindow.backgroundColor == .clear)
        #expect(toastWindow.isHidden == false)
    }

    @Test("Subviews")
    func testAddSubview() {
        let toastWindow = ToastWindow.shared
        let subview = UIView()

        toastWindow.addSubview(subview)

        #expect(toastWindow.subviews.contains(subview))
    }

    @Test("Device orientation")
    func testDeviceOrientationDidChange() {
        let toastWindow = ToastWindow.shared
        NotificationCenter.default.post(name: UIDevice.orientationDidChangeNotification, object: nil)
        #expect(toastWindow.frame.size == UIScreen.main.bounds.size)
    }

    @Test("View become key")
    func testBecomeKey() {
        let mainWindow = UIWindow()
        let toastWindow = ToastWindow(frame: UIScreen.main.bounds, mainWindow: mainWindow)

        toastWindow.becomeKey()

        #expect(mainWindow.isKeyWindow == true)
    }
}
