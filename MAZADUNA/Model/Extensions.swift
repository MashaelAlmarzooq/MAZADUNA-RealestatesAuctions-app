//
//  Extensions.swift
//  MAZADUNA
//
//  Created by Tahani Alsubaie on 17/11/21.
//

import Foundation

extension Date {
    
}

extension String {
    func dateUsingFormate(_ formate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        return dateFormatter.date(from: self) ?? Date()
    }
}

extension Double {
    func getDateString(_ formate: String) -> String {
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate
        return dateFormatter.string(from: date)
    }
}
