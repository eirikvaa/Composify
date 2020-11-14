//
//  HomeView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            Text("Studio")
                .tabItem {
                    VStack {
                        Image(systemName: "record.circle")
                        Text("Record")
                    }
                }
            Text("Settings")
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
