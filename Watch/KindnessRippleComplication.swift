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
            Circle().stroke(Color(red: 0.90, green: 0.87, blue: 0.82).opacity(0.4), lineWidth: 4)
            VStack {
                Image(systemName: level.icon).font(.caption2).foregroundStyle(Color(red: 0.76, green: 0.84, blue: 0.76))
                Text("\(totalRipples)").font(.headline).fontDesign(.rounded).foregroundStyle(Color(red: 0.30, green: 0.27, blue: 0.22))
            }
        }
    }
}
