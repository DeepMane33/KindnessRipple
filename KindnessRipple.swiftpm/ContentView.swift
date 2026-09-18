import SwiftUI
import NaturalLanguage
import Charts
import Observation
import PencilKit
import AppIntents

// MARK: - Pastel Theme

enum PastelTheme {
    static let lavender = Color(red: 0.76, green: 0.71, blue: 0.96)
    static let softPink = Color(red: 0.96, green: 0.76, blue: 0.84)
    static let peach = Color(red: 1.0, green: 0.82, blue: 0.74)
    static let mint = Color(red: 0.72, green: 0.93, blue: 0.85)
    static let skyBlue = Color(red: 0.74, green: 0.87, blue: 1.0)
    static let buttercup = Color(red: 1.0, green: 0.93, blue: 0.73)
    static let lilac = Color(red: 0.84, green: 0.78, blue: 0.96)
    static let rose = Color(red: 0.98, green: 0.82, blue: 0.85)
    static let backgroundTop = Color(red: 0.88, green: 0.82, blue: 0.96)
    static let backgroundBottom = Color(red: 0.96, green: 0.88, blue: 0.92)
}

// MARK: - Glassmorphism Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 24
    var opacity: Double = 0.55
    var tint: Color = PastelTheme.lavender
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .opacity(opacity)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

struct GlassBadge: ViewModifier {
    var tint: Color = PastelTheme.lavender
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, opacity: Double = 0.55, tint: Color = PastelTheme.lavender) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, opacity: opacity, tint: tint))
    }
    func glassBadge(tint: Color = PastelTheme.lavender) -> some View {
        modifier(GlassBadge(tint: tint))
    }
}

// MARK: - Models

enum Place: String, CaseIterable, Identifiable, Codable {
    case campus = "Campus"
    case transit = "Transit"
    case home = "Home"
    case neighborhood = "Neighborhood"
    case digital = "Online"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .campus: "book.fill"
        case .transit: "tram.fill"
        case .home: "house.fill"
        case .neighborhood: "leaf.fill"
        case .digital: "at.circle.fill"
        }
    }
    var color: Color {
        switch self {
        case .campus: PastelTheme.lavender
        case .transit: PastelTheme.skyBlue
        case .home: PastelTheme.peach
        case .neighborhood: PastelTheme.mint
        case .digital: PastelTheme.lilac
        }
    }
}

enum Energy: String, CaseIterable, Identifiable, Codable {
    case low = "Gentle"
    case okay = "Steady"
    case bright = "Bold"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .low: "moon.fill"
        case .okay: "sun.min.fill"
        case .bright: "sun.max.fill"
        }
    }
    var hint: String {
        switch self {
        case .low: "1-min acts"
        case .okay: "2-5 min acts"
        case .bright: "5+ min acts"
        }
    }
    var color: Color {
        switch self {
        case .low: PastelTheme.skyBlue
        case .okay: PastelTheme.buttercup
        case .bright: PastelTheme.peach
        }
    }
}

enum Mood: String, CaseIterable, Identifiable, Codable {
    case amazing = "Amazing"
    case happy = "Happy"
    case calm = "Calm"
    case okay = "Okay"
    case low = "Low"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .amazing: "sparkles"
        case .happy: "face.smiling.fill"
        case .calm: "cloud.sun.fill"
        case .okay: "cloud.fill"
        case .low: "cloud.rain.fill"
        }
    }
    var color: Color {
        switch self {
        case .amazing: PastelTheme.buttercup
        case .happy: PastelTheme.peach
        case .calm: PastelTheme.mint
        case .okay: PastelTheme.skyBlue
        case .low: PastelTheme.lavender
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

struct KindAct: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var place: Place
    var energy: Energy
    var reflection: String
    var sentiment: Double
    var keywords: [String]
    var date: Date
    var points: Int
    var minutes: Int
}

struct MoodEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var mood: Mood
    var note: String
    var date: Date
}

enum DeedType: String, Codable, CaseIterable, Identifiable {
    case good = "Good Deed"
    case reflect = "Area to Improve"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .good: "hand.thumbsup.fill"
        case .reflect: "hand.thumbsdown.fill"
        }
    }
    var color: Color {
        switch self {
        case .good: PastelTheme.mint
        case .reflect: PastelTheme.peach
        }
    }
}

struct DailyReflection: Identifiable, Codable {
    var id: UUID = UUID()
    var text: String
    var deedType: DeedType
    var rating: Int
    var characterPoints: Int
    var date: Date
    var tags: [String]
}

struct DayPoint: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let happiness: Double
}

enum RippleLevel: Int, CaseIterable {
    case seed, sprout, stream, river, ocean
    var title: String {
        switch self {
        case .seed: "Seed"
        case .sprout: "Sprout"
        case .stream: "Stream"
        case .river: "River"
        case .ocean: "Ocean"
        }
    }
    var threshold: Int {
        switch self {
        case .seed: 0
        case .sprout: 60
        case .stream: 150
        case .river: 300
        case .ocean: 500
        }
    }
    var icon: String {
        switch self {
        case .seed: "seedling"
        case .sprout: "leaf.fill"
        case .stream: "drop.fill"
        case .river: "water.waves"
        case .ocean: "wind"
        }
    }
    static func level(for points: Int) -> RippleLevel {
        var cur: RippleLevel = .seed
        for l in RippleLevel.allCases where points >= l.threshold { cur = l }
        return cur
    }
}

struct BadgeDef: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let icon: String
}

enum AppTab: Int, CaseIterable, Hashable {
    case home, journal, dashboard, breathe
}

// MARK: - Offline intelligence

func generateChallenge(for place: Place, energy: Energy, minutes: Int, salt: Int) -> Challenge {
    let lowPool: [Place: [Challenge]] = [
        .campus: [
            Challenge(title: "Silent Cheer", detail: "Smile at a classmate and mouth 'you got this' — 30 seconds, zero words needed.", minutes: 1, ripplePoints: 15),
            Challenge(title: "Seat Swap", detail: "Give up your comfy seat to someone who looks tired.", minutes: 1, ripplePoints: 12),
            Challenge(title: "Door Hold", detail: "Hold the door for someone with full hands.", minutes: 1, ripplePoints: 15)
        ],
        .transit: [
            Challenge(title: "Space Gift", detail: "Move your bag, make space, and offer a nod to someone standing.", minutes: 1, ripplePoints: 15),
            Challenge(title: "Kind Eyes", detail: "Make eye contact and smile at a fellow commuter.", minutes: 1, ripplePoints: 10)
        ],
        .home: [
            Challenge(title: "Thank-You Text", detail: "Send one specific thank-you text to a family member.", minutes: 1, ripplePoints: 20),
            Challenge(title: "Compliment Drop", detail: "Leave a sticky note compliment on someone's desk or mirror.", minutes: 1, ripplePoints: 18)
        ],
        .neighborhood: [
            Challenge(title: "Wave Hello", detail: "Wave at a neighbor you don't know yet.", minutes: 1, ripplePoints: 12),
            Challenge(title: "Plant Kindness", detail: "Pick up one piece of litter on your walk.", minutes: 1, ripplePoints: 15)
        ],
        .digital: [
            Challenge(title: "One-Line Lift", detail: "Leave 5 specific kind words on a friend's post.", minutes: 1, ripplePoints: 12),
            Challenge(title: "Voice Note", detail: "Send a 30-second voice message telling someone you appreciate them.", minutes: 1, ripplePoints: 18)
        ]
    ]
    let midPool: [Place: [Challenge]] = [
        .campus: [
            Challenge(title: "Note of Courage", detail: "Leave an anonymous note on a library desk: 'You belong here.'", minutes: 3, ripplePoints: 30),
            Challenge(title: "Study Buddy", detail: "Offer to help someone who looks stuck on a problem.", minutes: 5, ripplePoints: 35),
            Challenge(title: "Snack Share", detail: "Share your snack with a classmate who forgot theirs.", minutes: 2, ripplePoints: 25)
        ],
        .transit: [
            Challenge(title: "Offer Your Seat", detail: "Offer your seat to someone standing or leave a sticky note on a window.", minutes: 2, ripplePoints: 25),
            Challenge(title: "Driver Thanks", detail: "Thank your transit driver by name and brighten their route.", minutes: 2, ripplePoints: 22)
        ],
        .home: [
            Challenge(title: "5-Minute Rescue", detail: "Do one chore no one asked you to — fold laundry, wash dishes.", minutes: 5, ripplePoints: 35),
            Challenge(title: "Memory Ping", detail: "Call a relative for 3 minutes and ask about their day first.", minutes: 3, ripplePoints: 30),
            Challenge(title: "Cook Surprise", detail: "Make a small snack for someone with a sweet note.", minutes: 5, ripplePoints: 32)
        ],
        .neighborhood: [
            Challenge(title: "Sidewalk Gift", detail: "Pick up 3 pieces of litter and wave at a neighbor.", minutes: 4, ripplePoints: 25),
            Challenge(title: "Flower Drop", detail: "Leave a flower or plant cutting at a neighbor's door.", minutes: 3, ripplePoints: 28)
        ],
        .digital: [
            Challenge(title: "Kind Comment", detail: "Leave a thoughtful, specific encouraging comment on a friend's post.", minutes: 2, ripplePoints: 20),
            Challenge(title: "Shout-Out Story", detail: "Share a story celebrating a quiet friend's win.", minutes: 3, ripplePoints: 25)
        ]
    ]
    let boldPool: [Place: [Challenge]] = [
        .campus: [
            Challenge(title: "Study Rescue", detail: "Offer 15 minutes to help someone stuck on homework in the library.", minutes: 15, ripplePoints: 50),
            Challenge(title: "Kindness Wall", detail: "Create a mini 'kindness wall' in the bathroom with encouraging notes.", minutes: 10, ripplePoints: 45)
        ],
        .transit: [
            Challenge(title: "Carry Help", detail: "Offer to carry a heavy bag up stairs for someone struggling.", minutes: 5, ripplePoints: 40)
        ],
        .home: [
            Challenge(title: "Cook Surprise", detail: "Cook a full meal or plate a surprise snack for family with a note.", minutes: 15, ripplePoints: 50),
            Challenge(title: "Memory Book", detail: "Create a mini scrapbook page of a happy family memory.", minutes: 15, ripplePoints: 45)
        ],
        .neighborhood: [
            Challenge(title: "Mini Cleanup", detail: "15-minute block cleanup: one bag, one street, one photo for you.", minutes: 15, ripplePoints: 45),
            Challenge(title: "Bake & Share", detail: "Bake cookies or treats and deliver to a neighbor.", minutes: 15, ripplePoints: 50)
        ],
        .digital: [
            Challenge(title: "Hype Thread", detail: "Write a 3-sentence shout-out post celebrating a quiet friend.", minutes: 5, ripplePoints: 35),
            Challenge(title: "Kindness Playlist", detail: "Create and share a playlist of uplifting songs for a friend.", minutes: 5, ripplePoints: 30)
        ]
    ]
    let pool: [Challenge]
    switch energy {
    case .low: pool = lowPool[place] ?? []
    case .okay: pool = midPool[place] ?? []
    case .bright: pool = boldPool[place] ?? []
    }
    guard !pool.isEmpty else { return Challenge(title: "Small Hello", detail: "Say hello kindly to one person near you.", minutes: 1, ripplePoints: 10) }
    let idx = abs(salt + minutes) % pool.count
    return pool[idx]
}

