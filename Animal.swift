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
        conservationFact: "The Harpy Eagle needs trees over 40 meters tall to nest. When old-growth forest disappears, so does it.",
        hints: [
            "Listen closely. The sound is coming from above.",
            "A bird with claws stronger than any other. It lives in the tallest trees.",
            "The biggest eagle in the Americas."
        ]
    )
    
    static let scarletMacaw = Animal(
        id: "scarlet_macaw",
        name: "Scarlet Macaw",
        scientificName: "Ara macao",
        imageName: "macaw",
        soundFile: "arara-vermelha",
        direction: .left,
        conservationFact: "Scarlet Macaws mate for life. A pair can stay together for decades, returning to the same nesting tree every year.",
        hints: [
            "One of the loudest birds in the forest.",
            "Its beak is strong enough to crack a Brazil nut.",
            "A large parrot that can live up to 75 years."
        ]
    )
    
    static let jabiru = Animal(
        id: "jabiru",
        name: "Jabiru",
        scientificName: "Jabiru mycteria",
        imageName: "jaburu",
        soundFile: "tuiuiu",
        direction: .down,
        conservationFact: "The Jabiru builds nests so heavy they can weigh 500 kg. The same nest is used for generations.",
        hints: [
            "This bird is the symbol of the Pantanal wetlands.",
            "It doesn't sing. It claps its beak.",
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
        conservationFact: "The Pantanal is home to the largest jaguar population on Earth. As the wetlands shrink, their last great refuge disappears.",
        hints: [
            "You feel this sound before you hear it.",
            "The biggest cat in the Americas.",
            "It hunts caimans in the river."
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
        imageName: "tucan",
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
    
    static let owl = Animal(
        id: "owl",
        name: "Owl",
        scientificName: "Strigidae",
        imageName: "owl",
        soundFile: "",
        direction: .up,
        conservationFact: "",
        hints: []
    )
    
    static let parakeet = Animal(
        id: "parakeet",
        name: "Parakeet",
        scientificName: "Psittacidae",
        imageName: "parakeet",
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let parrot = Animal(
        id: "parrot",
        name: "Parrot",
        scientificName: "Amazona aestiva",
        imageName: nil,
        soundFile: "",
        direction: .left,
        conservationFact: "",
        hints: []
    )
    
    static let manedWolf = Animal(
        id: "maned_wolf",
        name: "Maned Wolf",
        scientificName: "Chrysocyon brachyurus",
        imageName: nil,
        soundFile: "",
        direction: .right,
        conservationFact: "",
        hints: []
    )
    
    static let howlerMonkey = Animal(
        id: "howler_monkey",
        name: "Howler Monkey",
        scientificName: "Alouatta caraya",
        imageName: nil,
        soundFile: "",
        direction: .left,
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
