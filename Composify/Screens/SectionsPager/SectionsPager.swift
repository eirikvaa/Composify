//
//  SectionsPager.swift
//  Composify
//
//  Created by Eirik Vale Aase on 14/11/2020.
//  Copyright © 2020 Eirik Vale Aase. All rights reserved.
//

import SwiftUI
import SwiftUIPager

struct SectionsPager: View {
    @EnvironmentObject var songState: SongState
    @StateObject private var page: Page

    var sections: [Section]
    var currentSection: Section

    init(sections: [Section], currentSection: Section) {
        self.sections = sections
        self.currentSection = currentSection
        self._page = .init(wrappedValue: .withIndex(currentSection.index))
    }

    var body: some View {
        Pager(page: page, data: sections, id: \.id) { section in
            VStack {
                SectionHeaderView(section: section)

                if section.recordings.isEmpty {
                    Spacer()
                    EmptyRecordingsView()
                    Spacer()
                } else {
                    RecordingsView(recordings: Array(section.recordings.freeze()))
                }
            }
        }
        .onPageChanged { index in
            let newCurrentSection = sections.first(where: { $0.index == index })
            songState.select(currentProject: currentSection.project, currentSection: newCurrentSection)
        }
    }
}

struct SectionsPager_Previews: PreviewProvider {
    static var previews: some View {
        SectionsPager(sections: [], currentSection: Section())
            .environmentObject(SongState())
    }
}