func analyzeSentiment(_ text: String) -> Double {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !t.isEmpty else { return 0 }
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = t
    let (tag, _) = tagger.tag(at: t.startIndex, unit: .paragraph, scheme: .sentimentScore)
    return Double(tag?.rawValue ?? "0") ?? 0
}

func extractKeywords(_ text: String) -> [String] {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !t.isEmpty else { return [] }
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = t
    var words: [String] = []
    let opts: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
    tagger.enumerateTags(in: t.startIndex..<t.endIndex, unit: .word, scheme: .lexicalClass, options: opts) { tag, range in
        if tag == .noun || tag == .personalName || tag == .placeName {
            let w = String(t[range]).lowercased().trimmingCharacters(in: .punctuationCharacters)
            if w.count > 2 && !words.contains(w) { words.append(w) }
        }
        return true
    }
    return Array(words.prefix(3))
}

let dailyAffirmations = [
    "You are enough, just as you are.",
    "Every small act of kindness creates a ripple.",
    "Today is full of possibility.",
    "You have the power to brighten someone's day.",
    "Be gentle with yourself and others.",
    "Your kindness matters more than you know.",
    "The world is better because you're in it.",
    "Take a breath. You're doing great.",
    "Choose compassion, always.",
    "Your light touches more lives than you realize."
]

let funFacts = [
    "5 min of helping can lift your whole day.",
    "Kindness lowers cortisol by 23%.",
    "Gratitude journaling improves sleep quality.",
    "Small daily acts beat rare big ones for habits.",
    "Kindness releases oxytocin, the 'love hormone.'",
    "Being kind activates the brain's pleasure centers.",
    "Helping others reduces inflammation in the body.",
    "Kind people are perceived as more attractive."
]

let motivationalQuotes = [
    ("\"The best way to find yourself is to lose yourself in the service of others.\"", "Mahatma Gandhi"),
    ("\"No act of kindness, no matter how small, is ever wasted.\"", "Aesop"),
    ("\"Kindness is the language which the deaf can hear and the blind can see.\"", "Mark Twain"),
    ("\"The meaning of life is to find your gift. The purpose of life is to give it away.\"", "Pablo Picasso"),
    ("\"What we do for ourselves dies with us. What we do for others and the world remains and is immortal.\"", "Albert Pine"),
    ("\"Carry out a random act of kindness, with no expectation of reward.\"", "Princess Diana"),
    ("\"In a world where you can be anything, be kind.\"", "Jennifer Ditz"),
    ("\"The roots of all goodness lie in the soil of goodness for society.\"", "Dalai Lama"),
    ("\"Happiness is not something ready made. It comes from your own actions.\"", "Dalai Lama"),
    ("\"Tell me and I forget. Teach me and I remember. Involve me and I learn.\"", "Benjamin Franklin"),
    ("\"The best time to plant a tree was 20 years ago. The second best time is now.\"", "Chinese Proverb"),
    ("\"Be the change that you wish to see in the world.\"", "Mahatma Gandhi"),
    ("\"If you want others to be happy, practice compassion. If you want to be happy, practice compassion.\"", "Dalai Lama"),
    ("\"People will forget what you said, people will forget what you did, but people will never forget how you made them feel.\"", "Maya Angelou"),
    ("\"The strongest people are not those who show strength in front of us, but those who win battles we know nothing about.\"", "Jonathan Harnish"),
    ("\"Your character is your fate.\"", "Heraclitus"),
    ("\"Integrity is doing the right thing, even when no one is watching.\"", "C.S. Lewis"),
    ("\"We make a living by what we get, but we make a life by what we give.\"", "Winston Churchill"),
    ("\"The price of greatness is responsibility.\"", "Winston Churchill"),
    ("\"What you do speaks so loudly that I cannot hear what you say.\"", "Ralph Waldo Emerson")
]

func rateDailyReflection(_ text: String, type: DeedType) -> (rating: Int, points: Int, tags: [String]) {
    let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !t.isEmpty else { return (0, 0, []) }
    let words = t.split(separator: " ").map(String.init)
    let wordCount = words.count
    let sentiment = analyzeSentiment(t)
    let keywords = extractKeywords(t)
    var baseScore: Int
    if type == .good {
        baseScore = 50
        baseScore += min(20, wordCount)
        baseScore += Int(sentiment * 20)
        if wordCount > 20 { baseScore += 10 }
        if keywords.count >= 2 { baseScore += 10 }
    } else {
        baseScore = 30
        baseScore += min(15, wordCount)
        baseScore += Int(max(0, sentiment + 1) * 10)
        if t.lowercased().contains("next time") || t.lowercased().contains("learn") || t.lowercased().contains("improve") {
            baseScore += 15
        }
        if wordCount > 15 { baseScore += 10 }
    }
    let rating = max(1, min(10, baseScore / 10))
    let points = type == .good ? rating * 3 : rating * 2
    return (rating, points, Array(keywords.prefix(3)))
}

// Siri / Shortcuts
struct LogKindnessIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Kindness Ripple"
    static var description = IntentDescription("Logs a quick kindness moment.")
    @Parameter(title: "Reflection") var reflection: String
    init() { reflection = "" }
    init(reflection: String) { self.reflection = reflection }
    static var parameterSummary: some ParameterSummary { Summary("Log \(\.$reflection)") }
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Ripple noted. Small act, big warmth.")
    }
}

// MARK: - Store

@Observable
final class RippleStore {
    var selectedTab: AppTab = .home
    var inspirationName: String = ""
    var selectedPlace: Place = .campus
    var selectedEnergy: Energy = .okay
    var selectedMinutes: Int = 2
    var currentChallenge: Challenge = generateChallenge(for: .campus, energy: .okay, minutes: 2, salt: 0)
    var reflection: String = ""
    var sentiment: Double = 0
    var keywords: [String] = []
    var acts: [KindAct] = []
    var moodEntries: [MoodEntry] = []
    var dailyReflections: [DailyReflection] = []
    var todayMood: Mood? = nil
    var showOnboarding: Bool = true
    var showChallenge: Bool = false
    var showLogSheet: Bool = false
    var showReflectionSheet: Bool = false
    var showCharacterScore: Bool = false
    var selectedDate: Date? = nil
    var dailyAffirmation: String = dailyAffirmations[0]
    var freezeUsedThisWeek: Bool = false
    var breathingActive: Bool = false
    var breathingPhase: String = "Breathe In"
    var breathingTimer: Int = 4
    var dailyQuote: (text: String, author: String) = (motivationalQuotes[0].0, motivationalQuotes[0].1)

    init() {
        load()
        let day = Calendar.current.component(.day, from: Date())
        dailyAffirmation = dailyAffirmations[day % dailyAffirmations.count]
        dailyQuote = motivationalQuotes[day % motivationalQuotes.count]
    }

    private var saveKey: String { "kindness.ripple.v4" }
    func save() {
        do {
            let data = try JSONEncoder().encode(acts)
            let moodData = try JSONEncoder().encode(moodEntries)
            let reflectionData = try JSONEncoder().encode(dailyReflections)
            UserDefaults.standard.set(data, forKey: saveKey)
            UserDefaults.standard.set(moodData, forKey: saveKey + ".moods")
            UserDefaults.standard.set(reflectionData, forKey: saveKey + ".reflections")
            UserDefaults.standard.set(inspirationName, forKey: saveKey + ".name")
            UserDefaults.standard.set(showOnboarding, forKey: saveKey + ".onboard")
        } catch { }
    }
    func load() {
        if let name = UserDefaults.standard.string(forKey: saveKey + ".name") { inspirationName = name }
        showOnboarding = UserDefaults.standard.bool(forKey: saveKey + ".onboard")
        if UserDefaults.standard.data(forKey: saveKey + ".onboard") == nil { showOnboarding = true }
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([KindAct].self, from: data) { acts = decoded }
        if let moodData = UserDefaults.standard.data(forKey: saveKey + ".moods"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: moodData) {
            moodEntries = decoded
            let cal = Calendar.current
            if let todayEntry = moodEntries.last(where: { cal.isDateInToday($0.date) }) {
                todayMood = todayEntry.mood
            }
        }
        if let reflectionData = UserDefaults.standard.data(forKey: saveKey + ".reflections"),
           let decoded = try? JSONDecoder().decode([DailyReflection].self, from: reflectionData) {
            dailyReflections = decoded
        }
    }

