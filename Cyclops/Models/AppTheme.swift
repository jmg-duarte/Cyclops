// AppTheme.swift
// Created by José Duarte on 18/06/2023
// Copyright (c) 2023

import SwiftUI

enum AppTheme: Int, Identifiable, CaseIterable {
    var id: Self { self }
    case system
    case light
    case dark

    var name: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return .none
        case .light: return .light
        case .dark: return .dark
        }
    }
}
