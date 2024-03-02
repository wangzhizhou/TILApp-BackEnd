@testable import App
import XCTVapor

final class CategoryTests: XCTestCase {
    
    let categoriesURI = "/api/categories/"
    
    let categoryName = "Teenager"
    
    var app: Application!
    
    override func setUp() async throws {
        app = try await Application.testable()
    }
    
    override func tearDown() async throws {
        app.shutdown()
    }
    
    func testCategoriesCanBeRetrievedFromAPI() async throws {
        
        let category = try await Category.create(name: categoryName, on: app.db)
        
        _ = try await Category.create(on: app.db)
        
        try app.test(.GET, categoriesURI, afterResponse: { response in
            let categories = try response.content.decode([App.Category].self)
            XCTAssertEqual(categories.count, 2)
            XCTAssertEqual(categories[0].name, categoryName)
            XCTAssertEqual(categories[0].id, category.id)
        })
    }
    
    func testCategoryCanBeSavedWithAPI() async throws {
        
        let category = Category(name: categoryName)
        
        try app.test(.POST, categoriesURI, beforeRequest: { request in
            try request.content.encode(category)
        }, afterResponse: { response in
            let receivedCategory = try response.content.decode(Category.self)
            XCTAssertEqual(receivedCategory.name, categoryName)
            XCTAssertNotNil(receivedCategory.id)
            
            try app.test(.GET, categoriesURI, afterResponse: { response in
                let categories = try response.content.decode([App.Category].self)
                XCTAssertEqual(categories.count, 1)
                XCTAssertEqual(categories[0].name, categoryName)
                XCTAssertEqual(categories[0].id, receivedCategory.id)
            })
        })
    }
    
    func testGettingASingleCategoryFromTheAPI() async throws {
        
        let category = try await Category.create(name: categoryName, on: app.db)
        
        try app.test(.GET, "\(categoriesURI)\(category.id!)", afterResponse: { response in
            let returnedCategory = try response.content.decode(Category.self)
            XCTAssertEqual(returnedCategory.name, categoryName)
            XCTAssertEqual(returnedCategory.id, category.id)
        })
    }
    
    func testGettingACategoriesAcronymsFromTheAPI() async throws {
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        let acronym = try await Acronym.create(short: acronymShort, long: acronymLong, on: app.db)
        let acronym2 = try await Acronym.create(on: app.db)
        
        let category = try await Category.create(name: categoryName, on: app.db)
        
        try await app.test(.POST, "/api/acronyms/\(acronym.id!)/categories/\(category.id!)")
        try await app.test(.POST, "/api/acronyms/\(acronym2.id!)/categories/\(category.id!)")
        
        try app.test(.GET, "\(categoriesURI)\(category.id!)/acronyms", afterResponse: { response in
            let acronyms = try response.content.decode([Acronym].self)
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].id, acronym.id)
            XCTAssertEqual(acronyms[0].short, acronymShort)
            XCTAssertEqual(acronyms[0].long, acronymLong)
        })
    }
}
