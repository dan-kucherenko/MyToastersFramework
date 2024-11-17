# MyToastersFramework

A lightweight and customizable framework for creating interactive and visually appealing toast notifications in your application

## Features

- **Customizable Toasts:** Add warning icons, action buttons, and personalized messages.
- **Undo Actions:** Easily undo user actions, such as deletions, directly from the toast notification.
- **Smooth Animations:** Includes slide-in, fade-out, and other customizable animation options.
- **Timeout Management:** Set durations for toast visibility or let the user dismiss them manually.
- **Lightweight Integration:** Simple setup with minimal dependencies.

---

### Example: Deletion Toast with Undo

```swift
import SwiftUI
import MyToastersFramework

struct ContentView: View {
    @State private var items = ["Item 1", "Item 2", "Item 3"]
    @State private var recentlyDeletedItem: (index: Int, name: String)?

    var body: some View {
        NavigationView {
            List {
                ForEach(items.indices, id: \.self) { index in
                    Text(items[index])
                        .swipeActions {
                            Button(role: .destructive) {
                                deleteItem(at: index)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .navigationTitle("Manage Items")
        }
    }

    private func deleteItem(at index: Int) {
        let deletedItem = items.remove(at: index)
        recentlyDeletedItem = (index, deletedItem)

        let toast = Toast(
            text: "Item '\(deletedItem)' deleted. Undo?",
            image: UIImage(systemName: "exclamationmark.triangle.fill")!,
            buttonTitle: "Undo",
            buttonAction: {
                if let item = recentlyDeletedItem {
                    items.insert(item.name, at: item.index)
                    recentlyDeletedItem = nil
                }
            },
            duration: 5,
            appearanceAnimation: .slideInFromTop,
            disappearanceAnimation: .slideOutToRight,
            animationDuration: 0.4
        )
        toast.show()
    }
}
```

## Installation

### Swift Package Manager

To integrate `MyToastersFramework` into your Xcode project, use **Swift Package Manager**:

1. Open your project in Xcode.
2. Go to `File` > `Add Packages...`.
3. Paste the repository URL: `https://github.com/dan-kucherenko/MyToastersFramework.git`
4. Select the desired version and click "Add Package."

Alternatively, add the following line to your `Package.swift` file:

```swift
dependencies: [
 .package(url: "https://github.com/dan-kucherenko/MyToastersFramework.git", branch: "main")
]
```

### Cocoa Pods

Todo: add cocoapods instruction

---

## How to Use

### Create a Simple Toast

```swift
let toast = Toast(text: "This is a simple toast")
toast.show()
```

### Add an action button

```swift
let toast = Toast(
    text: "This toast has an action",
    buttonTitle: "Click Me",
    buttonAction: {
        print("Action button clicked!")
    }
)
toast.show()
```

### Customize animations

```swift
let toast = Toast(
    text: "Custom animation toast",
    appearanceAnimation: .slideInFromBottom,
    disappearanceAnimation: .slideOutToLeft,
    animationDuration: 0.5
)
toast.show()
```

---

## Configuration Options

- **Text**: Set the main text of the toast.
- **Image**: Add an icon or warning image.
- **Button Title & Action**: Include a clickable button with a custom callback.
- **Duration**: Specify how long the toast remains visible (default: 5 seconds).
- **Animations**: Choose from predefined or custom animations for toast appearance and disappearance.

---

## License

This project is licensed under the [MIT License](LICENSE).
