import JavaScriptCore

public extension JSValue {
    
    /// `true` if the value is `undefined` or `null`
    var isNil: Bool {
        return isUndefined || isNull
    }
    
    /// `true` if the value is neither `undefined` nor `null`
    var isNotNil: Bool {
        return !isUndefined && !isNull
    }
}
