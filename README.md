# swift-toolbox
Contains various Swift implementations that can be useful in every project.

Still a work in progress, but maybe someone will stumble upon it and see it quite useful.

## Frameworks

#### [Task Framework](SwiftToolbox/Source/Tasks)
Pass around future values using this handy framework.

#### [GCD Swift Wrapper](SwiftToolbox/Source/Dispatch)
A nice Swift wrapper around libDispatch which provides additional features such as retreiving the current queue and setting queue local values.

#### [Enhanced Error Handling](SwiftToolbox/Source/Errors)
Enhances the `ErrorType` by introducing `Exception`s, which provide additional, debug information, as well as optional user presentable information.

### Data

#### [Currency Type](SwiftToolbox/Source/Data#currency)
A type used to deal with currency. At this time, it is a Swift wrapper around `NSDecimalNumber`.

#### [Date Type](SwiftToolbox/Source/Data#date)
A type used to deal with dates. At this time, it is a Swift wrappper around `NSDate`.

#### [JSON Values](SwiftToolbox/Source/Data#json)
This handy enumeration can represent any JSON value and provides serialization and deserialization.

#### [Percentage Postfix Operator](SwiftToolbox/Source/Data#percent)
Thought it was a good use for custom postfix operator.

#### [Misc. String Utilities](SwiftToolbox/Source/Data#string)
Misc. string utilities.

### User Interface

#### [View Animation Assistant](SwiftToolbox/Source/UI#viewanimator)
Provides a nice way to define complex animations by using an animation builder pattern.