    var totalRipples: Int { acts.reduce(0) { $0 + $1.points } }
    var level: RippleLevel { RippleLevel.level(for: totalRipples) }
    var nextLevelNeed: Int {
        let all = RippleLevel.allCases
        guard let idx = all.firstIndex(where: { $0 == level }), idx + 1 < all.count else { return 0 }
        return all[idx + 1].threshold - totalRipples
    }
    var avgPositivity: Double {
        guard !acts.isEmpty else { return 0 }
        return acts.reduce(0) { $0 + $1.sentiment } / Double(acts.count)
    }
    var gardenBloom: Double { min(1.0, Double(totalRipples) / 300.0) }
    var streakDays: Int {
        guard !acts.isEmpty else { return 0 }
        let cal = Calendar.current
        let days = Set(acts.map { cal.startOfDay(for: $0.date) })
        var count = 0
        var cursor = cal.startOfDay(for: Date())
        if !days.contains(cursor) {
            if let y = cal.date(byAdding: .day, value: -1, to: cursor), days.contains(y), !freezeUsedThisWeek {
                count = 1
            } else { return 0 }
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
            count = 0
            var c2 = cal.startOfDay(for: Date())
            if !days.contains(c2) { c2 = cal.date(byAdding: .day, value: -1, to: c2)! }
            while days.contains(c2) {
                count += 1
                c2 = cal.date(byAdding: .day, value: -1, to: c2)!
                if count > 30 { break }
            }
            return count
        }
        while days.contains(cursor) {
            count += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
            if count > 30 { break }
        }
        return count
    }

    // MARK: - Character Score

    var characterScore: Int {
        var score = 0
        let actCount = min(acts.count, 50)
        score += actCount * 2
        let reflectionCount = min(dailyReflections.count, 30)
        score += reflectionCount * 3
        let goodReflections = dailyReflections.filter { $0.deedType == .good }
        let avgReflectionRating = goodReflections.isEmpty ? 0 : Double(goodReflections.reduce(0) { $0 + $1.rating }) / Double(goodReflections.count)
        score += Int(avgReflectionRating * 2)
        score += min(20, streakDays * 4)
        let moodStreak = calcMoodStreak()
        score += min(15, moodStreak * 2)
        let uniquePlaces = Set(acts.map { $0.place }).count
        score += uniquePlaces * 3
        let avgSentiment = avgPositivity
        score += Int(avgSentiment * 15)
        if actCount >= 5 { score += 5 }
        if actCount >= 20 { score += 10 }
        if actCount >= 50 { score += 15 }
        return max(0, min(100, score))
    }

    var characterScoreGrade: String {
        switch characterScore {
        case 0..<20: return "Seeker"
        case 20..<40: return "Growing"
        case 40..<60: return "Kind Soul"
        case 60..<80: return "Beacon"
        case 80...100: return "Luminary"
        default: return "Seeker"
        }
    }

    var characterScoreColor: Color {
        switch characterScore {
        case 0..<20: return PastelTheme.skyBlue
        case 20..<40: return PastelTheme.mint
        case 40..<60: return PastelTheme.buttercup
        case 60..<80: return PastelTheme.peach
        case 80...100: return PastelTheme.lavender
        default: return PastelTheme.skyBlue
        }
    }

    var moralBalance: (good: Double, improve: Double) {
        let good = dailyReflections.filter { $0.deedType == .good }.count
        let improve = dailyReflections.filter { $0.deedType == .reflect }.count
        let total = Double(max(1, good + improve))
        return (Double(good) / total, Double(improve) / total)
    }

    var badges: [(BadgeDef, Bool)] {
        let defs = [
            BadgeDef(name: "First Light", detail: "Log your first act", icon: "sunrise.fill"),
            BadgeDef(name: "Warm Heart", detail: "Avg warmth above 0.5", icon: "heart.fill"),
            BadgeDef(name: "Streak 3", detail: "3 days in a row", icon: "flame.fill"),
            BadgeDef(name: "Explorer", detail: "Try 3 different places", icon: "map.fill"),
            BadgeDef(name: "Deep Reflector", detail: "Write 80+ char reflection", icon: "pencil.and.scribble"),
            BadgeDef(name: "Ocean Bound", detail: "Reach 300 points", icon: "water.waves"),
            BadgeDef(name: "Mood Master", detail: "Log mood 7 days in a row", icon: "face.smiling.fill"),
            BadgeDef(name: "Ripple Legend", detail: "Reach 500 points", icon: "star.fill")
        ]
        let places = Set(acts.map { $0.place }).count
        let hasLong = acts.contains { $0.reflection.count >= 80 }
        let moodStreak = calcMoodStreak()
        let earned: [Bool] = [
            !acts.isEmpty,
            avgPositivity > 0.5 && acts.count >= 2,
            streakDays >= 3,
            places >= 3,
            hasLong,
            totalRipples >= 300,
            moodStreak >= 7,
            totalRipples >= 500
        ]
        return Array(zip(defs, earned))
    }
    var happinessSeries: [DayPoint] {
        let cal = Calendar.current
        var out: [DayPoint] = []
        let fmt = DateFormatter()
        fmt.dateFormat = "E"
        for i in (0..<7).reversed() {
            let d = cal.date(byAdding: .day, value: -i, to: Date())!
            let dayActs = acts.filter { cal.isDate($0.date, inSameDayAs: d) }
            out.append(DayPoint(label: i == 0 ? "Today" : fmt.string(from: d), count: dayActs.count, happiness: dayActs.reduce(0) { $0 + Double($1.points) }))
        }
        return out
    }
    var weeklySummary: String {
        guard !acts.isEmpty else { return "Your garden is waiting for its first seed." }
        let top = acts.sorted { $0.points > $1.points }.first!
        return "Top ripple: \(top.title) (+\(top.points)). Avg warmth \(String(format: "%.2f", avgPositivity)). Keep the \(level.title.lowercased()) growing."
    }
    func calcMoodStreak() -> Int {
        let cal = Calendar.current
        let moodDays = Set(moodEntries.map { cal.startOfDay(for: $0.date) })
        var count = 0
        var cursor = cal.startOfDay(for: Date())
        while moodDays.contains(cursor) {
            count += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
            if count > 60 { break }
        }
        return count
    }
    func refreshChallenge() {
        currentChallenge = generateChallenge(for: selectedPlace, energy: selectedEnergy, minutes: selectedMinutes, salt: acts.count + 1)
    }
    func updateSentiment() {
        sentiment = analyzeSentiment(reflection)
        keywords = extractKeywords(reflection)
    }
    func logCurrentAct() {
        let pts = max(10, Int(20 + sentiment * 40) + currentChallenge.ripplePoints / 2)
        acts.append(KindAct(title: currentChallenge.title, place: selectedPlace, energy: selectedEnergy, reflection: reflection, sentiment: sentiment, keywords: keywords, date: Date(), points: pts, minutes: currentChallenge.minutes))
        reflection = ""; sentiment = 0; keywords = []
        refreshChallenge()
        showLogSheet = false
        save()
    }
    func logMood(_ mood: Mood, note: String) {
        let cal = Calendar.current
        moodEntries.removeAll { cal.isDate($0.date, inSameDayAs: Date()) }
        moodEntries.append(MoodEntry(mood: mood, note: note, date: Date()))
        todayMood = mood
        save()
    }
    func logDailyReflection(_ text: String, type: DeedType) {
        let result = rateDailyReflection(text, type: type)
        let reflection = DailyReflection(text: text, deedType: type, rating: result.rating, characterPoints: result.points, date: Date(), tags: result.tags)
        dailyReflections.append(reflection)
        save()
    }
    func simulateJudgeExperience() {
        let cal = Calendar.current
        let samples: [(String, Place, Energy, String, Double, Int, Int, Int)] = [
            ("Hold the door", .campus, .okay, "I held the door for a classmate today and they smiled, which made my morning feel much brighter!", 0.85, 3, 28, 2),
            ("Offer your seat", .transit, .low, "Gave my seat to an elderly man, he was so grateful and we chatted happily.", 0.9, 2, 30, 2),
            ("Thank-you text", .home, .low, "Texted mom thanking her for always packing lunch, she sent hearts back. I feel loved.", 0.95, 1, 32, 1),
            ("Sidewalk gift", .neighborhood, .okay, "Picked up litter on our street, a neighbor waved. Small but good.", 0.6, 1, 22, 4),
            ("Kind comment", .digital, .bright, "Left a kind comment on a friend's art. They said it made their day and I felt proud!", 0.8, 0, 27, 2)
        ]
        acts = samples.map { t, p, e, r, s, ago, pts, mins in
            KindAct(title: t, place: p, energy: e, reflection: r, sentiment: s, keywords: extractKeywords(r), date: cal.date(byAdding: .day, value: -ago, to: Date())!, points: pts, minutes: mins)
        }
        let moods: [Mood] = [.amazing, .happy, .calm, .happy, .amazing]
        for (i, mood) in moods.enumerated() {
            if let d = cal.date(byAdding: .day, value: -i, to: Date()) {
                moodEntries.append(MoodEntry(mood: mood, note: "Demo day", date: d))
            }
        }
        todayMood = .amazing
        if inspirationName.isEmpty { inspirationName = "Maya" }
        selectedPlace = .campus; selectedEnergy = .okay; selectedMinutes = 2
        dailyReflections = [
            DailyReflection(text: "Helped my neighbor carry groceries to their door. They were struggling and it felt great to assist.", deedType: .good, rating: 8, characterPoints: 24, date: cal.date(byAdding: .day, value: -1, to: Date())!, tags: ["neighbor", "help"]),
            DailyReflection(text: "I was impatient with my younger sibling today. Next time I will take a breath and be more understanding.", deedType: .reflect, rating: 6, characterPoints: 12, date: cal.date(byAdding: .day, value: -2, to: Date())!, tags: ["patience", "family"]),
            DailyReflection(text: "Volunteered at the local food bank for 2 hours. Met wonderful people and helped prepare 50 meal packages.", deedType: .good, rating: 9, characterPoints: 27, date: cal.date(byAdding: .day, value: -3, to: Date())!, tags: ["volunteer", "community"]),
            DailyReflection(text: "Left a genuine compliment for a stranger at the coffee shop. Their smile made my day.", deedType: .good, rating: 7, characterPoints: 21, date: cal.date(byAdding: .day, value: -4, to: Date())!, tags: ["kindness", "stranger"])
        ]
        refreshChallenge()
        showOnboarding = false
        save()
    }
    func resetAll() {
        acts = []; moodEntries = []; dailyReflections = []; todayMood = nil; freezeUsedThisWeek = false; save()
        refreshChallenge()
    }
}

// MARK: - Root

struct ContentView: View {
    @State private var store = RippleStore()
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [PastelTheme.backgroundTop, PastelTheme.backgroundBottom, Color(red: 0.92, green: 0.85, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if store.showOnboarding {
                OnboardingView(store: store)
            } else {
                MainTabView(store: store)
            }
        }
        .tint(PastelTheme.lavender)
    }
}

