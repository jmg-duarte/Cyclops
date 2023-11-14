//
//  BorderedLabelStyle.swift
//  Cyclops
//
//  Created by José Duarte on 14/11/2023.
//

import SwiftUI

class BorderedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        Label(configuration)
            .padding(8)
            .background(Color(UIColor.tertiarySystemFill))
            .cornerRadius(8)
    }
}

extension LabelStyle where Self == BorderedLabelStyle {
    static var send: BorderedLabelStyle { .init() }
}
