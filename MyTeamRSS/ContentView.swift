//
//  ContentView.swift
//  MyTeamRSS
//
//  Created by Arie Peretz on 02/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import SwiftUI
import SafariServices

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showSafari = false
    @State var url: String?
    
    var body: some View {
        VStack {
            HStack {
                Text("ONE")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button {
                    self.viewModel.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.primary)
                }

            }
            .padding()
        List {
            ForEach(self.viewModel.feed, id: \.self) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Text(item.title)
                            .multilineTextAlignment(.trailing)
                    }
                    Button(action: {
                        self.viewModel.url = item.link
                        self.showSafari = true
                    }) {
                        Text("קרא כתבה")
                            .font(.footnote)
                    }
                }
            }
        }
        .sheet(isPresented: $showSafari) {
            SafariView(url:URL(string: self.viewModel.url)!)
        }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(repository: RSSRepository()))
    }
}