// MARK: - Onboarding

struct OnboardingView: View {
    var store: RippleStore
    @State private var step = 0
    @State private var name = ""
    @State private var animate = false
    var body: some View {
        ZStack {
            if step == 0 {
                VStack(spacing: 28) {
                    Spacer()
                    ZStack {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [PastelTheme.softPink.opacity(0.4 - Double(i) * 0.08), PastelTheme.lavender.opacity(0.25 - Double(i) * 0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: 100 + CGFloat(i) * 45, height: 100 + CGFloat(i) * 45)
                                .scaleEffect(animate ? 1.06 : 0.94)
                                .animation(.easeInOut(duration: 2.8).repeatForever().delay(Double(i) * 0.35), value: animate)
                        }
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: [PastelTheme.softPink.opacity(0.3), PastelTheme.lilac.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 80, height: 80)
                            Image(systemName: "bolt.heart.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(
                                    LinearGradient(colors: [PastelTheme.softPink, PastelTheme.softPink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: PastelTheme.softPink.opacity(0.6), radius: 20)
                        }
                    }
                    .frame(height: 220)
                    VStack(spacing: 8) {
                        Text("Kindness Ripple")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Small acts. Big ripples.")
                            .font(.title3.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(red: 0.45, green: 0.38, blue: 0.6))
                    }
                    Text("Track your kindness journey.\nAll offline. All yours.")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .multilineTextAlignment(.center)
                    Button {
                        step = 1
                    } label: {
                        HStack(spacing: 8) {
                            Text("Get Started")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: PastelTheme.lavender.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 32)
                    Button {
                        store.simulateJudgeExperience()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                            Text("Try with demo data")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Color(red: 0.45, green: 0.38, blue: 0.6))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .stroke(Color(red: 0.45, green: 0.38, blue: 0.6).opacity(0.3), lineWidth: 1)
                        )
                    }
                    Spacer()
                }
                .onAppear { animate = true }
            } else {
                VStack(spacing: 24) {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [PastelTheme.lavender.opacity(0.2), PastelTheme.softPink.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(PastelTheme.lavender)
                    }
                    VStack(spacing: 6) {
                        Text("What's your name?")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color(red: 0.35, green: 0.28, blue: 0.55))
                        Text("We'll use this to personalize your experience")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    TextField("Your name", text: $name)
                        .textFieldStyle(.plain)
                        .font(.title3)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.5), lineWidth: 1))
                        .padding(.horizontal, 32)
                    if !name.isEmpty {
                        Text("Welcome, \(name)! Let's spread some kindness together.")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                            .transition(.opacity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    Button {
                        store.inspirationName = name
                        store.showOnboarding = false
                        store.save()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start My Journey")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: PastelTheme.lavender.opacity(0.4), radius: 12, y: 6)
                    }
                    .disabled(name.isEmpty)
                    .padding(.horizontal, 32)
                    Button {
                        store.inspirationName = name
                        store.showOnboarding = false
                        store.save()
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    }
                    Spacer()
                }
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(), value: step)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Bindable var store: RippleStore
    var body: some View {
        VStack(spacing: 0) {
            HeaderBar(store: store)
            TabView(selection: $store.selectedTab) {
                HomeView(store: store).tag(AppTab.home)
                JournalView(store: store).tag(AppTab.journal)
                DashboardView(store: store).tag(AppTab.dashboard)
                BreatheView(store: store).tag(AppTab.breathe)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            BottomBar(store: store)
        }
    }
}

struct HeaderBar: View {
    var store: RippleStore
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Text(store.inspirationName.isEmpty ? "Kindness Ripple" : store.inspirationName)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
            }
            Spacer()
            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: store.level.icon)
                        .font(.caption)
                        .foregroundStyle(PastelTheme.lavender)
                    Text("\(store.totalRipples)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.35, green: 0.28, blue: 0.55))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
    var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Sweet Dreams"
        }
    }
}

struct BottomBar: View {
    var store: RippleStore
    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "Home", icon: "house.fill", tab: .home, store: store)
            TabButton(title: "Journal", icon: "book.fill", tab: .journal, store: store)
            TabButton(title: "Dashboard", icon: "chart.bar.fill", tab: .dashboard, store: store)
            TabButton(title: "Breathe", icon: "wind", tab: .breathe, store: store)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(
            VStack(spacing: 0) {
                LinearGradient(colors: [.clear, PastelTheme.softPink.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 1)
                Rectangle()
                    .fill(.ultraThinMaterial)
            }
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let tab: AppTab
    var store: RippleStore
    var isSelected: Bool { store.selectedTab == tab }
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                store.selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(PastelTheme.lavender.opacity(0.2))
                            .frame(width: 36, height: 36)
                    }
                    Image(systemName: icon)
                        .font(.subheadline)
                }
                .frame(height: 36)
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(isSelected ? Color(red: 0.4, green: 0.3, blue: 0.65) : Color(red: 0.6, green: 0.55, blue: 0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Home View

struct HomeView: View {
    @Bindable var store: RippleStore
    @State private var showMoodPicker = false
    @State private var showChallenge = false
    @State private var showReflection = false
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CharacterScoreCard(store: store)
                AffirmationCard(store: store)
                MoodCard(store: store, showMoodPicker: $showMoodPicker)
                MotivationalQuoteCard(store: store)
                QuickActions(store: store, showChallenge: $showChallenge, showReflection: $showReflection)
                DailyChallengeCard(store: store)
                CommunityCard(store: store)
                RecentRipples(store: store)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showMoodPicker) {
            MoodPickerSheet(store: store)
        }
        .sheet(isPresented: $showChallenge) {
            ChallengeSheet(store: store)
        }
        .sheet(isPresented: $showReflection) {
            DailyReflectionSheet(store: store)
        }
        .fullScreenCover(isPresented: $store.showLogSheet) {
            LogSheet(store: store)
        }
    }
}

struct AffirmationCard: View {
    var store: RippleStore
    @State private var animate = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.caption)
                            .foregroundStyle(PastelTheme.softPink)
                        Text("Daily Affirmation")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    }
                    Text(store.dailyAffirmation)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [PastelTheme.buttercup.opacity(0.3), PastelTheme.softPink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "quote.opening")
                        .font(.title2)
                        .foregroundStyle(PastelTheme.softPink.opacity(0.7))
                        .scaleEffect(animate ? 1.05 : 0.95)
                }
            }
            .padding(18)
            .padding(.top, 4)
        }
        .background(
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.55)
                Circle()
                    .fill(PastelTheme.buttercup.opacity(0.06))
                    .frame(width: 100, height: 100)
                    .offset(x: 15, y: 15)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .onAppear { animate = true }
    }
}

struct MoodCard: View {
    var store: RippleStore
    @Binding var showMoodPicker: Bool
    var body: some View {
        Button {
            showMoodPicker = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: store.todayMood != nil
                                    ? [store.todayMood!.color.opacity(0.3), store.todayMood!.color.opacity(0.1)]
                                    : [PastelTheme.softPink.opacity(0.3), PastelTheme.softPink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    Image(systemName: store.todayMood?.icon ?? "face.smiling")
                        .font(.title2)
                        .foregroundStyle(store.todayMood?.color ?? PastelTheme.softPink)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Today's Mood")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    if let mood = store.todayMood {
                        Text(mood.rawValue)
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    } else {
                        Text("How are you feeling?")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    Text(store.todayMood != nil ? "Change" : "Log")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                }
            }
            .padding(16)
            .glassCard(cornerRadius: 20)
        }
    }
}

struct QuickActions: View {
    var store: RippleStore
    @Binding var showChallenge: Bool
    @Binding var showReflection: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.peach)
                Text("Quick Start")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    QuickActionTile(
                        title: "Daily Reflection",
                        subtitle: "Rate your day",
                        icon: "character.book.closed.fill",
                        color: PastelTheme.buttercup
                    ) {
                        showReflection = true
                    }
                    QuickActionTile(
                        title: "New Challenge",
                        subtitle: "Get inspired",
                        icon: "bolt.and.sparkles.fill",
                        color: PastelTheme.softPink
                    ) {
                        showChallenge = true
                    }
                    QuickActionTile(
                        title: "Log Kindness",
                        subtitle: "Write it down",
                        icon: "pencil.and.scribble",
                        color: PastelTheme.softPink
                    ) {
                        store.showLogSheet = true
                    }
                    QuickActionTile(
                        title: "Garden",
                        subtitle: "See your bloom",
                        icon: "leaf.fill",
                        color: PastelTheme.mint
                    ) {
                        store.selectedTab = .dashboard
                    }
                    QuickActionTile(
                        title: "Breathe",
                        subtitle: "Calm down",
                        icon: "wind",
                        color: PastelTheme.skyBlue
                    ) {
                        store.selectedTab = .breathe
                    }
                }
            }
        }
    }
}

struct QuickActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
            .frame(width: 115, height: 100, alignment: .topLeading)
            .padding(14)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .opacity(0.55)
                    Circle()
                        .fill(color.opacity(0.08))
                        .frame(width: 40, height: 40)
                        .offset(x: -5, y: -5)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct DailyChallengeCard: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [PastelTheme.softPink.opacity(0.3), PastelTheme.lavender.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "bolt.heart.fill")
                        .font(.subheadline)
                        .foregroundStyle(PastelTheme.softPink)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Today's Challenge")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    Text("\(store.currentChallenge.minutes) min · +\(store.currentChallenge.ripplePoints) pts")
                        .font(.caption2)
                        .foregroundStyle(PastelTheme.lavender)
                }
                Spacer()
                Button {
                    store.refreshChallenge()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial.opacity(0.6))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 1))
                }
            }
            Divider()
                .overlay(Color.white.opacity(0.3))
            VStack(alignment: .leading, spacing: 6) {
                Text(store.currentChallenge.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                Text(store.currentChallenge.detail)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button {
                store.showLogSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.subheadline)
                    Text("Do This Challenge")
                        .font(.subheadline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: PastelTheme.lavender.opacity(0.3), radius: 8, y: 4)
            }
        }
        .padding(18)
        .background(
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.55)
                Circle()
                    .fill(PastelTheme.softPink.opacity(0.06))
                    .frame(width: 80, height: 80)
                    .offset(x: -15, y: 15)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

