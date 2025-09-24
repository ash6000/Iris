import Foundation

class GuidedEntryViewModel: BaseViewModel, ViewModelProtocol {
    struct Input {
        let sendMessage: (String) -> Void
        let startSession: () -> Void
    }

    struct Output {
        let messages: Observable<[GuidedJournalMessage]>
        let isTyping: Observable<Bool>
        let canSendMessage: Observable<Bool>
    }

    @Observable var messages: [GuidedJournalMessage] = []
    @Observable var isTyping: Bool = false
    @Observable var canSendMessage: Bool = true

    private let guidedPrompts = [
        "Hello! I'm here to guide you through your journaling session. How are you feeling right now?",
        "That's interesting. Can you tell me more about what led to feeling this way?",
        "I understand. What do you think would help you process these feelings?",
        "That sounds like a meaningful insight. How might you apply this understanding going forward?",
        "Thank you for sharing that with me. What else would you like to explore today?",
        "It sounds like you've learned something valuable about yourself. How does this make you feel?",
        "That's a wonderful realization. What small step could you take today to honor this insight?",
        "I appreciate your openness. Is there anything else on your mind that you'd like to discuss?",
        "It seems like we've covered a lot of ground today. How are you feeling about our conversation?",
        "Thank you for this meaningful conversation. Remember, I'm always here when you need to reflect."
    ]

    private var currentPromptIndex = 0

    func transform(input: Input) -> Output {
        return Output(
            messages: $messages,
            isTyping: $isTyping,
            canSendMessage: $canSendMessage
        )
    }

    func startSession() {
        messages = [
            GuidedJournalMessage(
                type: .intro,
                content: "What's on your mind today? Do you want today's backup prompt?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .moodSelection,
                content: "How are you feeling right now?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .aiMessage,
                content: "I sense you might be carrying some weight today. What's been on your heart lately?",
                isUser: false
            ),
            GuidedJournalMessage(
                type: .userMessage,
                content: "I'm feeling overwhelmed with work and personal stuff. Everything feels like it's piling up.",
                isUser: true
            ),
            GuidedJournalMessage(
                type: .aiMessage,
                content: "That feeling of overwhelm is so human and valid. Let's breathe through this together. Can you name one small thing that brought you even a moment of peace today?",
                isUser: false
            )
        ]
        currentPromptIndex = 0
    }

    func sendUserMessage(_ text: String) {
        guard canSendMessage && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        addUserMessage(text)
        canSendMessage = false
        isTyping = true

        // Simulate AI response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.generateAIResponse()
            self?.isTyping = false
            self?.canSendMessage = true
        }
    }

    private func addUserMessage(_ text: String) {
        let message = GuidedJournalMessage(
            type: .userMessage,
            content: text,
            isUser: true
        )
        messages.append(message)
    }

    private func addAIMessage(_ text: String) {
        let message = GuidedJournalMessage(
            type: .aiMessage,
            content: text,
            isUser: false
        )
        messages.append(message)
    }

    private func generateAIResponse() {
        currentPromptIndex += 1

        if currentPromptIndex < guidedPrompts.count {
            addAIMessage(guidedPrompts[currentPromptIndex])
        } else {
            // Generate contextual response based on conversation
            let responses = [
                "That's a profound reflection. What does this mean for you moving forward?",
                "I can sense the depth of your thoughts. How might you carry this insight into your day?",
                "Your self-awareness is growing. What patterns do you notice in your reflections?",
                "Thank you for trusting me with your thoughts. What feels most important right now?",
                "I appreciate your honesty. How can you be kind to yourself today?"
            ]
            addAIMessage(responses.randomElement() ?? responses[0])
        }
    }
}