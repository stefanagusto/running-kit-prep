import WidgetKit
import SwiftUI
import ActivityKit

@main
struct SpikeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SpikeAppGroupWidget()
        SpikeLiveActivity()
    }
}

struct SpikeEntry: TimelineEntry {
    let date: Date
    let value: String
}

struct SpikeProvider: TimelineProvider {
    private func current() -> String {
        UserDefaults(suiteName: SpikeShared.appGroup)?.string(forKey: SpikeShared.key) ?? "MISSING"
    }

    func placeholder(in context: Context) -> SpikeEntry {
        SpikeEntry(date: Date(), value: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (SpikeEntry) -> Void) {
        completion(SpikeEntry(date: Date(), value: current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SpikeEntry>) -> Void) {
        let entry = SpikeEntry(date: Date(), value: current())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct SpikeAppGroupWidget: Widget {
    let kind = "SpikeAppGroupWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpikeProvider()) { entry in
            Text("App Group: \(entry.value)")
                .font(.footnote)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("App Group check")
        .description("Shows the value the app wrote to the App Group.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

struct SpikeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SpikeActivityAttributes.self) { context in
            VStack(alignment: .leading) {
                Text("Kit check · \(context.attributes.sessionTitle)")
                    .font(.headline)
                Text("\(context.state.ticked) of \(context.state.total)")
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.sessionTitle)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.ticked)/\(context.state.total)")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.state.ticked) of \(context.state.total) packed")
                }
            } compactLeading: {
                Image(systemName: "backpack")
            } compactTrailing: {
                Text("\(context.state.ticked)/\(context.state.total)")
            } minimal: {
                Image(systemName: "backpack")
            }
        }
    }
}
