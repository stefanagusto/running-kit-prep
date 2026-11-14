import SwiftUI

struct NotificationsOffBanner: View {
    let openSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bell.slash")
                    .accessibilityHidden(true)
                Text("Notifications are off. Reminders will not arrive.")
                    .font(.subheadline.weight(.semibold))
            }
            Button("Open iOS Settings", action: openSettings)
                .buttonStyle(.bordered)
                .frame(minHeight: 44)
        }
        .foregroundStyle(Color("Warn"))
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("WarnSoft"), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
