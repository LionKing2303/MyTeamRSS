//
//  Repository.swift
//  MyTeamRSS
//
//  Created by Arie Peretz on 02/01/2021.
//  Copyright © 2021 Arie Peretz. All rights reserved.
//

import Foundation
import Combine

protocol Repository {
    var feedPublisher: PassthroughSubject<Model, Never> { get }
    func fetchFeed()
}

class RSSRepository: NSObject, Repository, XMLParserDelegate {
    var cancellables = Set<AnyCancellable>()
    let startItemPublisher = PassthroughSubject<String, Never>()
    let valueItemPublisher = PassthroughSubject<String, Never>()
    let endItemPublisher = PassthroughSubject<String, Never>()
    var isInsideItem: Bool = false
    let titlePublisher = PassthroughSubject<String,Never>()
    let linkPublisher = PassthroughSubject<String,Never>()
    let feedPublisher = PassthroughSubject<Model,Never>()
    
    override init() {
        super.init()
        self.setPublishers()
    }
    
    func setPublishers() {
        value(for: "title")
            .sink { (value) in
                self.titlePublisher.send(value)
            }
            .store(in: &cancellables)
        value(for: "link")
            .sink { (value) in
                self.linkPublisher.send(value)
            }
            .store(in: &cancellables)
                
        Publishers.Zip(titlePublisher,linkPublisher)
            .map { (title,link) -> Model in
                Model(title: title, link: link)
            }
            .sink { (model) in
                self.feedPublisher.send(model)
            }
            .store(in: &cancellables)
    }
    
    func fetchFeed() {
        guard let url = URL(string: "https://www.one.co.il/cat/coop/xml/rss/newsfeed.aspx?t=1"), let parser: XMLParser = XMLParser(contentsOf: url) else { return }

        
        parser.delegate = self
        parser.parse()
    }
    
    func value(for key: String) -> AnyPublisher<String, Never> {
        return Publishers.CombineLatest3(startItemPublisher, valueItemPublisher, endItemPublisher)
            .filter { _ in
                self.isInsideItem
            }
            .filter { (start,_,_) in
                start == key
            }
            .filter { (_,_,end) in
                end == key
            }
            .filter { (start, _, end) in
                start == end
            }
            .map { (_,value,_) in
                value
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: -- XMLParser Delegate Methods
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "item" {
            isInsideItem = true
        }
        startItemPublisher.send(elementName)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            isInsideItem = false
        }
        endItemPublisher.send(elementName)
    }
    
//    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
//        if let cdblock = NSString(data: CDATABlock, encoding: String.Encoding.utf8.rawValue) as String?{
//
//        }
//    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        valueItemPublisher.send(string)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
    }

}
