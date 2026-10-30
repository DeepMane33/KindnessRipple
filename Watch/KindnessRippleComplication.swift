import SwiftUI
import ClockKit
import AppModule

struct KindnessRippleComplicationProvider: CLKComplicationDataSource {
    let totalRipples: Int
    let level: RippleLevel

    init(totalRipples: Int = 0, level: RippleLevel = .seed) {
        self.totalRipples = totalRipples
        self.level = level
    }

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "kindness.ripple.circular", displayName: "Kindness Ripple", supportedFamilies: [.circularSmall])
        ]
        handler(descriptors)
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let template = CLKComplicationTemplateCircularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: "\(totalRipples)"))
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        handler([entry])
    }

    func getPlaceholderTemplate(for complication: CLKComplication, handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(CLKComplicationTemplateCircularSmallSimpleText(textProvider: CLKSimpleTextProvider(text: "0")))
    }
}

struct KindnessRippleComplicationView: View {
    let totalRipples: Int
    let level: RippleLevel
    var body: some View {
        ZStack {
            Circle().stroke(Color(red: 0.89, green: 0.85, blue: 0.78).opacity(0.4), lineWidth: 4)
            VStack {
                Image(systemName: level.icon).font(.caption2).foregroundStyle(Theme.success)
                Text("\(totalRipples)").font(.headline).fontDesign(.rounded).foregroundStyle(Theme.ink)
            }
        }
    }
}
