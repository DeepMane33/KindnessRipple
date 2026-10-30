import SwiftUI
import WidgetKit
import ActivityKit

struct KindnessRippleEntry: TimelineEntry {
    let date: Date
    let totalRipples: Int
    let level: RippleLevel
}

struct KindnessRippleProvider: TimelineProvider {
    func placeholder(in context: Context) -> KindnessRippleEntry {
        KindnessRippleEntry(date: Date(), totalRipples: 0, level: .seed)
    }
    func getSnapshot(in context: Context, completion: @escaping (KindnessRippleEntry) -> Void) {
        completion(KindnessRippleEntry(date: Date(), totalRipples: 0, level: .seed))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<KindnessRippleEntry>) -> Void) {
        let entry = KindnessRippleEntry(date: Date(), totalRipples: 0, level: .seed)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct KindnessRippleWidgetEntryView: View {
    var entry: KindnessRippleProvider.Entry
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: entry.level.icon).font(.title2).foregroundStyle(Color(red: 0.76, green: 0.84, blue: 0.76))
            Text("\(entry.totalRipples)").font(.headline).fontDesign(.rounded).foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
            Text(entry.level.title).font(.caption2).foregroundStyle(Color(red: 0.65, green: 0.60, blue: 0.55))
        }
        .containerBackground(LinearGradient(colors: [Color(red: 0.97, green: 0.95, blue: 0.90), Color(red: 0.94, green: 0.91, blue: 0.85)], startPoint: .topLeading, endPoint: .bottomTrailing), for: .widget)
    }
}

struct KindnessRippleWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KindnessRippleWidget", provider: KindnessRippleProvider()) { entry in
            KindnessRippleWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kindness Ripple")
        .description("Your ripple garden at a glance.")
        .supportedFamilies([.systemSmall])
    }
}

struct KindnessRippleActivityAttributes: ActivityAttributes {
    public struct ContentState {
        var currentChallenge: String
        var minutesLeft: Int
    }
    public var challengeTitle: String
}

struct KindnessRippleActivityView: View {
    let context: ActivityViewContext<KindnessRippleActivityAttributes>
    var body: some View {
        VStack(spacing: 4) {
            Text(context.attributes.challengeTitle).font(.headline).fontDesign(.rounded).foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
            Text("\(context.state.minutesLeft) min left").font(.subheadline).foregroundStyle(Color(red: 0.65, green: 0.60, blue: 0.55))
            ProgressView()
                .tint(Color(red: 0.76, green: 0.84, blue: 0.76))
        }
        .padding()
        .activityBackgroundTint(Color(red: 0.97, green: 0.95, blue: 0.90))
        .activitySystemActionForegroundColor(Color(red: 0.30, green: 0.27, blue: 0.22))
    }
}

struct KindnessRippleLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KindnessRippleActivityAttributes.self) { context in
            KindnessRippleActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.challengeTitle)
                        .font(.headline).foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
                }
            } compactLeading: {
                Text("Ripple").foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
            } compactTrailing: {
                Text("\(context.state.minutesLeft)").foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
            } minimal: {
                Text("•").foregroundStyle(Color(red: 0.76, green: 0.84, blue: 0.76))
            }
        }
    }
}
