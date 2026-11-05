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
        assign value: Binding<CGFloat>
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

    // Measure a value based on a KeyPath from CGRect -> CGFloat, animating changes
    // only while the `stable` dimension (width by default) hasn't changed
    func measuringAnimatedValue(
        _ path: KeyPath<CGRect, CGFloat>,
        in coordinateSpace: CoordinateSpace = .local,
        assign value: Binding<CGFloat>,
        animation: Animation? = .default,
        whileUnchanged stable: KeyPath<CGRect, CGFloat> = \.width
    ) -> some View {
        modifier(
            AnimatedMeasurement(
                path: path,
                stablePath: stable,
                coordinateSpace: coordinateSpace,
                value: value,
                animation: animation
            )
        )
    }
}

/// Measures a value from a view's frame, animating a change only when `stablePath`
/// matches the previous measurement. For heights, a width change means the content
/// reflowed (such as the sheet's first layout at a placeholder width, or rotation),
/// so it applies immediately.
private struct AnimatedMeasurement: ViewModifier {
    let path: KeyPath<CGRect, CGFloat>
    let stablePath: KeyPath<CGRect, CGFloat>
    let coordinateSpace: CoordinateSpace
    let value: Binding<CGFloat>
    let animation: Animation?

    // Nil until the first measurement, so that one never animates
    @State private var stableValue: CGFloat?

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self, of: { geometry in
            geometry.frame(in: coordinateSpace)
        }, action: { frame in
            let isStable = frame[keyPath: stablePath] == stableValue
            stableValue = frame[keyPath: stablePath]

            let newValue = frame[keyPath: path]
            guard value.wrappedValue != newValue else { return }
            if isStable {
                withAnimation(animation) {
                    value.wrappedValue = newValue
                }
            } else {
                value.wrappedValue = newValue
            }
        })
    }
}
