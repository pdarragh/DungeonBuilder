//
//  CyclingSequence.swift
//  DungeonBuilder
//
//  Created by Pierce Darragh on 2/13/19.
//  Copyright © 2019 Pierce Corp. All rights reserved.
//

public protocol CyclingSequenceProtocol : Sequence {
    associatedtype Elements: Sequence = Self where Elements.Element == Element
}

@_fixed_layout
public struct CyclingSequence<Base> where Base : Collection {
    @usableFromInline
    internal var _base: Base

    @inlinable
    internal init(_base: Base) {
        self._base = _base
    }
}

extension CyclingSequence: Sequence where Elements : Collection {
    public typealias Element = Base.Element
    public typealias Iterator = CyclingIndexingIterator<Base>

    public func makeIterator() -> Iterator {
        return Iterator(_elements: _base)
    }
}

extension CyclingSequence: CyclingSequenceProtocol where Base : Collection {
    public typealias Elements = Base
}

public struct CyclingIndexingIterator<Elements : Collection> {
    @usableFromInline
    internal let _elements: Elements
    @usableFromInline
    internal var _position: Elements.Index

    @inlinable
    @inline(__always)
    public init(_elements: Elements) {
        self._elements = _elements
        self._position = _elements.startIndex
    }
}

extension CyclingIndexingIterator: IteratorProtocol, Sequence {
    public typealias Element = Elements.Element
    public typealias Iterator = CyclingIndexingIterator<Elements>

    @inlinable
    @inline(__always)
    public mutating func next() -> Elements.Element? {
        if _position == _elements.endIndex {
            // Reset the index to the beginning and resume.
            _position = _elements.startIndex
        }
        let element = _elements[_position]
        _elements.formIndex(after: &_position)
        return element
    }
}

extension Collection {
    @inlinable
    public var cycle: CyclingSequence<Self> {
        return CyclingSequence(_base: self)
    }
}
