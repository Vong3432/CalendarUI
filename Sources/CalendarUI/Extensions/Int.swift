//
//  File.swift
//  
//
//  Created by Vong Nyuksoon on 27/06/2022.
//

import Foundation

public extension Int {
    func toMonthSymbol() -> String {
        DateFormatter.current.monthSymbols[self - 1]
    }
}
