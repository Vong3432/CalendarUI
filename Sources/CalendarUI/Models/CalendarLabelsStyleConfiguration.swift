//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation
import SwiftUI

/// Style configuration labels  in CalendarUI
public struct CalendarLabelsStyleConfiguration {
    
    public init() {}
    
    /// The color for weekday labels.
    /// Default is .secondary
    public var dayOfWeekColor: Color = .secondary
}

public extension CalendarLabelsStyleConfiguration {
    /// The default style option
    /// - Tag: CalendarLabelsStyleConfigurationOriginal
    static var original: Self {
        var config = CalendarLabelsStyleConfiguration()
        config.dayOfWeekColor = .secondary
        return config
    }
}
