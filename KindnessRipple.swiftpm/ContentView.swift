import SwiftUI
import NaturalLanguage
import Charts
import Observation

// MARK: - Models

enum Place: String, CaseIterable, Identifiable {
    case campus = "School Campus"
    case transit = "Public Transit"
    case home = "At Home"
    case neighborhood = "Neighborhood"
    case digital = "Online"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .campus: "graduationcap.fill"
        case .transit: "tram.fill"
        case .home: "house.fill"
        case .neighborhood: "leaf.fill"
        case .digital: "at.circle.fill"
        }
    }
}

struct Challenge: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let minutes: Int
    let ripplePoints: Int
}

struct KindAct: Identifiable {
    let id = UUID()
    var title: String
    var place: Place
    var reflection: String
    var sentiment: Double
    var date: Date
    var points: Int
}

struct DayPoint: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let happiness: Double
}

enum AppPhase: Int, CaseIterable {
    case welcome, generator, action, dashboard
    var headline: String {
        switch self {
        case .welcome: "00:00 — Welcome"
        case .generator: "00:45 — Context Challenge"
        case .action: "01:30 — Feel the Ripple"
        case .dashboard: "02:30 — Your Impact"
        }
    }
}

// MARK: - Offline Mock Intelligence (simulates Foundation Models)

func generateChallenge(for place: Place, salt: Int) -> Challenge {
    switch place {
    case .transit:
        let pool = [
            Challenge(title: "Offer your seat", detail: "Offer your seat to someone standing or leave an encouraging sticky note on a window.", minutes: 2, ripplePoints: 25),
            Challenge(title: "Transit thank-you", detail: "Thank your driver by name and brighten one rider's commute with a smile.", minutes: 1, ripplePoints: 20)
        ]
        return pool[abs(salt) % pool.count]
    case .campus:
        let pool = [
            Challenge(title: "Hold the door", detail: "Hold the door open for someone carrying boxes or compliment a classmate's work.", minutes: 2, ripplePoints: 25),
            Challenge(title: "Note of courage", detail: "Leave an anonymous note on a library desk: 'You belong here.'", minutes: 3, ripplePoints: 30)
        ]
        return pool[abs(salt) % pool.count]
    case .home:
        let pool = [
            Challenge(title: "Specific thank-you text", detail: "Send an unexpected text message thanking a family member for something specific.", minutes: 2, ripplePoints: 30),
            Challenge(title: "5-minute rescue", detail: "Do one chore no one asked you to — fold laundry, wash dishes with music on.", minutes: 5, ripplePoints: 35)
        ]
        return pool[abs(salt) % pool.count]
    case .neighborhood:
        return Challenge(title: "Sidewalk gift", detail: "Pick up 3 pieces of litter and wave at a neighbor you don't know yet.", minutes: 4, ripplePoints: 25)
    case .digital:
        return Challenge(title: "Kind comment", detail: "Leave a thoughtful, specific encouraging comment on a friend's post.", minutes: 2, ripplePoints: 20)
    }
}

// MARK: - On-device Sentiment (NaturalLanguage, 100% offline)
// NLTagger.sentimentScore returns -1.0 (negative) ... 1.0 (positive).
// We map that score directly to glow color + particles + points.

func analyzeSentiment(_ text: String) -> Double {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return 0 }
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = trimmed
    let (tag, _) = tagger.tag(at: trimmed.startIndex, unit: .paragraph, scheme: .sentimentScore)
    return Double(tag?.rawValue ?? "0") ?? 0
}

// MARK: - Store (Observation)

@Observable
final class RippleStore {
    var phase: AppPhase = .welcome
    var selectedPlace: Place = .campus
    var currentChallenge: Challenge = generateChallenge(for: .campus, salt: 0)
    var reflection: String = ""
    var sentiment: Double = 0
    var acts: [KindAct] = []

    var totalRipples: Int { acts.reduce(0) { $0 + $1.points } }
    var avgPositivity: Double {
        guard !acts.isEmpty else { return 0 }
        return acts.reduce(0) { $0 + $1.sentiment } / Double(acts.count)
    }
    var streak: Int {
        guard !acts.isEmpty else { return 0 }
        let cal = Calendar.current
        let days = Set(acts.map { cal.startOfDay(for: $0.date) })
        var count = 0
        var cursor = cal.startOfDay(for: Date())
        // if today empty, start from yesterday so streak doesn't break instantly
        if !days.contains(cursor) {
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
        }
        while days.contains(cursor) {
            count += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
            if count > 30 { break }
        }
        return max(count, 1)
    }

