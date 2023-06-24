// UserDefaults+Constants.swift
// Created by José Duarte on 11/06/2023
// Copyright (c) 2023

import Foundation

/*
 NOTE: with the upcoming swift macros, this should be a piece of cake to create
 Just use something that can be writen inside an extension like
 ```swift
 extension Ext {
   #entry(AppTheme, .system)
   #entry(NumberOfStoriesPerPage, 25)
 }
 ```
 */
extension UserDefaults {
    enum Keys {
        static let AppTheme = "AppTheme"
        static let NumberOfStoriesPerPage = "NumberOfStoriesPerPage"
    }

    enum Defaults {
        static let AppTheme: AppTheme = .system
        static let NumberOfStoriesPerPage: Double = 25
    }
}
