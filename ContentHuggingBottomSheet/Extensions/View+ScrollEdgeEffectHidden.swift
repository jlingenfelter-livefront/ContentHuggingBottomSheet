//
//  View+ScrollEdgeEffectHidden.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/10/26.
//

import SwiftUI

extension Backport where Content: View {
    @ContentBuilder
    func scrollEdgeEffectHidden(_ hidden: Bool = true, for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26, *) {
            content.scrollEdgeEffectHidden(hidden, for: edges)
        } else {
            content
        }
    }
}
