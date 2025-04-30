# Task-Cancellation-Demo
Task Cancellation Demo in Swift A SwiftUI project demonstrating different approaches to task cancellation in Swift's concurrency model. Compares TaskGroup, regular Tasks, detached Tasks, and cancellation handlers. Perfect for understanding structured concurrency and proper task cleanup.

# Task Cancellation Demo in Swift

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20watchOS-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

A demonstration of different task cancellation approaches in Swift's concurrency model.

![Demo Screenshot](demo.gif)

## Features

- 🚀 Four distinct cancellation implementations:
  - `TaskGroup` with automatic child cancellation
  - Regular `Task` with manual management
  - `withTaskCancellationHandler` for explicit cleanup
  - `Detached Task` showing independent behavior
- 📝 Real-time logging of task lifecycle events
- 🎮 Interactive UI to test different scenarios
- 📚 Educational code comments explaining each pattern

## Key Concepts

✔️ Structured vs unstructured concurrency  
✔️ Parent-child task relationships  
✔️ Cancellation propagation  
✔️ Proper resource cleanup  
✔️ Attached vs detached tasks  

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/task-cancellation-demo.git
   ```
2. Open in **Xcode 15+**  
3. Build and run on your preferred platform

## Usage

- Launch the application  
- Try each task type:
  - Tap buttons to start different scenarios  
  - Observe the console output  
  - Use the cancel button to test cancellation  
- Compare behaviors between implementations

## Code Examples

### TaskGroup (Automatic Cancellation)

```swift
await withThrowingTaskGroup(of: Void.self) { group in
    group.addTask {
        try await work()
    }
    // Children automatically cancel when group exits
}
```

### With Cancellation Handler

```swift
await withTaskCancellationHandler {
    try await longRunningWork()
} onCancel: {
    cleanupResources()
}
```

### Detached Task

```swift
Task.detached {
    // Runs independently of parent context
    await nonCancellableWork()
}
```

## Requirements

- Xcode 15.0+  
- Swift 5.9+  
- iOS 17+ / macOS 14+ (or newer)

## Project Structure

```
.
├── Sources
│   ├── ContentView.swift        # Main UI
│   └── TaskViewModel.swift      # Business logic
├── README.md
└── TaskCancellationDemo.xcodeproj
```

## Contributing

Contributions are welcome! Please:

1. Fork the project  
2. Create a feature branch  
3. Submit a pull request

## License

MIT License. See [LICENSE](LICENSE) for details.



