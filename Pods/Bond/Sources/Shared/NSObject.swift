//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import ReactiveKit

extension NSObject: ReactiveExtensionsProvider {}

extension ReactiveExtensions where Base: NSObject {

  /// A signal that fires completion event when the object is deallocated.
  public var deallocated: SafeSignal<Void> {
    return bag.deallocated
  }

  /// Use this bag to dispose disposables upon the deallocation of the receiver.
  public var bag: DisposeBag {
    if let disposeBag = objc_getAssociatedObject(base, &NSObject.AssociatedKeys.DisposeBagKey) {
      return disposeBag as! DisposeBag
    } else {
      let disposeBag = DisposeBag()
      objc_setAssociatedObject(base, &NSObject.AssociatedKeys.DisposeBagKey, disposeBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return disposeBag
    }
  }
}

public protocol Deallocatable: class {
  var deallocated: Signal<Void, NoError> { get }
}

extension NSObject: Deallocatable {

  fileprivate struct AssociatedKeys {
    static var DisposeBagKey = "bnd_DisposeBagKey"
  }

  /// A signal that fires completion event when the object is deallocated.
  public var deallocated: Signal<Void, NoError> {
    return reactive.deallocated
  }

  /// Bind `signal` to `bindable` and dispose in `bnd_bag` of receiver.
  public func bind<O: SignalProtocol, B: BindableProtocol>(_ signal: O, to bindable: B) where O.Element == B.Element, O.Error == NoError {
    signal.bind(to: bindable).dispose(in: reactive.bag)
  }
  
  /// Bind `signal` to `bindable` and dispose in `bnd_bag` of receiver.
  public func bind<O: SignalProtocol, B: BindableProtocol>(_ signal: O, to bindable: B) where B.Element: OptionalProtocol, O.Element == B.Element.Wrapped, O.Error == NoError {
    signal.bind(to: bindable).dispose(in: reactive.bag)
  }
}
