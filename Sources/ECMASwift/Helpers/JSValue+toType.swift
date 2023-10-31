import JavaScriptCore

extension JSValue {
    func toType<T>(_: T.Type) -> T? {
        return toObject() as? T
    }
}
