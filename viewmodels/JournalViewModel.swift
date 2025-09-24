import Foundation

class JournalViewModel: BaseViewModel, ViewModelProtocol {
    struct Input {
        let loadEntries: () -> Void
    }

    struct Output {
        let entries: Observable<[MVVMJournalEntry]>
    }

    @Observable var entries: [MVVMJournalEntry] = []

    func transform(input: Input) -> Output {
        return Output(entries: $entries)
    }

    func loadSampleEntries() {
        setLoading(true)

        let sampleEntries = [
            MVVMJournalEntry(
                date: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
                title: "Today",
                preview: "Today I felt grateful for the quiet morning coffee and the way sunlight streamed through my window. There's something magical about these peaceful moments before the world wakes up...",
                emoji: "😊",
                type: "Voice Entry",
                readTime: "2 min read"
            ),
            MVVMJournalEntry(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                title: "Yesterday",
                preview: "Meditation helped me find clarity about the challenges I'm facing. I'm learning to trust the process and embrace uncertainty as part of growth...",
                emoji: "🙏",
                type: "Guided Entry",
                readTime: "3 min read"
            ),
            MVVMJournalEntry(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                title: "2 days ago",
                preview: "Had an incredible breakthrough during my morning walk. Sometimes the answers we seek come when we stop looking so hard and just allow ourselves to be present...",
                emoji: "✨",
                type: "Text Entry",
                readTime: "4 min read"
            ),
            MVVMJournalEntry(
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                title: "3 days ago",
                preview: "Reflecting on personal growth and how far I've come. Every small step matters, even when progress feels slow. Today I choose patience with myself...",
                emoji: "🌱",
                type: "Voice Entry",
                readTime: "1 min read"
            )
        ]

        self.entries = sampleEntries
        setLoading(false)
    }
}

struct MVVMJournalEntry {
    let date: Date
    let title: String
    let preview: String
    let emoji: String
    let type: String
    let readTime: String
}