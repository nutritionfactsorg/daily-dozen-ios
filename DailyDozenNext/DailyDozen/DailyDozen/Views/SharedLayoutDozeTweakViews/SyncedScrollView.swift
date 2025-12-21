//  SyncedScrollView.swift

import SwiftUI

// MARK: - ScrollPositionCoordinator
@MainActor
@Observable
final class ScrollPositionCoordinator {
    var offset: CGFloat = 0
    var version: Int = 0
    var lastSourceID: UUID?  // Tracks who last set the offset
    
    private var debounceTask: Task<Void, Never>?
    
    func setOffset(_ newOffset: CGFloat, from sourceID: UUID) async {
        let offset = max(0, newOffset)
        
        debounceTask?.cancel()
        debounceTask = nil
        
        debounceTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(150))
                if Task.isCancelled { return }
                
                if abs(offset - self.offset) > 5 {
                    self.lastSourceID = sourceID
                    self.offset = offset
                    self.version += 1
                    // print("APPLIED OFFSET: \(offset) from \(sourceID)")
                }
            } catch {}
        }
    }
}

// MARK: - SyncedScrollView
struct SyncedScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let coordinator: ScrollPositionCoordinator
    let version: Int
    let id: UUID  // Unique per instance
    
    init(coordinator: ScrollPositionCoordinator, id: UUID, version: Int, @ViewBuilder content: () -> Content) {
        self.coordinator = coordinator
        self.id = id
        self.version = version
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = true
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        context.coordinator.hostingController = hostingController
        context.coordinator.scrollView = scrollView
        
        restoreOffset(for: scrollView, in: context, retry: 0)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if let hostingController = context.coordinator.hostingController {
            hostingController.rootView = content
        }
        restoreOffset(for: uiView, in: context, retry: 0)
    }
    
    private func restoreOffset(for scrollView: UIScrollView, in context: Context, retry: Int) {
        guard context.coordinator.id != coordinator.lastSourceID else {
            // Skip if this view initiated the last change (already at correct offset)
            // print("RESTORE SKIPPED: initiator")
            return
        }
        
        let targetOffset = coordinator.offset
        
        scrollView.layoutIfNeeded()
        let contentHeight = scrollView.contentSize.height
        let viewHeight = scrollView.bounds.height
        let maxOffset = max(0, contentHeight - viewHeight)
        
        guard maxOffset > 0 else {
            if retry < 5 {
                // print("RETRY RESTORE \(retry + 1): content not laid out")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.restoreOffset(for: scrollView, in: context, retry: retry + 1)
                }
            }
            return
        }
        
        let safeOffset = max(0, min(targetOffset, maxOffset))
        let currentY = scrollView.contentOffset.y
        
        if abs(currentY - safeOffset) > 10 && !context.coordinator.isRestoring {
            context.coordinator.isRestoring = true
            // print("RESTORED → \(safeOffset)")
            scrollView.setContentOffset(CGPoint(x: 0, y: safeOffset), animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                context.coordinator.isRestoring = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coordinator: coordinator, id: id)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let coordinator: ScrollPositionCoordinator
        let id: UUID
        weak var scrollView: UIScrollView?
        weak var hostingController: UIHostingController<Content>?
        var isRestoring: Bool = false
        
        init(coordinator: ScrollPositionCoordinator, id: UUID) {
            self.coordinator = coordinator
            self.id = id
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if isRestoring { return }
            
            let offset = max(0, scrollView.contentOffset.y)
            
            Task { @MainActor in
                await coordinator.setOffset(offset, from: id)
            }
        }
    }
}
