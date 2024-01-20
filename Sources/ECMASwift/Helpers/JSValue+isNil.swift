import JavaScriptCore

public extension JSValue {

    /// `true` if the value is `undefined` or `null`
    var hasNoValue: Bool {
        return isUndefined || isNull
    }

    /// `true` if the value is neither `undefined` nor `null`
    var hasValue: Bool {
        return !isUndefined && !isNull
    }
}
