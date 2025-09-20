import SwiftUI

public struct OfflineStateView: View {
    let title: String
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    public init(title: String = "Brak połączenia",
                message: String = "Sprawdź połączenie i spróbuj ponownie.",
                retryTitle: String = "Spróbuj ponownie",
                onRetry: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .fontWeight(.thin)
                .opacity(0.5)
            Text(title)
                .font(.custom("PPEditorialNew-Regular", size: 30))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundStyle(.secondary)
            Button(action: onRetry) {
                Text(retryTitle)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
        .multilineTextAlignment(.center)
        .centered()
    }
}

private extension View {
    func centered() -> some View {
        VStack {
            Spacer()
            self
            Spacer()
        }
    }
}
