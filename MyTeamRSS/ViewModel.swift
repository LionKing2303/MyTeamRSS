//
//  ViewModel.swift
//  MyTeamRSS
//
//  Created by Arie Peretz on 02/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Combine

class ViewModel: ObservableObject {
    @Published var feed: [Model] = []
    @Published var url: String = ""
    var repository: Repository
    private var cancellables = Set<AnyCancellable>()

    init(repository: Repository) {
        self.repository = repository
        self.repository.feedPublisher
            .sink { (_) in
                
            } receiveValue: { (model) in
                self.feed.append(model)
            }.store(in: &cancellables)


        self.repository.fetchFeed()
    }
    
    func refresh() {
        self.feed = []
        self.repository.fetchFeed()
    }
}
