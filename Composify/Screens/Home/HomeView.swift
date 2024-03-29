//
//  HomeView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI

extension HomeView {
    enum TabItem {
        case record
        case library
    }
}

struct HomeView: View {
    @State private var selectedTab: TabItem = .record

    var body: some View {
        TabView(selection: $selectedTab) {
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "record.circle")
                }
                .tag(TabItem.record)

            NavigationStack {
                LibraryView()
                    .navigationDestination(for: Project.self) { project in
                        ProjectView(project: project)
                    }
            }
            .tabItem {
                Label("Library", systemImage: "music.note.list")
            }
            .tag(TabItem.library)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(WorkingProjectState())
    }
}
