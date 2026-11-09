//
//  PreviewStep.swift
//  ContentHuggingBottomSheet
//
//  Created by Jo Lingenfelter on 11/9/26.
//


enum PreviewStep {
    case intro, choose, done

    /// The step the footer button advances to, or `nil` on the last step.
    var next: PreviewStep? {
        switch self {
        case .intro: .choose
        case .choose: .done
        case .done: nil
        }
    }

    /// The step the back button returns to, or `nil` where going back doesn't apply.
    var previous: PreviewStep? {
        switch self {
        case .choose: .intro
        case .intro, .done: nil
        }
    }

    var footerTitle: String {
        switch self {
        case .intro: "Continue"
        case .choose: "Turn On"
        case .done: "Done"
        }
    }
}
