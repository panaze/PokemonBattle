import XCTest
@testable import PokemonApp

class NetworkServiceTests: XCTestCase {
    func testPokemonAPIResponseDecoding() {
        // Real PokeAPI response data for Bulbasaur (from response_example.json)
        let jsonString = """
        {
            "id": 1,
            "name": "bulbasaur",
            "types": [
                {
                    "slot": 1,
                    "type": {
                        "name": "grass",
                        "url": "https://pokeapi.co/api/v2/type/12/"
                    }
                },
                {
                    "slot": 2,
                    "type": {
                        "name": "poison",
                        "url": "https://pokeapi.co/api/v2/type/4/"
                    }
                }
            ],
            "sprites": {
                "back_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
                "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        // Decode the JSON response
        let decoder = JSONDecoder()
        let result = try? decoder.decode(PokemonAPIResponse.self, from: jsonData)
        // Should successfully decode all fields
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.name, "bulbasaur")
        XCTAssertEqual(result?.types.count, 2)
        XCTAssertEqual(result?.types.first?.type.name, "grass")
        XCTAssertEqual(result?.types.last?.type.name, "poison")
        XCTAssertEqual(result?.sprites.frontDefault,
                       "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        XCTAssertEqual(result?.sprites.backDefault,
                       "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png")
    }
}
