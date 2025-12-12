//
//  SyncedScrollView.swift
//  DailyDozen
//

import SwiftUI

struct SyncedScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let coordinator: ScrollPositionCoordinator
    let version: Int
    
    init(coordinator: ScrollPositionCoordinator, version: Int, @ViewBuilder content: () -> Content) {
        self.coordinator = coordinator
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
            hostingController.rootView = content  // Update rootView in case of changes
        }
        restoreOffset(for: uiView, in: context, retry: 0)
    }
    
    private func restoreOffset(for scrollView: UIScrollView, in context: Context, retry: Int) {
        let targetOffset = coordinator.offset
        
        DispatchQueue.main.async {
            scrollView.layoutIfNeeded()
            let contentHeight = scrollView.contentSize.height
            let viewHeight = scrollView.bounds.height
            let maxOffset = max(0, contentHeight - viewHeight)
            
            guard maxOffset > 0 else {
                if retry < 20 {
                    print("RETRY RESTORE \(retry + 1): content not laid out (size=\(contentHeight))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // Increased delay for data settle
                        self.restoreOffset(for: scrollView, in: context, retry: retry + 1)
                    }
                } else {
                    print("RETRY LIMIT: abort restore")
                }
                return
            }
            
            let safeOffset = max(0, min(targetOffset, maxOffset))
            
           // print("ATTEMPT RESTORE: offset → \(safeOffset)/\(maxOffset) (contentHeight: \(contentHeight))")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {  // Increased delay
                let currentY = scrollView.contentOffset.y
                if abs(currentY - safeOffset) > 10 && !context.coordinator.isRestoring {  // Increased threshold
                    context.coordinator.isRestoring = true
                    print("RESTORED → \(safeOffset)")
                    scrollView.setContentOffset(CGPoint(x: 0, y: safeOffset), animated: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        context.coordinator.isRestoring = false
                        print("RESTORE DONE")
                    }
                } else {
                   // print("RESTORE SKIPPED: diff=\(abs(currentY - safeOffset)) or restoring")
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coordinator: coordinator)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let coordinator: ScrollPositionCoordinator
        weak var scrollView: UIScrollView?
        weak var hostingController: UIHostingController<Content>?
        var isRestoring: Bool = false
        
        init(coordinator: ScrollPositionCoordinator) {
            self.coordinator = coordinator
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if isRestoring { return }
            
            let offset = max(0, scrollView.contentOffset.y)  // Clamp bounce
            
           // print("SCROLL → offset: \(offset)")
            
            Task { @MainActor in
                await coordinator.setOffset(offset)
            }
        }
    }
}

@MainActor
@Observable
final class ScrollPositionCoordinator {
    var offset: CGFloat = 0
    var version: Int = 0
    
    private var debounceTask: Task<Void, Never>?
    
    func setOffset(_ newOffset: CGFloat) async {
        let offset = max(0, newOffset)
        
        debounceTask?.cancel()
        debounceTask = nil
        
        debounceTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .milliseconds(200))
                if Task.isCancelled { return }
                
                if abs(offset - self.offset) > 5 {  // Keep threshold to avoid jitter
                    self.offset = offset
                    self.version += 1
                    print("APPLIED OFFSET: \(offset)")
                }
            } catch {}
        }
    }
}
