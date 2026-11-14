import SwiftUI

/// Floating glass bar while items are left: the count, the next item and a jump button.
struct KitBar: View {
    let done: Int
    let total: Int
    let nextName: String?
    let jump: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(done) of \(total) \u{00B7} \(total - done) to go")
                    .font(.subheadline.weight(.semibold))
                if let nextName {
                    Text("Next: \(nextName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 8)
            Button(action: jump) {
                Image(systemName: "arrow.down")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor, in: Circle())
            }
            .accessibilityLabel("Go to next unticked item")
        }
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: .capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .scrollEdgeFade()
    }
}

struct DoneBar: View {
    let done: () -> Void

    var body: some View {
        Button(action: done) {
            Text("Done \u{00B7} have a good run")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .scrollEdgeFade()
    }
}

private extension View {
    /// Rows fade out before they pass under the floating bar, so the glass never
    /// shows text through text (DESIGN.md: scroll edge under floating bars).
    func scrollEdgeFade() -> some View {
        background(alignment: .bottom) {
            LinearGradient(
                stops: [
                    .init(color: Color(.systemGroupedBackground).opacity(0), location: 0),
                    .init(color: Color(.systemGroupedBackground), location: 0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .padding(.top, -48)
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
        }
    }
}
