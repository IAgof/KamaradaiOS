//
//  SongProviderTests.swift
//  Kamarada
//
//  Created by Alejandro Arjonilla Garcia on 6/7/16.
//  Copyright © 2016 Videona. All rights reserved.
//

import XCTest

@testable import Kamarada


class SongProviderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testResourcesAreOkey() {
        let songs = SongProvider().getSongs()
        
        for song in songs{
            XCTAssertNotNil(song.getCoverImage())
            XCTAssertNotNil(song.getSongName())
        }
    }

}
