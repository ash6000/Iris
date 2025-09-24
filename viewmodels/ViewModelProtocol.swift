import Foundation

protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

@propertyWrapper
class Observable<T> {
    private var value: T
    private var observers: [String: (T) -> Void] = [:]

    var wrappedValue: T {
        get { value }
        set {
            value = newValue
            notifyObservers()
        }
    }

    var projectedValue: Observable<T> {
        return self
    }

    init(wrappedValue: T) {
        self.value = wrappedValue
    }

    func bind<Observer: AnyObject>(
        _ observer: Observer,
        _ closure: @escaping (T) -> Void
    ) {
        let key = "\(ObjectIdentifier(observer))"
        observers[key] = closure
        closure(value)
    }

    func unbind<Observer: AnyObject>(_ observer: Observer) {
        let key = "\(ObjectIdentifier(observer))"
        observers.removeValue(forKey: key)
    }

    private func notifyObservers() {
        observers.values.forEach { $0(value) }
    }
}