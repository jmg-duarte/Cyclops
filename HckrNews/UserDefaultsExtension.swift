//
//  UserDefaultsExtension.swift
//  HckrNews
//
//  Created by José Duarte on 11/06/2023.
//

import Foundation

extension UserDefaults {
    struct Keys {
        private init() {}
        
        static let NumberOfStoriesPerPage = "NumberOfStoriesPerPage"
    }
    
    class var numberOfStoriesPerPage: Double {
        if UserDefaults.standard.object(forKey: Keys.NumberOfStoriesPerPage) == nil {
            UserDefaults.standard.set(10, forKey: Keys.NumberOfStoriesPerPage)
        }
        return UserDefaults.standard.double(forKey: Keys.NumberOfStoriesPerPage)
    }
}