    var happinessSeries: [DayPoint] {
        let cal = Calendar.current
        var out: [DayPoint] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "E"
        for i in (0..<7).reversed() {
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            let dayActs = acts.filter { cal.isDate($0.date, inSameDayAs: d) }
            let happy = dayActs.reduce(0.0) { $0 + Double($1.points) }
            out.append(DayPoint(label: i == 0 ? "Today" : fmt.string(from: d), count: dayActs.count, happiness: happy))
        }
        return out
    }

    func refreshChallenge() {
        currentChallenge = generateChallenge(for: selectedPlace, salt: acts.count + reflection.count + 1)
    }

    func updateSentiment() {
        sentiment = analyzeSentiment(reflection)
    }

    func logCurrentAct() {
        let pts = max(10, Int(20 + sentiment * 40) + currentChallenge.ripplePoints / 2)
        acts.append(KindAct(title: currentChallenge.title, place: selectedPlace, reflection: reflection, sentiment: sentiment, date: Date(), points: pts))
        reflection = ""
        sentiment = 0
        refreshChallenge()
    }

    func simulateJudgeExperience() {
        let cal = Calendar.current
        let samples: [(String, Place, String, Double, Int)] = [
            ("Hold the door", .campus, "I held the door for a classmate today and they smiled, which made my morning feel much brighter!", 0.85, 3),
            ("Offer your seat", .transit, "Gave my seat to an elderly man, he was so grateful and we chatted happily.", 0.9, 2),
            ("Specific thank-you text", .home, "Texted mom thanking her for always packing lunch, she sent hearts back. I feel loved.", 0.95, 1),
            ("Sidewalk gift", .neighborhood, "Picked up litter on our street, a neighbor waved. Small but good.", 0.6, 1),
            ("Kind comment", .digital, "Left a kind comment on a friend's art. They said it made their day!", 0.8, 0)
        ]
        acts = samples.map { t, p, r, s, ago in
            KindAct(title: t, place: p, reflection: r, sentiment: s, date: cal.date(byAdding: .day, value: -ago, to: Date())!, points: Int(25 + s * 30))
        }
        selectedPlace = .campus
        refreshChallenge()
        phase = .generator
    }
}

// MARK: - Root

struct ContentView: View {
    @State private var store = RippleStore()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.10, blue: 0.29),
                    Color(red: 0.35, green: 0.27, blue: 0.62),
                    Color(red: 0.77, green: 0.71, blue: 0.99)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                PhaseProgressBar(phase: store.phase)
                    .padding(.horizontal)
                    .padding(.top, 12)

                switch store.phase {
                case .welcome: WelcomeView(store: store)
                case .generator: GeneratorView(store: store)
                case .action: ActionView(store: store)
                case .dashboard: DashboardView(store: store)
                }
            }
        }
        .tint(.white)
    }
}

struct PhaseProgressBar: View {
    var phase: AppPhase
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(phase.headline).font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.85))
                Spacer()
                Text("Kindness Ripple").font(.caption.weight(.bold)).foregroundStyle(.white)
            }
            ProgressView(value: Double(phase.rawValue + 1), total: 4)
                .tint(.white)
                .background(.white.opacity(0.25))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Phase A: Welcome

struct WelcomeView: View {
    var store: RippleStore
    @State private var animate = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Spacer(minLength: 16)
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(.white.opacity(0.25 - Double(i) * 0.07), lineWidth: 1.5)
                            .frame(width: 140 + CGFloat(i) * 55, height: 140 + CGFloat(i) * 55)
                            .scaleEffect(animate ? 1.08 : 0.94)
                            .animation(.easeInOut(duration: 2.5).repeatForever().delay(Double(i) * 0.3), value: animate)
                    }
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 84))
                        .foregroundStyle(.white, .pink)
                        .shadow(color: .pink.opacity(0.6), radius: 24)
                }
                .padding(.top, 10)

                Text("Kindness Ripple")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)

                Text("Small acts. Big ripples.\nLocal intelligence, measurable warmth.")
                    .font(.title3.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.horizontal)

                Text("Transform random acts of kindness into community ripples — 100% on-device with Natural Language & Charts. No accounts. No internet.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Button { store.simulateJudgeExperience() } label: {
                    Label("Simulate Judge Experience ✨", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.4))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                }
                .padding(.horizontal, 24)

                Button { store.phase = .generator } label: {
                    Text("Start fresh").font(.subheadline.weight(.semibold)).foregroundStyle(.white).padding(10)
                }
                Spacer()
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Phase B: Generator

