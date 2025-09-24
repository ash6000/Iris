import Foundation

class TextEntryViewModel: BaseViewModel, ViewModelProtocol {
    struct Input {
        let textChanged: (String) -> Void
        let moodSelected: (Int) -> Void
        let saveEntry: () -> Void
    }

    struct Output {
        let entryText: Observable<String>
        let wordCount: Observable<Int>
        let selectedMood: Observable<Int>
        let canSave: Observable<Bool>
        let currentPrompt: Observable<String>
    }

    @Observable var entryText: String = ""
    @Observable var wordCount: Int = 0
    @Observable var selectedMood: Int = 2
    @Observable var canSave: Bool = false
    @Observable var currentPrompt: String = ""

    private let prompts = [
        "What made today special?",
        "Describe a moment that brought you joy today.",
        "What are you grateful for right now?",
        "What challenged you today and how did you overcome it?",
        "What did you learn about yourself today?",
        "Describe the emotions you're feeling right now.",
        "What would you like to remember about today?",
        "How did you grow or change today?",
        "What are you looking forward to tomorrow?",
        "What person or experience impacted you today?"
    ]

    override init() {
        super.init()
        currentPrompt = "What brought you peace today?"
        setupTextObserver()
    }

    func transform(input: Input) -> Output {
        return Output(
            entryText: $entryText,
            wordCount: $wordCount,
            selectedMood: $selectedMood,
            canSave: $canSave,
            currentPrompt: $currentPrompt
        )
    }

    func updateText(_ text: String) {
        entryText = text
        updateWordCount()
        updateCanSave()
    }

    func updateMood(_ mood: Int) {
        selectedMood = mood
    }

    func generateRandomPrompt() {
        currentPrompt = prompts.randomElement() ?? prompts[0]
    }

    func saveEntry() {
        guard canSave else { return }

        setLoading(true)

        // Simulate saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.setLoading(false)
            self?.resetEntry()
        }
    }

    private func setupTextObserver() {
        $entryText.bind(self) { [weak self] _ in
            self?.updateWordCount()
            self?.updateCanSave()
        }
    }

    private func updateWordCount() {
        let words = entryText.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        wordCount = words.count
    }

    private func updateCanSave() {
        canSave = wordCount >= 10
    }

    private func resetEntry() {
        entryText = ""
        selectedMood = 2
        generateRandomPrompt()
    }
}