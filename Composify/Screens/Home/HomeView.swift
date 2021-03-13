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

    var body: some View {
        NavigationView {
            VStack {
                if let currentProject = viewModel.currentProject {
                    if let sections = viewModel.getSections(in: currentProject) {
                        SectionsPager(sections: sections)
                        Spacer()
                        RecordButton {
                            print("Start recording!")
                        }
                    } else {
                        Text("No sections in project \(currentProject.title)")
                    }
                } else {
                    Text("No projects to show.")
                }
            }
            .navigationBarTitle("Composify", displayMode: .inline)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
