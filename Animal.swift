//
//  Animal.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 16/12/2025.
//

// Data model for Pantanal wildlife species.

import SwiftUI

struct Animal: Identifiable, Equatable {
    let id: String
    let name: String
    let scientificName: String
    let emoji: String
    let soundFile: String
    let direction: Direction
    let conservationFact: String
    let hints: [String]
    
    enum Direction: String {
        case up = "Look up"
        case down = "Look down"
        case left = "Look left"
        case right = "Look right"
        
        var systemImage: String {
            switch self {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .left: return "arrow.left"
            case .right: return "arrow.right"
            }
        }
    }
}

// MARK: - Pantanal Wildlife Catalog

extension Animal {
    static let harpyEagle = Animal(
        id: "harpy_eagle",
        name: "Harpy Eagle",
        scientificName: "Harpia harpyja",
        emoji: "🦅",
        soundFile: "harpia",
        direction: .up,
        conservationFact: "The Harpy Eagle is the largest raptor in the Americas. Its powerful talons can exert over 500 PSI of pressure — stronger than a wolf's bite.",
        hints: [
            "This bird hunts from the canopy, soaring above the trees.",
            "Its call is a series of sharp, piercing whistles.",
            "Named after the harpies of Greek mythology."
        ]
    )
    
    static let howlerMonkey = Animal(
        id: "howler_monkey",
        name: "Howler Monkey",
        scientificName: "Alouatta caraya",
        emoji: "🐒",
        soundFile: "arara-vermelha", // Note: Using available sound
        direction: .left,
        conservationFact: "Howler monkeys produce the loudest calls of any land animal — audible from 5 kilometers away. Their hyoid bone amplifies sound like a natural speaker.",
        hints: [
            "This animal is known for its incredibly loud vocalizations.",
            "It lives in groups in the forest canopy.",
            "The sound resembles a deep, rumbling roar."
        ]
    )
    
    static let jabiru = Animal(
        id: "jabiru",
        name: "Jabiru",
        scientificName: "Jabiru mycteria",
        emoji: "🦩",
        soundFile: "tuiuiu",
        direction: .down,
        conservationFact: "The Jabiru is the tallest flying bird in South America, standing up to 1.5 meters. It's the symbol of the Pantanal and builds nests that can weigh 500 kg.",
        hints: [
            "This bird is the symbol of the Pantanal wetlands.",
            "It makes rhythmic clacking sounds with its bill.",
            "One of the tallest flying birds in the Americas."
        ]
    )
    
    static let jaguar = Animal(
        id: "jaguar",
        name: "Jaguar",
        scientificName: "Panthera onca",
        emoji: "🐆",
        soundFile: "onca-pintada",
        direction: .right,
        conservationFact: "The Jaguar has the strongest bite of all big cats. Unlike other cats, it kills prey by piercing the skull with its canines. The Pantanal hosts the densest jaguar population on Earth.",
        hints: [
            "The largest cat in the Americas.",
            "Its call is a deep, resonant growl.",
            "An apex predator that even hunts caimans."
        ]
    )
    
    static let allAnimals: [Animal] = [harpyEagle, howlerMonkey, jabiru, jaguar]
    
    static func animal(for id: String) -> Animal? {
        allAnimals.first { $0.id == id }
    }
}

// MARK: - Distractor Animals (for wrong answers)

extension Animal {
    static let capybara = Animal(
        id: "capybara",
        name: "Capybara",
        scientificName: "Hydrochoerus hydrochaeris",
        emoji: "🦫",
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
    
    static let caiman = Animal(
        id: "caiman",
        name: "Yacare Caiman",
        scientificName: "Caiman yacare",
        emoji: "🐊",
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
    
    static let toucan = Animal(
        id: "toucan",
        name: "Toco Toucan",
        scientificName: "Ramphastos toco",
        emoji: "🐦",
        soundFile: "",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let macaw = Animal(
        id: "macaw",
        name: "Hyacinth Macaw",
        scientificName: "Anodorhynchus hyacinthinus",
        emoji: "🦜",
        soundFile: "",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let giantOtter = Animal(
        id: "giant_otter",
        name: "Giant Otter",
        scientificName: "Pteronura brasiliensis",
        emoji: "🦦",
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let anaconda = Animal(
        id: "anaconda",
        name: "Yellow Anaconda",
        scientificName: "Eunectes notaeus",
        emoji: "🐍",
        soundFile: "",
        direction: .right,
        conservationFact: "",
        hints: []
    )
    
    static let tapir = Animal(
        id: "tapir",
        name: "South American Tapir",
        scientificName: "Tapirus terrestris",
        emoji: "🐘",
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let rhea = Animal(
        id: "rhea",
        name: "Greater Rhea",
        scientificName: "Rhea americana",
        emoji: "🦤",
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
}
