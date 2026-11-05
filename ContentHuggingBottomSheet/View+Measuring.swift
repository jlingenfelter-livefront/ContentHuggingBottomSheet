//
//  View+Measuring.swift
//  MyApp
//
//  Created by Jo Lingenfelter on 11/3/26.
//

import SwiftUI

extension View {
    // Measure a value based on a KeyPath of a GeometryProxy
    func measuring(
        _ path: KeyPath<GeometryProxy, CGFloat>,
        assign value: Binding<Double>
    ) -> some View {
        self.onGeometryChange(for: CGFloat.self, of: { geometry in
            geometry[keyPath: path]
        }, action: { newValue in
            guard value.wrappedValue != newValue else { return }
            value.wrappedValue = newValue
        })
    }

    // Measure a value based on a KeyPath from CGRect -> CGFloat
    func measuring(
        _ path: KeyPath<CGRect, CGFloat>,
        in coordinateSpace: CoordinateSpace = .local,
        assign value: Binding<CGFloat>
    ) -> some View {
        self.onGeometryChange(for: CGFloat.self, of: { geometry in
            geometry.frame(in: coordinateSpace)[keyPath: path]
        }, action: { newValue in
            guard value.wrappedValue != newValue else { return }
            value.wrappedValue = newValue
        })
    }

    // Measure a whole frame in a given coordinate space
    func measuringFrame(
        in coordinateSpace: CoordinateSpace = .global,
        assign value: Binding<CGRect>
    ) -> some View {
        self.onGeometryChange(for: CGRect.self, of: { geometry in
            geometry.frame(in: coordinateSpace)
        }, action: { newValue in
            guard value.wrappedValue != newValue else { return }
            value.wrappedValue = newValue
        })
    }
}
