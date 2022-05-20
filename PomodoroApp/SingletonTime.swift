//
//  SingletonTime.swift
//  PomodoroApp
//
//  Created by Даниил Смирнов on 20.05.2022.
//

import Foundation

final class SingletonTime {
    static let shared = SingletonTime()
    
    private init() {}
    var time = 4
}
