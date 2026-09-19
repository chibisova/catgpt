import Foundation

enum AIProvider: String, CaseIterable, Identifiable {
    case chatgpt
    case claude

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .chatgpt: return "GPT"
        case .claude: return "Claude"
        }
    }

    var url: URL {
        switch self {
        case .chatgpt: return URL(string: "https://chatgpt.com")!
        case .claude: return URL(string: "https://claude.ai")!
        }
    }
}