struct RecentRipples: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "water.waves")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.skyBlue)
                Text("Recent Ripples")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            if store.acts.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(PastelTheme.mint.opacity(0.2 - Double(i) * 0.05), lineWidth: 1.5)
                                .frame(width: 60 + CGFloat(i) * 20, height: 60 + CGFloat(i) * 20)
                        }
                        Image(systemName: "leaf.circle.dashed")
                            .font(.system(size: 36))
                            .foregroundStyle(PastelTheme.mint)
                    }
                    VStack(spacing: 4) {
                        Text("Your garden awaits")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        Text("Complete your first challenge\nto plant a seed of kindness")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .glassCard()
            } else {
                ForEach(store.acts.suffix(3).reversed()) { act in
                    RippleRow(act: act)
                }
            }
        }
    }
}

struct RippleRow: View {
    let act: KindAct
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(act.place.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: act.place.icon)
                    .font(.subheadline)
                    .foregroundStyle(act.place.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(act.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                HStack(spacing: 4) {
                    Text(act.place.rawValue)
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    Circle()
                        .fill(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .frame(width: 3, height: 3)
                    Text(act.date.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(PastelTheme.buttercup)
                    Text("+\(act.points)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(PastelTheme.buttercup)
                }
                SentimentBadge(score: act.sentiment)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Mood Picker

struct MoodPickerSheet: View {
    var store: RippleStore
    @Environment(\.dismiss) var dismiss
    @State private var note = ""
    @State private var selectedMood: Mood? = nil
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("How are you feeling right now?")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Text("Select the mood that best describes your current state")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                HStack(spacing: 14) {
                    ForEach(Mood.allCases) { mood in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMood = mood
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(selectedMood == mood
                                            ? LinearGradient(colors: [mood.color.opacity(0.4), mood.color.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: mood.icon)
                                        .font(.title2)
                                        .foregroundStyle(mood.color)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(selectedMood == mood ? mood.color : Color(red: 0.55, green: 0.48, blue: 0.7).opacity(0.2), lineWidth: selectedMood == mood ? 2 : 1)
                                )
                                Text(mood.rawValue)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                            }
                        }
                        .scaleEffect(selectedMood == mood ? 1.1 : 1.0)
                    }
                }
                TextField("Add a note (optional)", text: $note)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(PastelTheme.softPink.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, 20)
                Button {
                    if let mood = selectedMood {
                        store.logMood(mood, note: note)
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                        Text("Save Mood")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [PastelTheme.softPink, PastelTheme.lavender], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedMood == nil)
                .padding(.horizontal, 20)
                Spacer()
            }
            .background(PastelTheme.backgroundTop.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
        }
    }
}

// MARK: - Challenge Sheet

struct ChallengeSheet: View {
    var store: RippleStore
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose Your Context")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        .padding(.top, 10)
                    Text("Place")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(Place.allCases) { p in
                                Button {
                                    store.selectedPlace = p
                                    store.refreshChallenge()
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: p.icon)
                                            .font(.title3)
                                        Text(p.rawValue)
                                            .font(.caption.weight(.bold))
                                    }
                                    .foregroundStyle(store.selectedPlace == p ? .white : Color(red: 0.5, green: 0.43, blue: 0.65))
                                    .frame(width: 90, height: 76)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(store.selectedPlace == p ? p.color : Color.white.opacity(0.15))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(store.selectedPlace == p ? p.color : .white.opacity(0.3), lineWidth: 1.5)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    Text("Energy")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    HStack(spacing: 10) {
                        ForEach(Energy.allCases) { e in
                            Button {
                                store.selectedEnergy = e
                                store.refreshChallenge()
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: e.icon)
                                    Text(e.rawValue)
                                        .font(.caption.weight(.bold))
                                    Text(e.hint)
                                        .font(.caption2)
                                        .opacity(0.7)
                                }
                                .foregroundStyle(store.selectedEnergy == e ? .white : Color(red: 0.5, green: 0.43, blue: 0.65))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(store.selectedEnergy == e ? e.color : Color.white.opacity(0.15))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Challenge")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        Text(store.currentChallenge.title)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        Text(store.currentChallenge.detail)
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        HStack {
                            Label("\(store.currentChallenge.minutes) min", systemImage: "clock")
                            Spacer()
                            Label("+\(store.currentChallenge.ripplePoints) pts", systemImage: "star.fill")
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(PastelTheme.lavender)
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 20)
                    Button {
                        store.showLogSheet = true
                        dismiss()
                    } label: {
                        Label("Do This Kindness", systemImage: "heart.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .background(PastelTheme.backgroundTop.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
        }
    }
}

// MARK: - Character Score Card

struct CharacterScoreCard: View {
    var store: RippleStore
    @State private var animate = false
    @State private var showDetail = false
    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill.checkmark")
                                .font(.caption)
                                .foregroundStyle(store.characterScoreColor)
                            Text("Character Score")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(store.characterScore)")
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(colors: [store.characterScoreColor, store.characterScoreColor.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                )
                                .contentTransition(.numericText())
                            Text("/100")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                        Text(store.characterScoreGrade)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(store.characterScoreColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(store.characterScoreColor.opacity(0.2))
                            )
                    }
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                            .frame(width: 70, height: 70)
                        Circle()
                            .trim(from: 0, to: animate ? CGFloat(store.characterScore) / 100.0 : 0)
                            .stroke(
                                AngularGradient(colors: [store.characterScoreColor.opacity(0.6), store.characterScoreColor, store.characterScoreColor.opacity(0.6)], center: .center),
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.5, dampingFraction: 0.8).delay(0.3), value: animate)
                        VStack(spacing: 1) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(store.characterScoreColor)
                            Text("Score")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                    }
                }
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.3.fill")
                            .font(.caption2)
                            .foregroundStyle(PastelTheme.softPink)
                        Text("\(store.acts.count) acts")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(PastelTheme.peach)
                        Text("\(store.streakDays)d streak")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling.fill")
                            .font(.caption2)
                            .foregroundStyle(PastelTheme.mint)
                        Text("\(store.dailyReflections.count) reflections")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
                .padding(.top, 14)
            }
            .padding(18)
            .background(
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.55)
                    Circle()
                        .fill(store.characterScoreColor.opacity(0.08))
                        .frame(width: 90, height: 90)
                        .offset(x: 15, y: 15)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: store.characterScoreColor.opacity(0.15), radius: 12, y: 4)
        }
        .onAppear { animate = true }
        .sheet(isPresented: $showDetail) {
            CharacterScoreDetailSheet(store: store)
        }
    }
}

// MARK: - Character Score Detail Sheet

struct CharacterScoreDetailSheet: View {
    var store: RippleStore
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 160, height: 160)
                        Circle()
                            .trim(from: 0, to: CGFloat(store.characterScore) / 100.0)
                            .stroke(
                                AngularGradient(colors: [store.characterScoreColor.opacity(0.6), store.characterScoreColor, store.characterScoreColor.opacity(0.6)], center: .center),
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 4) {
                            Text("\(store.characterScore)")
                                .font(.system(size: 56, weight: .heavy, design: .rounded))
                                .foregroundStyle(store.characterScoreColor)
                            Text(store.characterScoreGrade)
                                .font(.headline)
                                .foregroundStyle(store.characterScoreColor)
                        }
                    }
                    .padding(.top, 20)
                    Text("This score reflects your journey of becoming a better person.\nEvery act of kindness, every reflection, every step forward counts.")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    VStack(spacing: 12) {
                        ScoreBreakdownRow(icon: "heart.fill", label: "Kind Acts", value: "\(store.acts.count)", color: PastelTheme.softPink, detail: "\(min(store.acts.count, 50) * 2) pts")
                        ScoreBreakdownRow(icon: "character.book.closed.fill", label: "Daily Reflections", value: "\(store.dailyReflections.count)", color: PastelTheme.buttercup, detail: "\(min(store.dailyReflections.count, 30) * 3) pts")
                        ScoreBreakdownRow(icon: "flame.fill", label: "Consistency Streak", value: "\(store.streakDays) days", color: PastelTheme.peach, detail: "\(min(store.streakDays * 4, 20)) pts")
                        ScoreBreakdownRow(icon: "face.smiling.fill", label: "Mood Tracking", value: "\(store.moodEntries.count) entries", color: PastelTheme.mint, detail: "\(min(store.calcMoodStreak() * 2, 15)) pts")
                        ScoreBreakdownRow(icon: "mappin.and.ellipse", label: "Places Explored", value: "\(Set(store.acts.map { $0.place }).count)", color: PastelTheme.skyBlue, detail: "\(Set(store.acts.map { $0.place }).count * 3) pts")
                        ScoreBreakdownRow(icon: "sparkles", label: "Warmth Rating", value: String(format: "%.1f", store.avgPositivity), color: PastelTheme.lilac, detail: "\(Int(store.avgPositivity * 15)) pts")
                    }
                    .padding(.horizontal, 20)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to increase your score:")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        TipRow(icon: "hand.raised.fill", text: "Complete kindness challenges")
                        TipRow(icon: "pencil.and.scribble", text: "Write daily reflections about your deeds")
                        TipRow(icon: "face.smiling", text: "Track your mood every day")
                        TipRow(icon: "flame", text: "Maintain your daily streak")
                        TipRow(icon: "mappin", text: "Try acts in different places")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .scrollIndicators(.hidden)
            .background(PastelTheme.backgroundTop.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
        }
    }
}

struct ScoreBreakdownRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let detail: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                Text(value)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
            }
            Spacer()
            Text(detail)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(PastelTheme.mint)
                .frame(width: 24)
            Text(text)
                .font(.caption)
                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
        }
    }
}

// MARK: - Motivational Quote Card

