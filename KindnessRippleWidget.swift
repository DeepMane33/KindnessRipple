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
            Image(systemName: entry.level.icon).font(.title2).foregroundStyle(Theme.success)
            Text("\(entry.totalRipples)").font(.headline).fontDesign(.rounded).foregroundStyle(Theme.ink)
            Text(entry.level.title).font(.caption2).foregroundStyle(Theme.inkSoft)
        }
        .containerBackground(Theme.bg, for: .widget)
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
            Text(context.attributes.challengeTitle).font(.headline).fontDesign(.rounded).foregroundStyle(Theme.ink)
            Text("\(context.state.minutesLeft) min left").font(.subheadline).foregroundStyle(Theme.inkSoft)
            ProgressView()
                .tint(Theme.success)
        }
        .padding()
        .activityBackgroundTint(Color(red: 0.985, green: 0.975, blue: 0.945))
        .activitySystemActionForegroundColor(Theme.ink)
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
                        .font(.headline).foregroundStyle(Theme.ink)
                }
            } compactLeading: {
                Text("Ripple").foregroundStyle(Theme.ink)
            } compactTrailing: {
                Text("\(context.state.minutesLeft)").foregroundStyle(Theme.ink)
            } minimal: {
                Text("•").foregroundStyle(Theme.success)
            }
        }
    }
}
