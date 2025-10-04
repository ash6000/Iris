import Foundation

class OpenAIService {
    static let shared = OpenAIService()

    // API key from configuration file
    private let apiKey = APIConfig.openAIAPIKey
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {}

    func sendMessage(_ message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard !apiKey.isEmpty && apiKey != "YOUR_API_KEY_HERE" else {
            completion(.failure(OpenAIError.invalidAPIKey))
            return
        }

        guard let url = URL(string: baseURL) else {
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
