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
    
    /// The color for today's cell circle.
    /// Default is .blue
    public var colorForTodayCell: Color = .blue
    
    /// The default style option 
    static var original: Self {
        var config = CalendarCellsStyleConfiguration()
        config.colorForTodayCell = .blue
        return config
    }
}
