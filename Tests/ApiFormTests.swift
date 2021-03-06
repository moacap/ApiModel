//
//  ApiFormTests.swift
//  APIModel
//
//  Created by Craig Heneveld on 1/14/16.
//
//

import XCTest
import ApiModel
import Alamofire
import OHHTTPStubs
import RealmSwift

class ApiFormTests: XCTestCase {
    var timeout: TimeInterval = 10
    var testRealm: Realm!
    var host = "http://you-dont-party.com"
    
    override func setUp() {
        
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        
        testRealm = try! Realm()
        
        ApiSingleton.setInstance(ApiManager(config: ApiConfig(host: self.host)))
    }
    
    override func tearDown() {
        
        super.tearDown()
        
        try! testRealm.write {
            self.testRealm.deleteAll()
        }
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testSimpleFindArray() {
        
        var theResponse: [Post]?
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            let stubPath = OHPathForFile("posts.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        
        Api<Post>.findArray { response, _ in
            theResponse = response
            
            XCTAssertEqual(response.count, 2)
            XCTAssertEqual(response.first!.id, "1")
            XCTAssertEqual(response.last!.id, "2")
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        
        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testGetWithServerFailure() {
        
        var theResponse: ApiModelResponse<Post>?
        let readyExpectation = self.expectation(description: "ready")
        
        
        stub(condition: {_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".data(using: String.Encoding.utf8)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.get("/v1/posts.json") { response in
            theResponse = response
            
            XCTAssertEqual(response.errors! as NSObject, ["base" : ["An unexpected server error occurred"]] as NSObject)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }

        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testFindArrayWithServerFailure() {
        
        var theResponse: [Post]?
        let readyExpectation = self.expectation(description: "ready")
        
        
        stub(condition: {_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".data(using: String.Encoding.utf8)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.findArray { response, _ in
            theResponse = response
            
            XCTAssertNotNil(response)
            
            XCTAssertEqual(response.count, 0)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }

        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNotNil(theResponse, "Received data should not be nil")
        }
    }
    
    func testFindWithServerFailure() {
        
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            return OHHTTPStubsResponse(data:"Something went wrong!".data(using: String.Encoding.utf8)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.find { post, response in

            XCTAssertEqual("An unexpected server error occurred", response.errorMessages?.first ?? "")
            XCTAssertNil(post)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Received data should be nil")
        }
    }
    
    
    func testFindWithServerFailureWithErrorMessage() {
        
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            return OHHTTPStubsResponse(data:"{\"post\": {\"errors\": [\"Something went wrong!\"]}}".data(using: String.Encoding.utf8)!, statusCode: 500, headers: nil)
        }
        
        Api<Post>.find { post, response in
            
            XCTAssertEqual("Something went wrong!", response.errorMessages?.first ?? "")
            XCTAssertNotNil(post)
            
            readyExpectation.fulfill()
            OHHTTPStubs.removeAllStubs()
        }
        
        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Received data should be nil")
        }
    }
    
    func testSaveWithModelValidationErrors() {
        
        let readyExpectation = self.expectation(description: "ready")
        
        stub(condition: {_ in true}) { request in
            let stubPath = OHPathForFile("post_with_error.json", type(of: self))
            return fixture(filePath: stubPath!, status: 422, headers: ["Content-Type":"application/json"])
        }
        
        let post = Post()

        let form = Api<Post>(model: post)
        
        form.save { _ in
            XCTAssertTrue(form.hasErrors)
            
            // But what happened? - the server returned meaningful validations but are lost!
            XCTAssertEqual(form.errorMessages, ["An unexpected server error occurred"])

            readyExpectation.fulfill()
            
            OHHTTPStubs.removeAllStubs()
        }
        
        self.waitForExpectations(timeout: self.timeout) { err in
            // By the time we reach this code, the while loop has exited
            // so the response has arrived or the test has timed out
            XCTAssertNil(err, "Received data should be nil")
        }
    }
}