struct MotivationalQuoteCard: View {
    var store: RippleStore
    @State private var animate = false
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.caption)
                            .foregroundStyle(PastelTheme.lilac)
                        Text("Daily Inspiration")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    }
                    Text(store.dailyQuote.text)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("— \(store.dailyQuote.author)")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .italic()
                }
                Spacer()
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(PastelTheme.lilac.opacity(0.15 - Double(i) * 0.04), lineWidth: 1)
                            .frame(width: 30 + CGFloat(i) * 12, height: 30 + CGFloat(i) * 12)
                            .offset(x: 12, y: 12)
                    }
                    Image(systemName: "lightbulb.max.fill")
                        .font(.caption)
                        .foregroundStyle(PastelTheme.buttercup.opacity(0.7))
                }
            }
            .padding(16)
        }
        .background(
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                Circle()
                    .fill(PastelTheme.lilac.opacity(0.06))
                    .frame(width: 70, height: 70)
                    .offset(x: -10, y: -10)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Daily Reflection Sheet

struct DailyReflectionSheet: View {
    var store: RippleStore
    @Environment(\.dismiss) var dismiss
    @State private var reflectionText = ""
    @State private var deedType: DeedType = .good
    @State private var ratingResult: (rating: Int, points: Int, tags: [String]) = (0, 0, [])
    @State private var showResult = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            ForEach(DeedType.allCases) { type in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        deedType = type
                                        showResult = false
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: type.icon)
                                            .font(.subheadline)
                                        Text(type.rawValue)
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .foregroundStyle(deedType == type ? .white : Color(red: 0.5, green: 0.43, blue: 0.65))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(deedType == type
                                                ? LinearGradient(colors: [type.color, type.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                                                : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(deedType == type ? Color.clear : .white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        Text(deedType == .good ? "What good deed did you do today?" : "What's something you want to improve on?")
                            .font(.headline)
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        Text(deedType == .good ? "Be specific! The more detail you share, the better your rating." : "Reflecting on areas to improve shows great self-awareness. That's already a positive step!")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        TextEditor(text: $reflectionText)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.4), lineWidth: 1))
                            .onChange(of: reflectionText) { _, _ in
                                showResult = false
                            }
                        HStack {
                            Image(systemName: "text.badge.checkmark")
                                .font(.caption)
                                .foregroundStyle(PastelTheme.mint)
                            Text("\(reflectionText.split(separator: " ").count) words")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    if showResult {
                        VStack(spacing: 14) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(PastelTheme.buttercup)
                                Text("Rating: \(ratingResult.rating)/10")
                                    .font(.headline)
                                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                                Spacer()
                                HStack(spacing: 2) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(PastelTheme.mint)
                                    Text("+\(ratingResult.points) character pts")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(PastelTheme.mint)
                                }
                            }
                            if !ratingResult.tags.isEmpty {
                                HStack {
                                    ForEach(ratingResult.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.caption2.weight(.bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(PastelTheme.softPink.opacity(0.2))
                                            .foregroundStyle(PastelTheme.softPink)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            Text(ratingResult.rating >= 7 ? "Wonderful! Your kindness is making a real difference." : ratingResult.rating >= 4 ? "Good reflection! Every step forward matters." : "Self-awareness is the first step to growth. Keep going!")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                                .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .glassCard(cornerRadius: 18)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    Button {
                        ratingResult = rateDailyReflection(reflectionText, type: deedType)
                        withAnimation { showResult = true }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.subheadline)
                            Text(showResult ? "Rate Again" : "Rate My Day")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(reflectionText.trimmingCharacters(in: .whitespaces).isEmpty
                                    ? AnyShapeStyle(Color.gray)
                                    : AnyShapeStyle(LinearGradient(colors: [deedType.color, deedType.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)))
                        )
                        .shadow(color: reflectionText.trimmingCharacters(in: .whitespaces).isEmpty ? .clear : deedType.color.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(reflectionText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 20)
                    if showResult {
                        Button {
                            store.logDailyReflection(reflectionText, type: deedType)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.subheadline)
                                Text("Save Reflection")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [PastelTheme.mint, PastelTheme.skyBlue], startPoint: .leading, endPoint: .trailing))
                            )
                            .shadow(color: PastelTheme.mint.opacity(0.3), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(PastelTheme.backgroundTop.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
        }
    }
}

// MARK: - Moral Compass View

struct MoralCompassView: View {
    var store: RippleStore
    @State private var animate = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "safari")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.rose)
                Text("Moral Compass")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            if store.dailyReflections.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "safari")
                        .font(.title2)
                        .foregroundStyle(PastelTheme.rose.opacity(0.5))
                    Text("Start logging reflections to see your moral compass")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                let balance = store.moralBalance
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 120, height: 120)
                        Circle()
                            .trim(from: 0, to: animate ? CGFloat(balance.good) : 0)
                            .stroke(PastelTheme.mint, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.2), value: animate)
                        Circle()
                            .trim(from: animate ? CGFloat(balance.good) : 0, to: 1)
                            .stroke(PastelTheme.peach.opacity(0.5), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 1.2, dampingFraction: 0.8).delay(0.4), value: animate)
                        VStack(spacing: 2) {
                            Image(systemName: "safari")
                                .font(.title3)
                                .foregroundStyle(PastelTheme.rose)
                            Text("Balance")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                    }
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Circle().fill(PastelTheme.mint).frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("Good Deeds")
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                                Text("\(Int(balance.good * 100))%")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(PastelTheme.mint)
                            }
                        }
                        HStack(spacing: 6) {
                            Circle().fill(PastelTheme.peach).frame(width: 10, height: 10)
                            VStack(alignment: .leading, spacing: 1) {
                                Text("To Improve")
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                                Text("\(Int(balance.improve * 100))%")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(PastelTheme.peach)
                            }
                        }
                    }
                    Text("Reflecting on both strengths and areas for growth shows true character development.")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                Circle()
                    .fill(PastelTheme.rose.opacity(0.06))
                    .frame(width: 60, height: 60)
                    .offset(x: 10, y: 10)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .onAppear { animate = true }
    }
}

// MARK: - Reflection History Card

struct ReflectionHistoryCard: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.skyBlue)
                Text("Recent Reflections")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            if store.dailyReflections.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "character.book.closed")
                        .font(.title2)
                        .foregroundStyle(PastelTheme.buttercup.opacity(0.5))
                    Text("Your reflections will appear here")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(store.dailyReflections.suffix(4).reversed()) { ref in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(ref.deedType.color.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: ref.deedType.icon)
                                .font(.caption)
                                .foregroundStyle(ref.deedType.color)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ref.text)
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                                .lineLimit(2)
                            Text(ref.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(PastelTheme.buttercup)
                                Text("\(ref.rating)/10")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(PastelTheme.buttercup)
                            }
                            Text("+\(ref.characterPoints)")
                                .font(.caption2)
                                .foregroundStyle(PastelTheme.mint)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .opacity(0.35)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - People Illustrations

struct PeopleIllustrationView: View {
    @State private var animate = false
    var size: CGFloat = 100
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.28))
                    .foregroundStyle(
                        [PastelTheme.lavender, PastelTheme.softPink, PastelTheme.mint, PastelTheme.skyBlue, PastelTheme.buttercup][i]
                    )
                    .offset(
                        x: cos(Double(i) * 1.26) * size * 0.3,
                        y: sin(Double(i) * 1.26) * size * 0.25
                    )
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2.5).repeatForever().delay(Double(i) * 0.15), value: animate)
            }
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.18))
                .foregroundStyle(PastelTheme.softPink)
                .opacity(animate ? 1 : 0.6)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: animate)
        }
        .frame(width: size, height: size)
        .onAppear { animate = true }
    }
}

struct CommunityCard: View {
    var store: RippleStore
    @State private var animate = false
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "person.3.fill")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.lavender)
                Text("Community Spirit")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            HStack(spacing: 16) {
                PeopleIllustrationView(size: 80)
                VStack(alignment: .leading, spacing: 6) {
                    Text("You're part of something bigger")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Text("Every kindness ripple you create inspires others. Together, we make the world a warmer place.")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundStyle(PastelTheme.lavender)
                            Text("You")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        }
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        HStack(spacing: 3) {
                            Image(systemName: "person.3.fill")
                                .font(.caption2)
                                .foregroundStyle(PastelTheme.softPink)
                            Text("Others")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        }
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        HStack(spacing: 3) {
                            Image(systemName: "globe")
                                .font(.caption2)
                                .foregroundStyle(PastelTheme.mint)
                            Text("World")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
                Circle()
                    .fill(PastelTheme.lavender.opacity(0.06))
                    .frame(width: 70, height: 70)
                    .offset(x: -10, y: 10)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.6), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Log Sheet

struct LogSheet: View {
    @Bindable var store: RippleStore
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .font(.title2)
                                .foregroundStyle(PastelTheme.softPink)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(store.currentChallenge.title)
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                                Text("\(store.currentChallenge.minutes) min · +\(store.currentChallenge.ripplePoints) pts")
                                    .font(.caption)
                                    .foregroundStyle(PastelTheme.lavender)
                            }
                        }
                        Text(store.currentChallenge.detail)
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 20)

                    SentimentBloomView(score: store.sentiment)
                        .frame(height: 180)
                        .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("How did it feel?")
                                .font(.headline)
                                .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                            Spacer()
                            SentimentBadge(score: store.sentiment)
                        }
                        TextEditor(text: $store.reflection)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.4), lineWidth: 1))
                            .onChange(of: store.reflection) { _, _ in store.updateSentiment() }
                        if !store.keywords.isEmpty {
                            HStack {
                                ForEach(store.keywords, id: \.self) { k in
                                    Text("#\(k)")
                                        .font(.caption.weight(.bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(PastelTheme.softPink.opacity(0.2))
                                        .foregroundStyle(PastelTheme.softPink)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        Text("Try: \"I held the door for a classmate and they smiled, which made my morning brighter!\"")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                            .italic()
                    }
                    .padding(18)
                    .glassCard()
                    .padding(.horizontal, 20)

                    Button {
                        store.logCurrentAct()
                        dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.subheadline)
                            Text("Complete Ripple")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(store.reflection.trimmingCharacters(in: .whitespaces).isEmpty ?
                                      AnyShapeStyle(Color.gray) :
                                      AnyShapeStyle(LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)))
                        )
                        .shadow(color: store.reflection.trimmingCharacters(in: .whitespaces).isEmpty ? .clear : PastelTheme.lavender.opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(store.reflection.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(PastelTheme.backgroundTop.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
        }
    }
}

// MARK: - Sentiment Bloom

struct SentimentBloomView: View {
    var score: Double
    var t: Double { max(0, min(1, (score + 1) / 2)) }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var shimmer = false
    var mood: String {
        switch score {
        case 0.6...: "Radiant"
        case 0.2..<0.6: "Warming"
        case -0.2..<0.2: "Neutral"
        default: "Reflective"
        }
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial).opacity(0.5)
            Circle().fill(PastelTheme.skyBlue.opacity(0.3 * (1 - t))).frame(width: 120, height: 120).blur(radius: 25)
            Circle().fill(PastelTheme.buttercup.opacity(0.6 * t))
                .frame(width: 70 + 80 * t, height: 70 + 80 * t).blur(radius: 24)
            Circle().fill(PastelTheme.softPink.opacity(0.5 * t))
                .frame(width: 50 + 60 * t, height: 50 + 60 * t).blur(radius: 18).offset(x: 25 * t, y: -15 * t)
            if !reduceMotion {
                ForEach(0..<Int(8 + 18 * t), id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.4 + 0.5 * t))
                        .frame(width: 3 + 4 * t, height: 3 + 4 * t)
                        .offset(x: cos(Double(i) * 2.4) * (40 + 40 * t), y: sin(Double(i) * 2.4) * (35 + 30 * t))
                        .blur(radius: 0.5)
                        .opacity(shimmer ? 1 : 0.4)
                        .animation(.easeInOut(duration: 1.4).repeatForever().delay(Double(i) * 0.07), value: shimmer)
                }
            }
            VStack(spacing: 4) {
                Text(String(format: "%.2f", score))
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                Text(mood)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                Text("NLTagger · on-device")
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
        .onAppear { shimmer = true }
    }
}

