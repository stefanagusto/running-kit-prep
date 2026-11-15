import RunPrepCore
import SwiftUI

/// Two-place control for the cobalt card with a Liquid Glass thumb.
/// Tap a side, or press, hold and slide: the thumb swells into a glass lens,
/// follows the finger and springs into place on release.
struct PlacePicker: View {
    let selection: Place?
    let select: (Place) -> Void

    static let cobalt = Color(red: 0x1F / 255, green: 0x3F / 255, blue: 0xD6 / 255)

    /// Thumb centre while the finger is down; nil when resting.
    @State private var dragX: CGFloat?
    @State private var pressing = false
    /// Shown immediately after release, until the rebuild reports the new place.
    @State private var pending: Place?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let inset: CGFloat = 3
    private let height: CGFloat = 50

    private var shown: Place? { pending ?? selection }

    var body: some View {
        GeometryReader { geo in
            let half = (geo.size.width - inset * 2) / 2
            let center = thumbCenter(half: half)
            let hovered = place(at: center, width: geo.size.width)
            ZStack(alignment: .leading) {
                if shown != nil || dragX != nil {
                    thumb(width: half)
                        .position(x: center, y: height / 2)
                }
                HStack(spacing: 0) {
                    label(.ui, title: "UI campus", symbol: "bicycle", on: hovered == .ui)
                    label(.home, title: "Home", symbol: "house", on: hovered == .home)
                }
                .padding(.horizontal, inset)
                .allowsHitTesting(false)
            }
            .frame(width: geo.size.width, height: height)
            .background(.white.opacity(0.14), in: Capsule())
            .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
            .contentShape(Capsule())
            .gesture(drag(width: geo.size.width, half: half))
            .sensoryFeedback(.selection, trigger: hovered)
        }
        .frame(height: height)
        .onChange(of: selection) { _, new in
            if new == pending { pending = nil }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Start place")
        .accessibilityValue(valueText)
        .accessibilityHint("Swipe up or down to switch between UI campus and Home.")
        .accessibilityAdjustableAction { _ in choose(shown == .ui ? .home : .ui) }
        .accessibilityAction(named: "Start at UI campus") { choose(.ui) }
        .accessibilityAction(named: "Start at home") { choose(.home) }
    }

    // MARK: - Pieces

    private func thumb(width: CGFloat) -> some View {
        Capsule()
            .fill(.white.opacity(pressing ? 0.82 : 1))
            .frame(width: width, height: height - inset * 2)
            .glassEffect(.regular.interactive(), in: Capsule())
            .scaleEffect(pressing && !reduceMotion ? CGSize(width: 1.08, height: 1.16) : CGSize(width: 1, height: 1))
            .shadow(color: .black.opacity(pressing ? 0.25 : 0.12), radius: pressing ? 10 : 4, y: pressing ? 4 : 2)
    }

    private func label(_ place: Place, title: String, symbol: String, on: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).imageScale(.medium)
            Text(title).lineLimit(1)
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(on ? Self.cobalt : Color.white)
        .frame(maxWidth: .infinity, minHeight: 44)
        .animation(.easeInOut(duration: 0.35).delay(0.1), value: on)
    }

    // MARK: - Gesture

    private func drag(width: CGFloat, half: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !pressing {
                    withAnimation(.spring(duration: 0.3, bounce: 0.25)) { pressing = true }
                }
                // A tap only swells the thumb; it glides on release. A real slide tracks the finger.
                guard dragX != nil || abs(value.translation.width) > 6 else { return }
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.86)) {
                    dragX = value.location.x
                }
            }
            .onEnded { value in
                // A tap picks the tapped side; a slide picks the side the thumb is over.
                let x = dragX ?? value.location.x
                let target: Place = clamp(x, half: half) < width / 2 ? .ui : .home
                choose(target)
            }
    }

    private func choose(_ target: Place) {
        // Slow, soft glide like a tab bar lens: about half a second with a small settle.
        let glide: Animation = reduceMotion
            ? .easeOut(duration: 0.2)
            : .spring(duration: 0.55, bounce: 0.18)
        withAnimation(glide) {
            dragX = nil
            if target != selection { pending = target }
        }
        // The lens stays swollen while it travels, then shrinks back once it lands.
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.45, bounce: 0.2).delay(0.25)) {
            pressing = false
        }
        if target != selection { select(target) }
    }

    // MARK: - Geometry

    private func thumbCenter(half: CGFloat) -> CGFloat {
        if let dragX { return clamp(dragX, half: half) }
        let index: CGFloat = shown == .home ? 1 : 0
        return inset + half * index + half / 2
    }

    private func clamp(_ x: CGFloat, half: CGFloat) -> CGFloat {
        min(max(x, inset + half / 2), inset + half * 1.5)
    }

    private func place(at x: CGFloat, width: CGFloat) -> Place? {
        if dragX == nil, shown == nil { return nil }
        return x < width / 2 ? .ui : .home
    }

    private var valueText: String {
        switch shown {
        case .ui: return "UI campus"
        case .home: return "Home"
        case .none: return "Not set"
        }
    }
}

/// The card's one action: the prompt, the picker, the kit it implies and, when the
/// calendar chose, where that came from.
struct PlacePrompt: View {
    let session: Session
    let items: [ItemRule]
    let select: (Place) -> Void

    private static let lightText = Color(red: 0xE3 / 255, green: 0xE8 / 255, blue: 0xFF / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where do you start?")
                .font(.headline.weight(.bold))
            PlacePicker(selection: session.place, select: select)
            KitSummaryLine(session: session, items: items)
            if session.placeSource == .calendar {
                Text(sourceText)
                    .font(.footnote)
                    .foregroundStyle(Self.lightText)
            }
        }
        .padding(.top, 4)
    }

    private var sourceText: String {
        let location = session.location?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return location.isEmpty || location.count > 30
            ? "From your calendar"
            : "From your calendar \u{00B7} \(location)"
    }
}
