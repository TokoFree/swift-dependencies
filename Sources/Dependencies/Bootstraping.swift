//
//  Bootstrapping.swift
//  RxComposableArchitecture
//
//  Created by Wendy Liga on 25/06/21.
//

import Foundation

#if DEBUG
    /**
     A Way to Mock/Inject custom behaviour to your TCA.
     with `Bootstrap` you can inject your custom `Dependencies` or `Environment` to your page.
     
     let's say, our page have this environment or dependencies
     ```swift
     struct Environment {
        var request: () -> Effect<Result<Response, NetworkError>>
        ...
        ...
     }
     ```
     
     ## Injecting custom Dependencies

     we want to inject custom behaviour like if request fail,
     we will create the fail `Environment` case, and inject it.

     ```swift
     let requestFail = Environment {
        request: {
            return Effect(value: .failure(.serverError))
        }
     }
     
     extension DependencyValues {
         var yourPageEnvironment: Environment {
             get { self[Environment.self] }
             set { self[Environment.self] = newValue }
         }
     }
     ```

     once we have our Environment, we can inject it by
     calling `mock(_:)` function on `Bootstrap`

     ```swift
     Bootstrap.mock(\.yourPageEnvironment, requestFail)
     ```

     you can expect your feature to have this custom behaviour right away,
     you *do not* need to restart the simulator, or reinit your page.

     ## Injecting custom Environment

     we want to inject custom behaviour like if request fail,
     we will create the fail `Environment` case, and inject it.

     ```swift
     let requestFail = Environment {
        request: {
            return Effect(value: .failure(.serverError))
        }
     }
     ```

     once we have our Environment, we can inject it by
     calling `mock(_:)` function on `Bootstrap`

     ```swift
     Bootstrap.mock(requestFail)
     ```

     you can expect your feature to have this custom behaviour right away,
     you *do not* need to restart the simulator, or reinit your page.

     ## Reset custom Environment or Dependencies

     once you inject something, it will be there for the rest of app session(means untill app is killed).
     maybe after testing and playing with custom behaviour, you want to go back to 'live' or production behaviour,
     then you need to reset it by

     ```swift
     Bootstrap.clear(_YOUR_ENVIRONMENT_TYPE)
     
     /// or when using Dependencies
     Bootstrap.clear(_YOUR_KEYPATH_DEPENDENCIES)
     ```

     so on our example
     ```swift
     Bootstrap.clear(Environment.self)
     
     /// or when using dependencies
     Bootstrap.clear(\.yourPageEnvironment)
     ```
     it will clear the custom behaviour and you can expect it right away like when you custom it in the first place.

     - Warning:
     the way bootstrap works is each `Environment` type will become identifier for Environment & for dependencies it will use the `KeyPath` for the identifiers. means you only can inject one at a time for spesific `Environment` type or `Dependencies` keyPath.
     */
    public enum Bootstrap {
        /// Inject your custom `Environment`
        ///
        /// ## Example
        ///
        /// ```swift
        /// let requestFail = Environment {
        ///    request: {
        ///       return Effect(value: .failure(.serverError))
        ///    }
        /// }
        ///
        ///
        /// Bootstrap.mock(requestFail)
        /// ```
        /// - Parameter environment: `Environment` to be injected
        public static func mock<Environment>(environment: Environment) {
            guard type(of: environment) != Void.self else {
                assertionFailure("You made a mistake by passing Void as a param, you never need to mock the Void")
                return
            }

            _bootstrappedEnvironments[String(reflecting: Environment.self)] = environment
        }

        /// Clear Previous custom injected `Environment`
        ///
        /// ## Example
        ///
        /// ```swift
        /// Bootstrap.clear(HomeEnvironment.self)
        /// ```
        ///
        /// - Parameter environment: `Environment` type
        public static func clear<Environment>(environment _: Environment.Type) {
            clear(String(reflecting: Environment.self))
        }

        /// fetch bootstrapped environment from given `Environment` type if exist
        /// - Parameter : `Environment` type
        /// - Returns: `Environment` from `_bootstrappedEnvironments` by given type
        public static func get<Environment>(environment _: Environment.Type) -> Environment? {
            _bootstrappedEnvironments[String(reflecting: Environment.self)] as? Environment
        }

        /// clear from spesific id
        /// - Warning: this api only supposed to be used on `BootstrapPicker`
        /// - Parameter id: environment type in string
        internal static func clear(_ id: String) {
            _bootstrappedEnvironments.removeValue(forKey: id)
        }

        /// clear all bootstrapped environment
        /// - Warning: this api only supposed to be used on `BootstrapPicker`
        internal static func clearAll() {
            _bootstrappedEnvironments.removeAll()
            _bootstrappedDependencies.storage.removeAll()
        }

        /// get all Bootstrapped identifier
        /// - Warning: this api only supposed to be used on `BootstrapPicker`
        /// - Returns: all active indentifier
        internal static func getAllBootstrappedIdentifier() -> [String] {
            _bootstrappedEnvironments.map(\.key) + _bootstrappedDependencies.storage.map(\.key.debugDescription)
        }
    }

    /// for our `Dependencies` mocking functionality
    ///
    extension Bootstrap {
        /// Inject your custom `Dependencies`
        ///
        /// ## Example
        ///
        /// ```swift
        /// let requestFail = Environment {
        ///    request: {
        ///       return Effect(value: .failure(.serverError))
        ///    }
        /// }
        /// Bootstrap.mock(\.yourPageEnvironment, mockFailed)
        /// ```
        /// - Parameter keypath: the `Kaypath` Dependencies to be injected
        /// - Parameter value: the mock 
        public static func mock<Value>(
            keypath: WritableKeyPath<DependencyValues, Value>,
            value: Value
        ) {
            _bootstrappedDependencies[keyPath: keypath] = value
        }
        
        /// Clear Previous custom injected `Dependencies`
        ///
        /// ## Example
        ///
        /// ```swift
        /// Bootstrap.clear(\.yourPageEnvironment)
        /// ```
        ///
        /// - Parameter keypath: the kaypath for our injected dependencies
        public static func clear<Value>(keypath: WritableKeyPath<DependencyValues, Value>) {
            _bootstrappedDependencies.storage.removeValue(forKey: ObjectIdentifier(keypath))
        }
    }

    internal var _bootstrappedEnvironments: [String: Any] = [:]
    internal var _bootstrappedDependencies: DependencyValues = DependencyValues()
#endif
