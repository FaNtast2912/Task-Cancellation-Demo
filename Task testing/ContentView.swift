//
//  ContentView.swift
//  Task testing
//
//  Created by Maksim Zakharov on 16.04.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Task Cancellation Demo").font(.largeTitle).bold()
            
            Button("🚀 Start with TaskGroup") {
                viewModel.startWithTaskGroup()
            }
            .buttonStyle(.borderedProminent)
            
            Button("🧵 Start with Regular Task") {
                viewModel.startWithTask()
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            Button("🔄 Start with TaskCancellationHandler") {
                viewModel.startWithCancellationHandler()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            
            Button("🛰️ Start with Detached Task") {
                viewModel.startWithDetachedTask()
            }
            .buttonStyle(.bordered)
            
            Button("🛑 Cancel Task") {
                viewModel.cancel()
            }
            .buttonStyle(.bordered)
            .tint(.red)
            
            ScrollView {
                Text(viewModel.log)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }
}

class TaskViewModel: ObservableObject {
    @Published var log: String = ""
    private var parentTask: Task<Void, Error>?
    
    // Method with withTaskCancellationHandler
    func startWithCancellationHandler() {
        clearLog()
        parentTask = Task {
            logMessage("🎯 Parent Task with CancellationHandler started")
            
            // Create child tasks
            let task1 = Task {
                do {
                    self.logMessage("🧵 Child Task 1 started")
                    while true {
                        try Task.checkCancellation()
                        try await Task.sleep(nanoseconds: 500_000_000)
                        self.logMessage("⏳ Child Task 1 working...")
                    }
                } catch {
                    self.logMessage("❌ Child Task 1 canceled")
                }
            }
            
            let task2 = Task {
                do {
                    self.logMessage("🧵 Child Task 2 started")
                    while true {
                        try Task.checkCancellation()
                        try await Task.sleep(nanoseconds: 700_000_000)
                        self.logMessage("⏳ Child Task 2 working...")
                    }
                } catch {
                    self.logMessage("❌ Child Task 2 canceled")
                }
            }
            
            // Use withTaskCancellationHandler for explicit child task cancellation
            await withTaskCancellationHandler {
                // This block will execute before cancellation
                logMessage("📋 CancellationHandler active, waiting for tasks...")
                
                // Wait for both tasks to complete (or be canceled)
                let _ = await task1.result
                let _ = await task2.result
                
                logMessage("✅ All child tasks completed")
            } onCancel: {
                // This block will execute when parent task is canceled
                logMessage("⚠️ CancellationHandler: cancellation received, canceling child tasks")
                task1.cancel()
                task2.cancel()
            }
            
            logMessage("⌛ Parent Task with CancellationHandler completed")
        }
    }
    
    // Method with TaskGroup - demonstrates automatic child task cancellation
    func startWithTaskGroup() {
        clearLog()
        parentTask = Task {
            logMessage("🎯 Parent TaskGroup started")
            
            await withThrowingTaskGroup(of: Void.self) { group in
                // Add multiple child tasks
                for i in 1...3 {
                    group.addTask {
                        do {
                            self.logMessage("🧩 Child task \(i) started")
                            // Infinite loop with cancellation check
                            while true {
                                try Task.checkCancellation()
                                try await Task.sleep(nanoseconds: 500_000_000) // 500ms
                                self.logMessage("⏳ Child task \(i) working...")
                            }
                        } catch {
                            self.logMessage("❌ Child task \(i) canceled")
                        }
                    }
                }
            }
            
            logMessage("⌛ Parent TaskGroup completed")
        }
    }
    
    // Method with regular Task - demonstrates manual child task creation
    func startWithTask() {
        clearLog()
        parentTask = Task {
            logMessage("🎯 Parent Task started")
            
            // Create several child tasks
            let childTask1 = Task {
                do {
                    self.logMessage("🧵 Child Task 1 started")
                    while true {
                        try Task.checkCancellation()
                        try await Task.sleep(nanoseconds: 500_000_000)
                        self.logMessage("⏳ Child Task 1 working...")
                        try Task.checkCancellation()
                    }
                } catch {
                    self.logMessage("❌ Child Task 1 canceled")
                }
                try Task.checkCancellation()
            }
            
            let childTask2 = Task {
                do {
                    self.logMessage("🧵 Child Task 2 started")
                    while true {
                        try Task.checkCancellation()
                        try await Task.sleep(nanoseconds: 800_000_000)
                        self.logMessage("⏳ Child Task 2 working...")
                        try Task.checkCancellation()
                    }
                } catch {
                    self.logMessage("❌ Child Task 2 canceled")
                }
                try Task.checkCancellation()
            }
            
            // Wait for some time before completing parent task
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            logMessage("⌛ Parent Task completed")
            
            // Wait for child tasks to complete (in real situation this might be needed)
            // But when parent task is canceled, child tasks will !!NOT!! be canceled automatically

            if childTask2.isCancelled {
                print("task canceled!!!")
            }
            
            do {
                try await childTask1.value
                try await childTask2.value
            } catch {
                self.logMessage("❌ Child Task 1 canceled")
                self.logMessage("❌ Child Task 2 canceled")
            }
        }
    }
    
    // Method with Detached Task for comparison
    func startWithDetachedTask() {
        clearLog()
        parentTask = Task {
            logMessage("🎯 Parent Task started")
            
            // Create detached tasks
            Task.detached {
                do {
                    self.logMessage("🛰️ Detached Task 1 started")
                    while true {
                        try Task.checkCancellation()
                        try await Task.sleep(nanoseconds: 500_000_000)
                        self.logMessage("⏳ Detached Task 1 working...")
                    }
                } catch {
                    self.logMessage("❌ Detached Task 1 canceled")
                }
            }
            
            Task.detached {
                do {
                    self.logMessage("🛰️ Detached Task 2 started")
                    while true {
                        // Detached tasks ignore parent task cancellation
                        // and continue working even after parent is canceled
                        try await Task.sleep(nanoseconds: 800_000_000)
                        self.logMessage("⏳ Detached Task 2 working...")
                    }
                } catch {
                    self.logMessage("❌ Detached Task 2 canceled") // This won't execute when parent is canceled
                }
            }
            
            // Wait for some time
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            logMessage("⌛ Parent Task completed")
        }
    }
    
    func cancel() {
        parentTask?.cancel()
        logMessage("🔴 Parent task canceled")
    }
    
    private func clearLog() {
        log = ""
    }
    
    private func logMessage(_ message: String) {
        DispatchQueue.main.async {
            self.log.append("\(message)\n")
        }
    }
}

class TaskTestModel: ObservableObject {
    private var parentTask: Task<Void, Error>?
    
    func startWithTask() {
        parentTask = Task {
            
            let childTask1 = Task {
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    try Task.checkCancellation()
                    print("task completed")
                } catch {
                    print("task was canceled")
                }
            }
            
            try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            
            await childTask1.value
        }
    }
    
    func cancel() {
        parentTask?.cancel()
    }
    
}
