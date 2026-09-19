import SwiftUI

struct ChatOverlayView: View {
    @Binding var isOpen: Bool
    @ObservedObject var activity: ChatActivityMonitor
    @StateObject private var commander = WebViewCommander()
    @State private var selectedProvider: AIProvider = .chatgpt

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("CatGPT").font(.headline)

                Picker("", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
                .labelsHidden()

                Spacer()
                Button(action: { commander.reload() }) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                }
                .buttonStyle(.plain)
                Button(action: { isOpen = false }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(12)

            // Your real ChatGPT or Claude session, not an API. First
            // launch of each provider will show a normal login page
            // inside this view — log in once per provider, it persists.
            ChatWebView(activity: activity, commander: commander, provider: selectedProvider)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}
