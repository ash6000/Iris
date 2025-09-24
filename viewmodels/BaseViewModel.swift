import Foundation

class BaseViewModel {
    @Observable var isLoading: Bool = false
    @Observable var error: Error?

    func handleError(_ error: Error) {
        self.error = error
    }

    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
}