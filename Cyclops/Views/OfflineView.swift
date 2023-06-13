//
//  OfflineView.swift
//  Cyclops
//
//  Created by José Duarte on 13/06/2023.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
            Text("No network detected.")
        }
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
