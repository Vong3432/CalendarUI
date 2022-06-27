//
//  TintViewModifier.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation
import SwiftUI

@available(iOS 15.4, *)
struct TintViewModifier: ViewModifier {
    var color: Color?
    
    func body(content: Content) -> some View {
        content
            .tint(color)
    }
}

struct AccentColorViewModifier: ViewModifier {
    var color: Color?
    
    func body(content: Content) -> some View {
        content
            .accentColor(color)
    }
}


extension View {
    @ViewBuilder
    func customTint(_ color: Color?) -> some View {
        if #available(iOS 15.4, *) {
            self.modifier(TintViewModifier(color: color))
        } else {
            self.modifier(AccentColorViewModifier(color: color))
        }
    }
}
