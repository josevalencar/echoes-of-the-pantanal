//
//  Animal.swift
//  Echoes Of The Pantanal
//
//  Created by José Vitor Alencar on 23/02/26.
//

// Data model for Pantanal wildlife species.

import SwiftUI

struct Animal: Identifiable, Equatable {
    let id: String
    let name: String
    let scientificName: String
    let imageName: String?  // Asset catalog image name (nil for distractors without images)
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
        imageName: "harpy",
        soundFile: "harpia",
        direction: .up,
        conservationFact: "The Harpy Eagle is the largest raptor in the Americas. Its powerful talons can exert over 500 PSI of pressure — stronger than a wolf's bite.",
        hints: [
            "This bird hunts from the canopy, soaring above the trees.",
            "Its call is a series of sharp, piercing whistles.",
            "Named after the harpies of Greek mythology."
        ]
    )
    
    static let scarletMacaw = Animal(
        id: "scarlet_macaw",
        name: "Scarlet Macaw",
        scientificName: "Ara macao",
        imageName: "macaw",
        soundFile: "arara-vermelha",
        direction: .left,
        conservationFact: "The Scarlet Macaw can live up to 75 years in the wild. Their powerful beaks can crack Brazil nuts — one of the hardest nuts in the world.",
        hints: [
            "This bird is famous for its vibrant red, yellow and blue plumage.",
            "It lives in pairs or small flocks in the forest canopy.",
            "One of the most colorful birds in the Americas."
        ]
    )
    
    static let jabiru = Animal(
        id: "jabiru",
        name: "Jabiru",
        scientificName: "Jabiru mycteria",
        imageName: "jaburu",
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
        imageName: "jaguar",
        soundFile: "onca-pintada",
        direction: .right,
        conservationFact: "The Jaguar has the strongest bite of all big cats. Unlike other cats, it kills prey by piercing the skull with its canines. The Pantanal hosts the densest jaguar population on Earth.",
        hints: [
            "The largest cat in the Americas.",
            "Its call is a deep, resonant growl.",
            "An apex predator that even hunts caimans."
        ]
    )
    
    static let allAnimals: [Animal] = [harpyEagle, scarletMacaw, jabiru, jaguar]
    
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
        imageName: nil,
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
    
    static let caiman = Animal(
        id: "caiman",
        name: "Yacare Caiman",
        scientificName: "Caiman yacare",
        imageName: nil,
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
    
    static let toucan = Animal(
        id: "toucan",
        name: "Toco Toucan",
        scientificName: "Ramphastos toco",
        imageName: nil,
        soundFile: "",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let hyacinthMacaw = Animal(
        id: "hyacinth_macaw",
        name: "Hyacinth Macaw",
        scientificName: "Anodorhynchus hyacinthinus",
        imageName: nil,
        soundFile: "",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let giantOtter = Animal(
        id: "giant_otter",
        name: "Giant Otter",
        scientificName: "Pteronura brasiliensis",
        imageName: nil,
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let anaconda = Animal(
        id: "anaconda",
        name: "Yellow Anaconda",
        scientificName: "Eunectes notaeus",
        imageName: nil,
        soundFile: "",
        direction: .right,
        conservationFact: "",
        hints: []
    )
    
    static let tapir = Animal(
        id: "tapir",
        name: "South American Tapir",
        scientificName: "Tapirus terrestris",
        imageName: nil,
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let rhea = Animal(
        id: "rhea",
        name: "Greater Rhea",
        scientificName: "Rhea americana",
        imageName: nil,
        soundFile: "",
        direction: .down,
        conservationFact: "",
        hints: []
    )
    
    // MARK: - Distractor Animals with Sound (for Image → Sound challenges)
    
    static let greatKiskadee = Animal(
        id: "great_kiskadee",
        name: "Great Kiskadee",
        scientificName: "Pitangus sulphuratus",
        imageName: nil,
        soundFile: "bemtevi",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let chachalaca = Animal(
        id: "chachalaca",
        name: "Chaco Chachalaca",
        scientificName: "Ortalis canicollis",
        imageName: nil,
        soundFile: "aracua",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let wailingFrog = Animal(
        id: "wailing_frog",
        name: "Wailing Frog",
        scientificName: "Physalaemus albonotatus",
        imageName: nil,
        soundFile: "ra-chorona",
        direction: .down,
        conservationFact: "",
        hints: []
    )
}
