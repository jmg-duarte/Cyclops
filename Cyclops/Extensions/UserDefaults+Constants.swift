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
        /// The number of stories to show per feeed page
        static let NumberOfStoriesPerPage = "NumberOfStoriesPerPage"
        /// Whether to show the number of comments per item
        static let ShowNumberOfComments = "ShowNumberOfComments"
        /// Did the user go through the onboarding process
        static let WasOnboarded = "WasOnboarded"
    }

    enum Defaults {
        static let AppTheme: AppTheme = .system
        static let NumberOfStoriesPerPage: Double = 25
        static let ShowNumberOfComments: Bool = false
        static let WasOnboarded: Bool = false
    }
}
