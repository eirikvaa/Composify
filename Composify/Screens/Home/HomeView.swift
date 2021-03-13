//
//  HomeView.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI
import SwiftUIPager

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingNewProjectView = false

    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.state {
                case let .loaded(project, sections):
                    SectionsPager(sections: sections)
                    Spacer()
                    RecordButton {
                        print("Add recording to \(project.title)")
                    }
                case .noSections(let project):
                    Text("No sections in project \(project.title)")
                case .noProjects:
                    Button(action: {
                        isShowingNewProjectView = true
                    }, label: {
                        Text("Add project")
                    })
                    .sheet(isPresented: $isShowingNewProjectView) {
                        NewProjectView()
                    }
                }
            }
            .navigationBarTitle("Composify", displayMode: .inline)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
