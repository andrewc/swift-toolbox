# swift-toolbox
Contains various Swift implementations that can be useful in every project.

This is still a work in progress, and many of the components in this fraemwork could be broken into several submodules.  But, for now, keeping it all in one.

## Features

### Task Framework for Passing Future Values

There is always a need to pass around a value that may not be available immediately. This handy framework allows for an easy to use and elegant approach.

#### Components of the Framework

- A 'TaskKernel', an object which performs the task's work.
- A `TaskScheduler`, an object which is responsible for starting the kernel, and notifying the result. *The default task scheduler uses GCD global dispatch queue.*
- A `TaskFactory`, an object which vends new `Task<>`, constructed with defaults of the properties set on it.
- A method for *cooperative cancellation*, which allows a task's kernel to acknowledge a cancellation request so it can exit gracefully.

#### The Duties of `Task<>`

- Holds a refernce to the `TaskKernel` that will be doing the work.
- Keeps track of status of the task's execution, such as `Waiting`, `Running`, `Completed`, etc.