struct SentimentBadge: View {
    var score: Double
    var body: some View {
        Text(score >= 0.6 ? "Radiant" : score >= 0.2 ? "Warm" : score > -0.2 ? "Neutral" : "Reflective")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
            .glassBadge()
    }
}

// MARK: - Journal View

struct JournalView: View {
    var store: RippleStore
    @State private var selectedFilter: String = "All"
    let filters = ["All", "This Week", "High Warmth", "Favorites"]
    var filteredActs: [KindAct] {
        let cal = Calendar.current
        switch selectedFilter {
        case "This Week":
            return store.acts.filter { act in
                cal.isDate(act.date, equalTo: Date(), toGranularity: .weekOfYear)
            }
        case "High Warmth":
            return store.acts.filter { $0.sentiment > 0.5 }
        default:
            return store.acts
        }
    }
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.title3)
                        .foregroundStyle(PastelTheme.lavender)
                    Text("Kindness Journal")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Spacer()
                    Text("\(filteredActs.count) entries")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { f in
                            Button {
                                withAnimation { selectedFilter = f }
                            } label: {
                                HStack(spacing: 4) {
                                    if f == "High Warmth" {
                                        Image(systemName: "sparkles")
                                            .font(.caption2)
                                    }
                                    Text(f)
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(selectedFilter == f ? .white : Color(red: 0.55, green: 0.48, blue: 0.7))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedFilter == f
                                            ? LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                                            : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedFilter == f ? Color.clear : .white.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                if filteredActs.isEmpty {
                    VStack(spacing: 14) {
                        ZStack {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .stroke(PastelTheme.lavender.opacity(0.15 - Double(i) * 0.04), lineWidth: 1.5)
                                    .frame(width: 70 + CGFloat(i) * 24, height: 70 + CGFloat(i) * 24)
                            }
                            Image(systemName: "book.closed")
                                .font(.system(size: 32))
                                .foregroundStyle(PastelTheme.lavender)
                        }
                        VStack(spacing: 4) {
                            Text("No entries yet")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                            Text("Complete challenges to fill\nyour kindness journal")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .glassCard()
                    .padding(.horizontal, 20)
                } else {
                    ForEach(filteredActs.reversed()) { act in
                        JournalEntry(act: act)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }
}

struct JournalEntry: View {
    let act: KindAct
    @State private var expanded = false
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) { expanded.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(act.place.color.opacity(0.2))
                            .frame(width: 42, height: 42)
                        Image(systemName: act.place.icon)
                            .font(.subheadline)
                            .foregroundStyle(act.place.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(act.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        HStack(spacing: 6) {
                            Text(act.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                            Circle()
                                .fill(Color(red: 0.55, green: 0.48, blue: 0.7))
                                .frame(width: 3, height: 3)
                            Text(act.energy.rawValue)
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(PastelTheme.buttercup)
                            Text("+\(act.points)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(PastelTheme.buttercup)
                        }
                        SentimentBadge(score: act.sentiment)
                    }
                }
                if expanded {
                    Divider()
                        .overlay(Color.white.opacity(0.3))
                    Text(act.reflection)
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        .fixedSize(horizontal: false, vertical: true)
                    if !act.keywords.isEmpty {
                        HStack {
                            ForEach(act.keywords, id: \.self) { k in
                                Text("#\(k)")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(PastelTheme.mint.opacity(0.2))
                                    .foregroundStyle(PastelTheme.mint)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        Label("\(act.minutes) min", systemImage: "clock")
                        Label(act.place.rawValue, systemImage: "mappin")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .opacity(expanded ? 0.55 : 0.4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: expanded
                                ? [.white.opacity(0.6), act.place.color.opacity(0.3)]
                                : [.white.opacity(0.5), .white.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: expanded ? 1.5 : 1
                    )
            )
            .shadow(color: expanded ? act.place.color.opacity(0.1) : .clear, radius: 8, y: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    var store: RippleStore
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(PastelTheme.mint)
                    Text("Your Garden")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Spacer()
                    Text(store.weeklySummary)
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .lineLimit(1)
                        .frame(maxWidth: 160, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                LevelCard(store: store)
                StatsGrid(store: store)
                MoralCompassView(store: store)
                    .padding(.horizontal, 20)
                GardenPondView(bloom: store.gardenBloom, name: store.inspirationName)
                    .padding(.horizontal, 20)
                ReflectionHistoryCard(store: store)
                ChartCard(store: store)
                BadgesGrid(store: store)
                KindnessCalendar(store: store)
                MoodHistory(store: store)
                WeeklyInsights(store: store)
                Button {
                    store.resetAll()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.caption)
                        Text("Reset All Data")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(PastelTheme.rose.opacity(0.6))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .stroke(PastelTheme.rose.opacity(0.6).opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct LevelCard: View {
    var store: RippleStore
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [PastelTheme.lavender.opacity(0.3), PastelTheme.softPink.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: store.level.icon)
                    .font(.title2)
                    .foregroundStyle(PastelTheme.lavender)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("Level: \(store.level.title)")
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                }
                if store.nextLevelNeed > 0 {
                    Text("\(store.nextLevelNeed) pts to next level")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(PastelTheme.lavender.opacity(0.2))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: max(0, geo.size.width * (Double(store.totalRipples) / Double(store.totalRipples + store.nextLevelNeed))), height: 8)
                        }
                    }
                    .frame(height: 8)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(PastelTheme.buttercup)
                        Text("Max level achieved!")
                            .font(.caption)
                            .foregroundStyle(PastelTheme.buttercup)
                    }
                }
            }
            Spacer()
            VStack(spacing: 2) {
                Text("\(store.totalRipples)")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(
                        LinearGradient(colors: [PastelTheme.buttercup, PastelTheme.peach], startPoint: .top, endPoint: .bottom)
                    )
                Text("ripples")
                    .font(.caption2)
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
            }
        }
        .padding(16)
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.55)
                Circle()
                    .fill(PastelTheme.lavender.opacity(0.06))
                    .frame(width: 60, height: 60)
                    .offset(x: 10, y: -10)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, 20)
    }
}

struct StatsGrid: View {
    var store: RippleStore
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            StatCard(value: "\(store.acts.count)", label: "Acts", icon: "heart.fill", color: PastelTheme.softPink)
            StatCard(value: "\(store.streakDays)d", label: "Streak", icon: "flame.fill", color: PastelTheme.peach)
            StatCard(value: String(format: "%.1f", store.avgPositivity), label: "Warmth", icon: "sparkles", color: PastelTheme.buttercup)
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    var value: String
    var label: String
    var icon: String
    var color: Color
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .opacity(0.45)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct GardenPondView: View {
    var bloom: Double
    var name: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animate = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
            VStack(spacing: 8) {
                Text(name.isEmpty ? "Ripple Garden" : "\(name)'s Garden")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .stroke(PastelTheme.mint.opacity(0.25), lineWidth: 1)
                            .frame(width: 50 + CGFloat(i) * 24, height: 50 + CGFloat(i) * 24)
                            .scaleEffect(animate ? 1.04 : 0.96)
                            .animation(.easeInOut(duration: 3).repeatForever().delay(Double(i) * 0.2), value: animate)
                    }
                    ForEach(0..<Int(2 + bloom * 8), id: \.self) { i in
                        Circle()
                            .fill(PastelTheme.mint.opacity(0.4 + 0.4 * bloom))
                            .frame(width: 12 + 10 * bloom, height: 12 + 10 * bloom)
                            .offset(x: cos(Double(i) * 2.1) * (25 + 35 * bloom), y: sin(Double(i) * 2.1) * (20 + 28 * bloom))
                    }
                    Image(systemName: bloom > 0.6 ? "face.smiling.fill" : bloom > 0.2 ? "leaf.fill" : "circle.dotted")
                        .font(.system(size: 38))
                        .foregroundStyle(PastelTheme.mint, PastelTheme.buttercup)
                        .shadow(color: PastelTheme.buttercup.opacity(0.4 * bloom), radius: 12)
                }
                .frame(height: 150)
                Text(bloom < 0.2 ? "Plant your first seed" : bloom < 0.6 ? "Sprouting! Keep going." : "Blooming beautifully!")
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
            }
            .padding(14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(colors: [.white.opacity(0.5), .white.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
        .onAppear { animate = true }
    }
}

struct ChartCard: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.skyBlue)
                Text("7-Day Activity")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            Chart(store.happinessSeries) { p in
                BarMark(x: .value("Day", p.label), y: .value("Acts", p.count))
                    .foregroundStyle(
                        LinearGradient(colors: [PastelTheme.lavender, PastelTheme.softPink], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(6)
                LineMark(x: .value("Day", p.label), y: .value("Happiness", p.happiness))
                    .foregroundStyle(PastelTheme.mint)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .symbol(Circle().strokeBorder(lineWidth: 1.5))
                    .symbolSize(30)
            }
            .frame(height: 160)
            Text(store.weeklySummary)
                .font(.caption)
                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal, 20)
    }
}

struct BadgesGrid: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "rosette")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.buttercup)
                Text("Badges")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
                let earned = store.badges.filter { $0.1 }.count
                Text("\(earned)/\(store.badges.count)")
                    .font(.caption2)
                    .foregroundStyle(PastelTheme.buttercup)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 10) {
                ForEach(Array(store.badges.enumerated()), id: \.offset) { _, pair in
                    let def = pair.0; let earned = pair.1
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(earned ? PastelTheme.buttercup.opacity(0.2) : Color(red: 0.55, green: 0.48, blue: 0.7).opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: def.icon)
                                .font(.title3)
                                .foregroundStyle(earned ? PastelTheme.buttercup : Color(red: 0.55, green: 0.48, blue: 0.7))
                        }
                        VStack(spacing: 2) {
                            Text(def.name)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                                .multilineTextAlignment(.center)
                            Text(def.detail)
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial)
                            .opacity(earned ? 0.5 : 0.3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                earned
                                    ? LinearGradient(colors: [PastelTheme.buttercup.opacity(0.4), PastelTheme.buttercup.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1
                            )
                    )
                    .opacity(earned ? 1 : 0.6)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct KindnessCalendar: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.skyBlue)
                Text("Kindness Calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            let cal = Calendar.current
            let today = Date()
            let daysInMonth = cal.range(of: .day, in: .month, for: today)?.count ?? 30
            let firstWeekday = cal.component(.weekday, from: cal.date(from: cal.dateComponents([.year, .month], from: today))!)
            let _ = print("First weekday offset:", firstWeekday)
            let actDays = Set(store.acts.map { cal.component(.day, from: $0.date) })
            let moodDays = Set(store.moodEntries.map { cal.component(.day, from: $0.date) })
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                    Color.clear.frame(height: 32)
                }
                ForEach(1...daysInMonth, id: \.self) { day in
                    let hasAct = actDays.contains(day)
                    let hasMood = moodDays.contains(day)
                    let isToday = cal.component(.day, from: today) == day
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(hasAct ? PastelTheme.mint.opacity(0.5) : hasMood ? PastelTheme.lavender.opacity(0.3) : Color.clear)
                            .frame(height: 32)
                        if isToday {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(PastelTheme.softPink, lineWidth: 1.5)
                                .frame(height: 32)
                        }
                        Text("\(day)")
                            .font(.caption2.weight(isToday ? .bold : .regular))
                            .foregroundStyle(hasAct ? PastelTheme.mint : Color(red: 0.5, green: 0.43, blue: 0.65))
                    }
                }
            }
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(PastelTheme.mint.opacity(0.5)).frame(width: 8, height: 8)
                    Text("Kind act")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                }
                HStack(spacing: 4) {
                    Circle().fill(PastelTheme.lavender.opacity(0.3)).frame(width: 8, height: 8)
                    Text("Mood logged")
                        .font(.caption2)
                        .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                }
            }
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal, 20)
    }
}