struct GeneratorView: View {
    @Bindable var store: RippleStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Where are you?")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                Text("Pick a context. On-device intelligence crafts a micro-challenge instantly.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Place.allCases) { p in
                            Button {
                                store.selectedPlace = p
                                store.refreshChallenge()
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: p.icon).font(.title2)
                                    Text(p.rawValue).font(.caption.weight(.bold)).multilineTextAlignment(.center)
                                }
                                .foregroundStyle(store.selectedPlace == p ? Color(red: 0.25, green: 0.18, blue: 0.5) : .white)
                                .frame(width: 110, height: 96)
                                .background(store.selectedPlace == p ? .white : .white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.4), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cpu").foregroundStyle(.pink)
                        Text("LOCAL INTELLIGENCE").font(.caption.weight(.heavy)).foregroundStyle(.pink)
                        Spacer()
                        Text("\(store.currentChallenge.minutes) min • +\(store.currentChallenge.ripplePoints)")
                            .font(.caption.weight(.bold)).foregroundStyle(.secondary)
                    }
                    Text(store.currentChallenge.title).font(.system(.title2, design: .rounded).weight(.heavy))
                    Text(store.currentChallenge.detail).font(.body).foregroundStyle(.secondary)
                    HStack(spacing: 10) {
                        Button { store.phase = .action } label: {
                            Label("Do this kindness", systemImage: "arrow.right.heart.fill")
                                .font(.headline).foregroundStyle(.white)
                                .frame(maxWidth: .infinity).padding()
                                .background(LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        Button { store.refreshChallenge() } label: {
                            Image(systemName: "arrow.triangle.2.circlepath").font(.title2).foregroundStyle(.primary).padding().background(.ultraThinMaterial).clipShape(Circle())
                        }
                    }
                }
                .padding(20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                .padding(.horizontal, 20)

                Button { store.phase = .dashboard } label: {
                    Label("Skip to Impact Dashboard", systemImage: "chart.xyaxis.line")
                        .font(.footnote.weight(.semibold)).foregroundStyle(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }
}

// MARK: - Phase C: Action + Sentiment Glow

struct ActionView: View {
    @Bindable var store: RippleStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ACTIVE CHALLENGE • \(store.selectedPlace.rawValue.uppercased())")
                        .font(.caption.weight(.heavy)).foregroundStyle(.white.opacity(0.7))
                    Text(store.currentChallenge.title)
                        .font(.system(.title, design: .rounded).weight(.bold)).foregroundStyle(.white)
                    Text(store.currentChallenge.detail).foregroundStyle(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.top, 12)

                SentimentBloomView(score: store.sentiment)
                    .frame(height: 190)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Log completion").font(.headline)
                        Spacer()
                        SentimentBadge(score: store.sentiment)
                    }
                    TextEditor(text: $store.reflection)
                        .frame(minHeight: 110)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray.opacity(0.2)))
                        .onChange(of: store.reflection) { _, _ in store.updateSentiment() }
                    Text("Try: “I held the door for a classmate today and they smiled, which made my morning feel much brighter!”")
                        .font(.caption).foregroundStyle(.secondary)

                    Button {
                        store.logCurrentAct()
                        store.phase = .dashboard
                    } label: {
                        Label("Complete ripple • Feel awesome", systemImage: "heart.fill")
                            .font(.headline).foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(store.reflection.trimmingCharacters(in: .whitespaces).isEmpty ? AnyView(ViewBuilder.grayFill()) : AnyView(ViewBuilder.warmFill()))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(store.reflection.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button { store.phase = .generator } label: {
                        Text("← Change challenge").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                .padding(20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .sensoryFeedback(.success, trigger: store.sentiment)
    }
}

enum ViewBuilder {
    static func grayFill() -> some View { Color.gray }
    static func warmFill() -> some View {
        LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
    }
}

// Live particle glow mapped from sentiment score
struct SentimentBloomView: View {
    var score: Double
    var t: Double { max(0, min(1, (score + 1) / 2)) }
    @State private var shimmer = false

    var mood: String {
        switch score {
        case 0.6...: "Radiant ✨"
        case 0.2..<0.6: "Warming 🌤️"
        case -0.2..<0.2: "Neutral 🌫️"
        default: "Heavy 💙"
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(.white.opacity(0.12))
            Circle().fill(.gray.opacity(0.35 * (1 - t))).frame(width: 140, height: 140).blur(radius: 30)
            Circle().fill(Color(red: 1, green: 0.75, blue: 0.35).opacity(0.75 * t))
                .frame(width: 90 + 90 * t, height: 90 + 90 * t).blur(radius: 28)
            Circle().fill(Color(red: 1, green: 0.62, blue: 0.72).opacity(0.7 * t))
                .frame(width: 60 + 70 * t, height: 60 + 70 * t).blur(radius: 22)
                .offset(x: 30 * t, y: -20 * t)
            ForEach(0..<Int(10 + 22 * t), id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.35 + 0.55 * t))
                    .frame(width: 3 + 5 * t, height: 3 + 5 * t)
                    .offset(x: cos(Double(i) * 2.4) * (50 + 45 * t), y: sin(Double(i) * 2.4) * (40 + 35 * t))
                    .blur(radius: 0.5)
                    .opacity(shimmer ? 1 : 0.4)
                    .animation(.easeInOut(duration: 1.4).repeatForever().delay(Double(i) * 0.07), value: shimmer)
            }
            VStack(spacing: 4) {
                Text(String(format: "%.2f", score))
                    .font(.system(.title, design: .rounded).weight(.heavy)).foregroundStyle(.white)
                Text(mood).font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.9))
                Text("on-device NLTagger.sentimentScore").font(.caption2).foregroundStyle(.white.opacity(0.6))
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.3), lineWidth: 1))
        .onAppear { shimmer = true }
    }
}

