import SwiftUI

extension View {
    /// Applies the test-only appearance override. A no-op in release builds.
    func debugAppearance() -> some View { modifier(DebugAppearanceModifier()) }
}

#if DEBUG
// TEMPORARY (test only): remove before release
enum DebugAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct DebugAppearanceModifier: ViewModifier {
    @AppStorage("debugAppearance") private var raw = DebugAppearance.system.rawValue

    func body(content: Content) -> some View {
        content.preferredColorScheme(DebugAppearance(rawValue: raw)?.scheme)
    }
}

struct DebugAppearanceMenu: View {
    @AppStorage("debugAppearance") private var raw = DebugAppearance.system.rawValue

    var body: some View {
        Menu {
            Picker("Appearance", selection: $raw) {
                ForEach(DebugAppearance.allCases) { Text($0.title).tag($0.rawValue) }
            }
        } label: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
        }
    }
}
#else
struct DebugAppearanceModifier: ViewModifier {
    func body(content: Content) -> some View { content }
}
#endif