struct MoodHistory: View {
    var store: RippleStore
    var recentMoods: [MoodEntry] {
        Array(store.moodEntries.suffix(7).reversed())
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "face.smiling")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.softPink)
                Text("Mood History")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            if recentMoods.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "face.smiling")
                        .font(.title2)
                        .foregroundStyle(PastelTheme.softPink.opacity(0.5))
                    Text("Log your mood daily to see patterns here.")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(recentMoods) { entry in
                    HStack(spacing: 10) {
                        Image(systemName: entry.mood.icon)
                            .font(.subheadline)
                            .foregroundStyle(entry.mood.color)
                        VStack(alignment: .leading) {
                            Text(entry.mood.rawValue)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                            if !entry.note.isEmpty {
                                Text(entry.note)
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Text(entry.date.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.caption2)
                            .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
                    }
                    .padding(10)
                    .glassCard(cornerRadius: 12, opacity: 0.4)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct WeeklyInsights: View {
    var store: RippleStore
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundStyle(PastelTheme.peach)
                Text("Weekly Insights")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                Spacer()
            }
            let cal = Calendar.current
            let thisWeek = store.acts.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
            let totalPoints = thisWeek.reduce(0) { $0 + $1.points }
            let totalMinutes = thisWeek.reduce(0) { $0 + $1.minutes }
            let uniquePlaces = Set(thisWeek.map { $0.place }).count
            HStack(spacing: 12) {
                InsightTile(value: "\(thisWeek.count)", label: "Acts", icon: "heart.fill", color: PastelTheme.softPink)
                InsightTile(value: "\(totalPoints)", label: "Points", icon: "star.fill", color: PastelTheme.buttercup)
                InsightTile(value: "\(totalMinutes)m", label: "Time", icon: "clock.fill", color: PastelTheme.skyBlue)
                InsightTile(value: "\(uniquePlaces)", label: "Places", icon: "map.fill", color: PastelTheme.mint)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct InsightTile: View {
    var value: String
    var label: String
    var icon: String
    var color: Color
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color(red: 0.55, green: 0.48, blue: 0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .opacity(0.4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Breathe View

struct BreatheView: View {
    var store: RippleStore
    @State private var isBreathing = false
    @State private var breatheIn = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var breathCount = 0
    @State private var totalSeconds = 0
    @State private var selectedDuration = 60
    @State private var shimmer = false
    let durations = [30, 60, 120, 300]
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    Image(systemName: "wind")
                        .font(.title3)
                        .foregroundStyle(PastelTheme.skyBlue)
                    Text("Breathe")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(colors: [PastelTheme.skyBlue, PastelTheme.lavender], startPoint: .leading, endPoint: .trailing)
                        )
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                Text("Calm your mind. Release stress.\nBe present in this moment.")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [PastelTheme.skyBlue.opacity(0.12 + 0.03 * Double(i)), PastelTheme.lavender.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 140 + CGFloat(i) * 32, height: 140 + CGFloat(i) * 32)
                            .scaleEffect(isBreathing ? (breatheIn ? 1.12 : 0.88) : 1.0)
                            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathing)
                    }
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    PastelTheme.skyBlue.opacity(isBreathing ? 0.45 : 0.25),
                                    PastelTheme.lavender.opacity(isBreathing ? 0.25 : 0.12)
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 130, height: 130)
                        .scaleEffect(isBreathing ? (breatheIn ? 1.25 : 0.75) : 1.0)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathing)
                    if !isBreathing {
                        ForEach(0..<6, id: \.self) { i in
                            Circle()
                                .fill(PastelTheme.softPink.opacity(0.4 + 0.2 * Double(i)))
                                .frame(width: 3, height: 3)
                                .offset(x: cos(Double(i) * 1.05) * 55, y: sin(Double(i) * 1.05) * 55)
                                .opacity(shimmer ? 0.8 : 0.3)
                                .animation(.easeInOut(duration: 2).repeatForever().delay(Double(i) * 0.2), value: shimmer)
                        }
                    }
                    VStack(spacing: 6) {
                        Image(systemName: isBreathing ? (breatheIn ? "arrow.down.circle.fill" : "arrow.up.circle.fill") : "play.circle.fill")
                            .font(.system(size: isBreathing ? 28 : 32))
                            .foregroundStyle(
                                isBreathing
                                    ? (breatheIn ? PastelTheme.skyBlue : PastelTheme.lavender)
                                    : PastelTheme.skyBlue
                            )
                        Text(isBreathing ? (breatheIn ? "Breathe In" : "Breathe Out") : "Ready?")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        if isBreathing {
                            Text("\(breathCount) breaths")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        }
                    }
                }
                .frame(height: 300)
                if !isBreathing {
                    VStack(spacing: 10) {
                        Text("Duration")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                        HStack(spacing: 10) {
                            ForEach(durations, id: \.self) { d in
                                Button {
                                    selectedDuration = d
                                } label: {
                                    Text("\(d / 60) min")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(selectedDuration == d ? .white : Color(red: 0.55, green: 0.48, blue: 0.7))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 10)
                                         .background(
                                            Capsule()
                                                .fill(selectedDuration == d
                                                    ? LinearGradient(colors: [PastelTheme.skyBlue, PastelTheme.lavender], startPoint: .leading, endPoint: .trailing)
                                                    : LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(selectedDuration == d ? Color.clear : .white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                Button {
                    if isBreathing {
                        stopBreathing()
                    } else {
                        startBreathing()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isBreathing ? "stop.fill" : "play.fill")
                            .font(.subheadline)
                        Text(isBreathing ? "Stop" : "Begin")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isBreathing
                                ? AnyShapeStyle(LinearGradient(colors: [Color.red.opacity(0.6), Color.red.opacity(0.4)], startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(LinearGradient(colors: [PastelTheme.skyBlue, PastelTheme.lavender], startPoint: .leading, endPoint: .trailing)))
                    )
                }
                .padding(.horizontal, 20)
                if breathCount > 0 && !isBreathing {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(PastelTheme.buttercup)
                            Text("Great job!")
                                .font(.headline)
                                .foregroundStyle(Color(red: 0.3, green: 0.24, blue: 0.5))
                        }
                        Text("You completed \(breathCount) breaths. Mindfulness reduces cortisol and boosts happiness.")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.5, green: 0.43, blue: 0.65))
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .glassCard()
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .onAppear { shimmer = true }
        .onReceive(timer) { _ in
            guard isBreathing else { return }
            totalSeconds += 1
            if totalSeconds >= selectedDuration {
                stopBreathing()
                return
            }
            if totalSeconds % 4 == 0 {
                breatheIn.toggle()
                breathCount += 1
            }
        }
    }
    func startBreathing() {
        isBreathing = true
        breatheIn = true
        breathCount = 0
        totalSeconds = 0
    }
    func stopBreathing() {
        isBreathing = false
    }
}

// MARK: - Pencil Canvas (for future thank-you cards)

struct PencilCanvas: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = UIColor(white: 1, alpha: 0.9)
        canvas.tool = PKInkingTool(.marker, color: UIColor.systemPink, width: 12)
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