struct SentimentBadge: View {
    var score: Double
    var body: some View {
        Text(score >= 0.6 ? "💛 Radiant" : score >= 0.2 ? "🧡 Warm" : score > -0.2 ? "🤍 Neutral" : "💙 Reflective")
            .font(.caption.weight(.bold))
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
    }
}

// MARK: - Phase D: Dashboard

struct DashboardView: View {
    @Bindable var store: RippleStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("You did it! 🎉")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                Text("In 3 minutes you turned small acts into measurable community ripples — all offline, all yours.")
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCard(value: "\(store.acts.count)", label: "Kind acts", icon: "heart.fill", color: .pink)
                    StatCard(value: "\(store.streak)d", label: "Streak", icon: "flame.fill", color: .orange)
                    StatCard(value: "\(store.totalRipples)", label: "Happiness", icon: "sparkles", color: .yellow)
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Kindness Streak & Community Happiness").font(.headline)
                    Chart(store.happinessSeries) { p in
                        BarMark(x: .value("Day", p.label), y: .value("Acts", p.count))
                            .foregroundStyle(LinearGradient(colors: [.pink, .orange], startPoint: .top, endPoint: .bottom))
                            .cornerRadius(6)
                        LineMark(x: .value("Day", p.label), y: .value("Happiness", p.happiness))
                            .foregroundStyle(.purple)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                            .symbolSize(40)
                    }
                    .frame(height: 220)
                    Text("Avg positivity: \(String(format: "%.2f", store.avgPositivity)) • Charts + NaturalLanguage, offline")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Your ripples 💧").font(.headline).foregroundStyle(.white).padding(.horizontal, 20)
                    ForEach(Array(store.acts.reversed())) { act in
                        HStack(spacing: 12) {
                            Image(systemName: act.place.icon)
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.2))
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(act.title).font(.subheadline.weight(.bold)).foregroundStyle(.white)
                                Text(act.reflection).font(.caption).foregroundStyle(.white.opacity(0.75)).lineLimit(2)
                            }
                            Spacer()
                            VStack {
                                Text("+\(act.points)").font(.caption.weight(.heavy)).foregroundStyle(.yellow)
                                Text(String(format: "%.2f", act.sentiment)).font(.caption2).foregroundStyle(.white.opacity(0.7))
                            }
                        }
                        .padding(12)
                        .background(.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.2)))
                        .padding(.horizontal, 20)
                    }
                }

                Button { store.phase = .welcome } label: {
                    Text("Replay 3-minute journey ↺")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.25, green: 0.18, blue: 0.5))
                        .frame(maxWidth: .infinity).padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(20)
            }
            .padding(.bottom, 20)
        }
    }
}

struct StatCard: View {
    var value: String
    var label: String
    var icon: String
    var color: Color
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(value).font(.system(.title2, design: .rounded).weight(.heavy))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
