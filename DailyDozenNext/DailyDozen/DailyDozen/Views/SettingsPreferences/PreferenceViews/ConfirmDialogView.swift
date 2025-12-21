//
//  ConfirmDialogView.swift
//  DailyDozen
//
//
//

import SwiftUI

// MARK: - Reusable Confirmation Dialog Modifier

struct ConfirmDialog: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let confirmTitle: String      // ← renamed clearly
    let confirmRole: ButtonRole
    let onConfirm: () -> Void
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                title,
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                Button(confirmTitle, role: confirmRole) {
                    onConfirm()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let message = message {
                    Text(message)
                }
            }
    }
}

// MARK: - Extension

extension View {
    func reusableConfirmDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        confirmTitle: String = "Yes",          // ← default is "Yes"
        confirmRole: ButtonRole = .destructive,
        action: @escaping () -> Void
    ) -> some View {
        modifier(ConfirmDialog(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            confirmRole: confirmRole,
            onConfirm: action
        ))
    }
}
