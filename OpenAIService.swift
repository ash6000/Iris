import Foundation

class OpenAIService {
    static let shared = OpenAIService()

    // API key from configuration file
    private let apiKey = APIConfig.openAIAPIKey
    private let chatURL = "https://api.openai.com/v1/chat/completions"
    private let whisperURL = "https://api.openai.com/v1/audio/transcriptions"
    private let ttsURL = "https://api.openai.com/v1/audio/speech"

    private init() {}

    func sendMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(OpenAIError.invalidAPIKey))
            return
        }

        guard let url = URL(string: chatURL) else {
            completion(.failure(OpenAIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are Iris, a compassionate and personalized AI companion in a journaling and wellness app. You help users with their mental health, personal growth, and daily reflections. Respond in a warm, supportive, and understanding tone. Keep responses concise but meaningful."
                ],
                [
                    "role": "user",
                    "content": message
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(OpenAIError.noData))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                if let message = response.choices.first?.message.content {
                    DispatchQueue.main.async {
                        completion(.success(message))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(OpenAIError.noMessage))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Voice Functions

    /// Transcribe audio to text using Whisper API
    func transcribeAudio(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(OpenAIError.invalidAPIKey))
            return
        }

        guard let url = URL(string: whisperURL) else {
            completion(.failure(OpenAIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)

        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(OpenAIError.noData))
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(WhisperResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.text))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    /// Convert text to speech using TTS API
    func textToSpeech(text: String, voice: VoiceType = .nova, speed: Double = 1.0, completion: @escaping (Result<Data, Error>) -> Void) {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(OpenAIError.invalidAPIKey))
            return
        }

        guard let url = URL(string: ttsURL) else {
            completion(.failure(OpenAIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": voice.rawValue,
            "speed": speed
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(OpenAIError.noData))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
}

// MARK: - OpenAI Response Models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let role: String
    let content: String
}

// MARK: - Voice Response Models
struct WhisperResponse: Codable {
    let text: String
}

// MARK: - Voice Types
enum VoiceType: String, CaseIterable {
    case alloy = "alloy"
    case echo = "echo"
    case fable = "fable"
    case onyx = "onyx"
    case nova = "nova"
    case shimmer = "shimmer"
}

// MARK: - Custom Errors
enum OpenAIError: Error, LocalizedError {
    case invalidAPIKey
    case invalidURL
    case noData
    case noMessage

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid or missing OpenAI API key"
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from OpenAI"
        case .noMessage:
            return "No message content in OpenAI response"
        }
    }
}
