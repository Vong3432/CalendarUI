//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation
import SwiftUI

/// Style configuration day cells in CalendarUI
public struct CalendarCellsStyleConfiguration {
    
    public init() {} 
    
    /// The color for today's cell circle.
    /// Default is .blue
    public var colorForTodayCell: Color = .blue
}

public extension CalendarCellsStyleConfiguration {
    /// The default style option
    /// - Tag: CalendarCellsStyleConfigurationOriginal
    static var original: Self {
        var config = CalendarCellsStyleConfiguration()
        config.colorForTodayCell = .blue
        return config
    }
}

