//
//  LocationData.swift
//  Spyfall
//
//  Created by Efe Mesudiyeli on 18.07.2024.
//

import Foundation
import SwiftUI

struct Location: Hashable, Identifiable {
    var id: UUID = UUID()
    let nameKey: String
    let roles: [String]
    let descriptionKey: String
       
       // Varsayılan descriptionKey değeri atandı
       init(nameKey: String, roles: [String], descriptionKey: String = "") {
           self.nameKey = nameKey
           self.roles = roles
           self.descriptionKey = descriptionKey
       }
    
    var description: String {
           // Use NSLocalizedString instead of String(localized:comment:)
           return NSLocalizedString(descriptionKey, comment: "Description for \(nameKey) location")
       }
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }
    
    var localizedRoles: [String] {
        roles.map { NSLocalizedString($0, comment: "") }
    }
}

enum LocationSets: String {
    case spyfallOne = "First Edition"
    case spyfallTwo = "Second Edition"
    case spyfallCombined = "Combined Edition"
    case spyfallExtra = "Extra Edition"
    case spyfallAll = "All Edition"
    case pirateTheme = "Pirates Edition"
    case wildWestTheme = "Wild West Edition"

    
    var locations: [Location] {
        switch self {
        case .spyfallOne:
            return [
                Location(nameKey: "Airplane", roles: [
                    "First Class Passenger",
                    "Air Marshal",
                    "Mechanic",
                    "Air Hostess",
                    "Co-Pilot",
                    "Captain",
                    "Economy Class Passenger"
                ]),
                Location(nameKey: "Bank", roles: [
                    "Armored Car Driver",
                    "Manager",
                    "Consultant",
                    "Robber",
                    "Security Guard",
                    "Teller",
                    "Customer"
                ]),
                Location(nameKey: "Beach", roles: [
                    "Beach Waitress",
                    "Kite Surfer",
                    "Lifeguard",
                    "Thief",
                    "Beach Photographer",
                    "Ice Cream Truck Driver",
                    "Beach Goer"
                ]),
                Location(nameKey: "Broadway Theater", roles: [
                    "Coat Check Lady",
                    "Prompter",
                    "Cashier",
                    "Visitor",
                    "Director",
                    "Actor",
                    "Crewman"
                ]),
                Location(nameKey: "Cathedral", roles: [
                    "Priest",
                    "Beggar",
                    "Sinner",
                    "Tourist",
                    "Sponsor",
                    "Chorister",
                    "Parishioner"
                ]),
                Location(nameKey: "Circus Tent", roles: [
                    "Acrobat",
                    "Animal Trainer",
                    "Magician",
                    "Fire Eater",
                    "Clown",
                    "Juggler",
                    "Visitor"
                ]),
                Location(nameKey: "Corporate Party", roles: [
                    "Entertainer",
                    "Manager",
                    "Unwanted Guest",
                    "Owner",
                    "Secretary",
                    "Delivery Boy",
                    "Accountant"
                ]),
                Location(nameKey: "Crusader Army", roles: [
                    "Monk",
                    "Imprisoned Saracen",
                    "Servant",
                    "Bishop",
                    "Squire",
                    "Archer",
                    "Knight"
                ]),
                Location(nameKey: "Casino", roles: [
                    "Bartender",
                    "Head Security Guard",
                    "Bouncer",
                    "Manager",
                    "Hustler",
                    "Dealer",
                    "Gambler"
                ]),
                Location(nameKey: "Day Spa", roles: [
                    "Stylist",
                    "Masseuse",
                    "Manicurist",
                    "Makeup Artist",
                    "Dermatologist",
                    "Beautician",
                    "Customer"
                ]),
                Location(nameKey: "Embassy", roles: [
                    "Security Guard",
                    "Secretary",
                    "Ambassador",
                    "Tourist",
                    "Refugee",
                    "Diplomat",
                    "Government Official"
                ]),
                Location(nameKey: "Hospital", roles: [
                    "Nurse",
                    "Doctor",
                    "Anesthesiologist",
                    "Intern",
                    "Therapist",
                    "Surgeon",
                    "Patient"
                ]),
                Location(nameKey: "Hotel", roles: [
                    "Doorman",
                    "Security Guard",
                    "Manager",
                    "Housekeeper",
                    "Bartender",
                    "Bellman",
                    "Customer"
                ]),
                Location(nameKey: "Military Base", roles: [
                    "Deserter",
                    "Colonel",
                    "Medic",
                    "Sniper",
                    "Officer",
                    "Tank Engineer",
                    "Soldier"
                ]),
                Location(nameKey: "Movie Studio", roles: [
                    "Stunt Man",
                    "Sound Engineer",
                    "Camera Man",
                    "Director",
                    "Costume Artist",
                    "Producer",
                    "Actor"
                ]),
                Location(nameKey: "Ocean Liner", roles: [
                    "Cook",
                    "Captain",
                    "Bartender",
                    "Musician",
                    "Waiter",
                    "Mechanic",
                    "Rich Passenger"
                ]),
                Location(nameKey: "Passenger Train", roles: [
                    "Mechanic",
                    "Border Patrol",
                    "Train Attendant",
                    "Restaurant Chef",
                    "Train Driver",
                    "Stroker",
                    "Passenger"
                ]),
                Location(nameKey: "Pirate Ship", roles: [
                    "Cook",
                    "Slave",
                    "Cannoneer",
                    "Tied Up Prisoner",
                    "Cabin Boy",
                    "Brave Captain",
                    "Sailor"
                ]),
                Location(nameKey: "Polar Station", roles: [
                    "Medic",
                    "Expedition Leader",
                    "Biologist",
                    "Radioman",
                    "Hydrologist",
                    "Meteorologist",
                    "Geologist"
                ]),
                Location(nameKey: "Police Station", roles: [
                    "Detective",
                    "Lawyer",
                    "Journalist",
                    "Criminalist",
                    "Archivist",
                    "Criminal",
                    "Patrol Officer"
                ]),
                Location(nameKey: "Restaurant", roles: [
                    "Musician",
                    "Bouncer",
                    "Hostess",
                    "Head Chef",
                    "Food Critic",
                    "Waiter",
                    "Customer"
                ]),
                Location(nameKey: "School", roles: [
                    "Gym Teacher",
                    "Principal",
                    "Security Guard",
                    "Janitor",
                    "Cafeteria Lady",
                    "Maintainence Man",
                    "Student"
                ]),
                Location(nameKey: "Service Station", roles: [
                    "Manager",
                    "Tire Specialist",
                    "Biker",
                    "Car Owner",
                    "Car Wash Operator",
                    "Electrician",
                    "Auto Mechanic"
                ]),
                Location(nameKey: "Space Station", roles: [
                    "Engineer",
                    "Alien",
                    "Pilot",
                    "Commander",
                    "Scientist",
                    "Doctor",
                    "Space Tourist"
                ]),
                Location(nameKey: "Submarine", roles: [
                    "Cook",
                    "Commander",
                    "Sonar Technician",
                    "Electronics Technician",
                    "Radioman",
                    "Navigator",
                    "Sailor"
                ]),
                Location(nameKey: "Supermarket", roles: [
                    "Cashier",
                    "Butcher",
                    "Janitor",
                    "Security Guard",
                    "Food Sample Demonstrator",
                    "Shelf Stocker",
                    "Customer"
                ]),
                Location(nameKey: "University", roles: [
                    "Graduate Student",
                    "Professor",
                    "Dean",
                    "Psychologist",
                    "Maintenance Man",
                    "Janitor",
                    "Student"
                ]),
            ]
        case .spyfallTwo:
            return [
                Location(
                    nameKey: "Amusement Park",
                    roles: [
                        "Ride Operator",
                        "Parent",
                        "Food Vendor",
                        "Cashier",
                        "Happy Child",
                        "Annoying Child",
                        "Teenager",
                        "Janitor",
                        "Security Guard"
                    ]),
                Location(
                    nameKey: "Art Museum",
                    roles: [
                        "Ticket Seller",
                        "Student",
                        "Visitor",
                        "Teacher",
                        "Security Guard",
                        "Painter",
                        "Art Collector",
                        "Art Critic",
                        "Photographer",
                        "Tourist"
                    ]),
                Location(
                    nameKey: "Candy Factory",
                    roles: [
                        "Pastry Chef",
                        "Visitor",
                        "Taster",
                        "Supply Worker",
                        "Oompa Loompa",
                        "Inspector",
                        "Machine Operator",
                    ]),
                Location(
                    nameKey: "Cat Show",
                    roles: [
                        "Judge",
                        "Cat-Handler",
                        "Veterinarian",
                        "Security Guard",
                        "Cat Trainer",
                        "Crazy Cat Lady",
                        "Animal Lover",
                        "Cat Owner",
                        "Cat",
                    ]),
                Location(
                    nameKey: "Cemetery",
                    roles: [
                        "Priest",
                        "Gothic Girl",
                        "Grave Robber",
                        "Poet",
                        "Mourner",
                        "Gatekeeper",
                        "Dead Person",
                        "Relative",
                        "Flower Seller",
                        "Grave Digger"
                    ]),
                Location(
                    nameKey: "Coal Mine",
                    roles: [
                        "Safety Officer",
                        "Miner",
                        "Overseer",
                        "Dump Truck Operator",
                        "Driller",
                        "Coordinator",
                        "Blasting Engineer",
                        "Solid Waste Engineer",
                        "Worker",
                    ]),
                Location(
                    nameKey: "Construction Site",
                    roles: [
                        "Free-Roaming Toddler",
                        "Contractor",
                        "Crane Driver",
                        "Trespasser",
                        "Safety Officer",
                        "Electrician",
                        "Engineer",
                        "Architect",
                        "Construction Worker",
                    ]),
                Location(
                    nameKey: "Gaming Convention",
                    roles: [
                        "Blogger",
                        "Cosplayer",
                        "Gamer",
                        "Exhibitor",
                        "Collector",
                        "Child",
                        "Security Guard",
                        "Geek",
                        "Shy Person",
                        "Famous Person"
                    ]),
                Location(
                    nameKey: "Gas Station",
                    roles: [
                        "Car Enthusiast",
                        "Service Attendant",
                        "Shopkeeper",
                        "Customer",
                        "Car Washer",
                        "Cashier",
                        "Climate Change Activist",
                        "Service Attendant",
                        "Manager",
                    ]),
                Location(
                    nameKey: "Harbor Docks",
                    roles: [
                        "Loader",
                        "Salty Old Pirate",
                        "Captain",
                        "Sailor",
                        "Fisherman",
                        "Exporter",
                        "Cargo Overseer",
                        "Cargo Inspector",
                        "Smuggler",
                    ]),
                Location(
                    nameKey: "Ice Hockey Stadium",
                    roles: [
                        "Hockey Fan",
                        "Medic",
                        "Hockey Player",
                        "Food Vendor",
                        "Security Guard",
                        "Goaltender",
                        "Coach",
                        "Referee",
                        "Spectator",
                    ]),
                Location(
                    nameKey: "Ice Hockey Stadium",
                    roles: [
                        "Hockey Fan",
                        "Medic",
                        "Hockey Player",
                        "Food Vendor",
                        "Security Guard",
                        "Goaltender",
                        "Coach",
                        "Referee",
                        "Spectator",
                    ]),
                Location(
                    nameKey: "Jail",
                    roles: [
                        "Wrongly Accused Man",
                        "CCTV Operator",
                        "Guard",
                        "Visitor",
                        "Lawyer",
                        "Janitor",
                        "Jailkeeper",
                        "Criminal",
                        "Correctional Officer",
                        "Maniac"
                    ]),
                Location(
                    nameKey: "Jazz Club",
                    roles: [
                        "Bouncer",
                        "Drummer",
                        "Pianist",
                        "Saxophonist",
                        "Singer",
                        "Jazz Fanatic",
                        "Dancer",
                        "Barman",
                        "VIP",
                        "Waiter"
                    ]),
                Location(
                    nameKey: "Library",
                    roles: [
                        "Old Man",
                        "Journalist",
                        "Author",
                        "Volunteer",
                        "Know-It-All",
                        "Student",
                        "Librarian",
                        "Loudmouth",
                        "Book Fanatic",
                        "Nerd"
                    ]),
                Location(
                    nameKey: "Night Club",
                    roles: [
                        "Regular",
                        "Bartender",
                        "Security Guard",
                        "Dancer",
                        
                        "Party Girl",
                        "Model",
                        "Muscly Guy",
                        "Drunk Person",
                        "Shy Person"
                    ]),
                Location(
                    nameKey: "Race Track",
                    roles: [
                        "Team Owner",
                        "Driver",
                        "Engineer",
                        "Spectator",
                        "Referee",
                        "Mechanic",
                        "Food Vendor",
                        "Commenter",
                        "Bookmaker",
                        "Shy Person"
                    ]),
                Location(
                    nameKey: "Retirement Home",
                    roles: [
                        "Relative",
                        "Cribbage Player",
                        "Old Person",
                        "Nurse",
                        "Janitor",
                        "Cook",
                        "Blind Person",
                        "Psychologist",
                    ]),
                Location(
                    nameKey: "Rock Concert",
                    roles: [
                        "Dancer",
                        "Singer",
                        "Fan",
                        "Guitarist",
                        "Drummer",
                        "Stage Diver",
                        "Security Guard",
                        "Bassist",
                        "Technical Support"
                    ]),
                Location(
                    nameKey: "Sightseeing Bus",
                    roles: [
                        "Old Man",
                        "Lone Tourist",
                        "Driver",
                        "Annoying Child",
                        "Tourist",
                        "Tour Guide",
                        "Photographer",
                        "Lost Person",
                    ]),
                Location(
                    nameKey: "Stadium",
                    roles: [
                        "Medic",
                        "Hammer Thrower",
                        "Athlete",
                        "Commentor",
                        "Spectator",
                        "Security Guard",
                        "Referee",
                        "Food Vendor",
                        "High Jumper",
                        "Sprinter"
                    ]),
                Location(
                    nameKey: "Subway",
                    roles: [
                        "Tourist",
                        "Subway Operator",
                        "Ticket Inspector",
                        "Pregnant Lady",
                        "Pickpocket",
                        "Cleaner",
                        "Businessman",
                        "Ticket Seller",
                        "Old Lady",
                        "Blind Person"
                    ]),
                Location(
                    nameKey: "The U.N.",
                    roles: [
                        "Diplomat",
                        "Interpreter",
                        "Blowhard",
                        "Tourist",
                        "Napping Delegate",
                        "Journalist",
                        "Secretary of State",
                        "Speaker",
                        "Secretary-General",
                        "Lobbyist"
                    ]),
                Location(
                    nameKey: "Vineyard",
                    roles: [
                        "Gardener",
                        "Gourmet Guide",
                        "Winemaker",
                        "Exporter",
                        "Butler",
                        "Wine Taster",
                        "Sommelier",
                        "Rich Lord",
                        "Vineyard Manager",
                        "Enologist"
                    ]),
                Location(
                    nameKey: "Wedding",
                    roles: [
                        "Ring Bearer",
                        "Groom",
                        "Bride",
                        "Officiant",
                        "Photographer",
                        "Flower Girl",
                        "Father of the Bride",
                        "Wedding Crasher",
                        "Best Man",
                        "Relative"
                    ]),
                Location(
                    nameKey: "Zoo",
                    roles: [
                        "Zookeeper",
                        "Visitor",
                        "Photographer",
                        "Child",
                        "Veterinarian",
                        "Tourist",
                        "Food Vendor",
                        "Cashier",
                        "Researcher",
                    ]),
            ]
        case .spyfallCombined:
            return LocationSets.spyfallOne.locations + LocationSets.spyfallTwo.locations
        case .spyfallExtra:
            return [
                Location(nameKey: "Aquarium", roles: [
                    "Marine Biologist",
                    "Tour Guide",
                    "Photographer",
                    "Visitor",
                    "Cashier",
                    "Security Guard",
                    "Diver"
                ]),
                Location(nameKey: "Ballet Theater", roles: [
                    "Ballet Dancer",
                    "Choreographer",
                    "Audience Member",
                    "Musician",
                    "Costume Designer",
                    "Stage Manager",
                    "Director"
                ]),
                Location(nameKey: "Brewery", roles: [
                    "Brewmaster",
                    "Bartender",
                    "Tour Guide",
                    "Quality Control",
                    "Brewer",
                    "Delivery Driver",
                    "Customer"
                ]),
                Location(nameKey: "Bus Stop", roles: [
                    "Bus Driver",
                    "Commuter",
                    "Tourist",
                    "Student",
                    "Vendor",
                    "Homeless Person",
                    "Street Performer"
                ]),
                Location(nameKey: "Carnival", roles: [
                    "Ride Operator",
                    "Ticket Seller",
                    "Visitor",
                    "Clown",
                    "Food Vendor",
                    "Game Operator",
                    "Security Guard"
                ]),
                Location(nameKey: "Castle", roles: [
                    "King",
                    "Queen",
                    "Knight",
                    "Jester",
                    "Servant",
                    "Cook",
                    "Noble"
                ]),
                Location(nameKey: "Coffee Shop", roles: [
                    "Barista",
                    "Manager",
                    "Customer",
                    "Freelancer",
                    "Student",
                    "Musician",
                    "Cashier"
                ]),
                Location(nameKey: "Comedy Club", roles: [
                    "Comedian",
                    "Audience Member",
                    "Bartender",
                    "Waiter",
                    "Host",
                    "Technician",
                    "Security Guard"
                ]),
                Location(nameKey: "Cowboy Ranch", roles: [
                    "Cowboy",
                    "Ranch Owner",
                    "Horse Trainer",
                    "Veterinarian",
                    "Cook",
                    "Visitor",
                    "Blacksmith"
                ]),
                Location(nameKey: "Cruise Ship", roles: [
                    "Captain",
                    "Cruise Director",
                    "Bartender",
                    "Chef",
                    "Housekeeper",
                    "Entertainer",
                    "Passenger"
                ]),
                Location(nameKey: "Dentist Office", roles: [
                    "Dentist",
                    "Dental Hygienist",
                    "Receptionist",
                    "Patient",
                    "Dental Assistant",
                    "Lab Technician",
                    "Manager"
                ]),
                Location(nameKey: "Fashion Show", roles: [
                    "Model",
                    "Designer",
                    "Photographer",
                    "Makeup Artist",
                    "Hairstylist",
                    "Audience Member",
                    "Journalist"
                ]),
                Location(nameKey: "Farm", roles: [
                    "Farmer",
                    "Rancher",
                    "Farmhand",
                    "Veterinarian",
                    "Produce Seller",
                    "Visitor",
                    "Mechanic"
                ]),
                Location(nameKey: "Fire Station", roles: [
                    "Firefighter",
                    "Chief",
                    "Dispatcher",
                    "Paramedic",
                    "Mechanic",
                    "Trainer",
                    "Visitor"
                ]),
                Location(nameKey: "Flower Shop", roles: [
                    "Florist",
                    "Delivery Person",
                    "Customer",
                    "Shop Owner",
                    "Cashier",
                    "Gardener",
                    "Wedding Planner"
                ]),
                Location(nameKey: "Golf Course", roles: [
                    "Golfer",
                    "Groundskeeper",
                    "Clubhouse Manager",
                    "Instructor",
                    "Visitor",
                    "Bartender"
                ]),
                Location(nameKey: "Helicopter", roles: [
                    "Pilot",
                    "Co-Pilot",
                    "Mechanic",
                    "Passenger",
                    "Tour Guide",
                    "Paramedic",
                    "News Reporter"
                ]),
                Location(nameKey: "Hiking Trail", roles: [
                    "Hiker",
                    "Guide",
                    "Photographer",
                    "Wildlife Enthusiast",
                    "Ranger",
                    "Camper",
                    "Scout"
                ]),
                Location(nameKey: "Hot Air  Balloon", roles: [
                    "Pilot",
                    "Tourist",
                    "Photographer",
                    "Ground Crew",
                    "Mechanic",
                    "Event Organizer",
                    "Vendor"
                ]),
                Location(nameKey: "Jewelry Store", roles: [
                    "Jeweler",
                    "Customer",
                    "Security Guard",
                    "Shop Owner",
                    "Cashier",
                    "Salesperson",
                    "Appraiser"
                ]),
                Location(nameKey: "Laundromat", roles: [
                    "Customer",
                    "Attendant",
                    "Manager",
                    "Repair Technician",
                    "Student",
                    "Parent",
                    "Vendor"
                ]),
                Location(nameKey: "Music Festival", roles: [
                    "Performer",
                    "Audience Member",
                    "Security Guard",
                    "Vendor",
                    "Stage Crew",
                    "Organizer",
                    "Technician"
                ]),
                Location(nameKey: "Observatory", roles: [
                    "Astronomer",
                    "Tour Guide",
                    "Visitor",
                    "Technician",
                    "Student",
                    "Researcher",
                    "Photographer"
                ]),
                Location(nameKey: "Orphanage", roles: [
                    "Orphan",
                    "Caretaker",
                    "Volunteer",
                    "Visitor",
                    "Cook",
                    "Teacher",
                    "Nurse"
                ]),
                Location(nameKey: "Rodeo", roles: [
                    "Rider",
                    "Clown",
                    "Audience Member",
                    "Announcer",
                    "Rancher",
                    "Vendor",
                    "Trainer"
                ]),
                Location(nameKey: "Science Lab", roles: [
                    "Scientist",
                    "Lab Technician",
                    "Researcher",
                    "Student",
                    "Security Guard",
                    "Administrator"
                ])
            ]
        case .spyfallAll:
            return LocationSets.spyfallOne.locations + LocationSets.spyfallTwo.locations + LocationSets.spyfallExtra.locations
            case .pirateTheme:
                return [
                    Location(nameKey: "Treacherous Sea", roles: [
                        "Captain",
                        "Pirate",
                        "Commander",
                        "Treasure Hunter",
                        "Sailor",
                        "Ship Engineer",
                        "Prisoner"
                    ], descriptionKey: "A mysterious region surrounded by rocky shores and the deep dark waters of the sea. Dangerous storms and mysterious creatures are on the hunt."),
                    
                    Location(nameKey: "Hell Island", roles: [
                        "Islander",
                        "Ghost Pirate",
                        "Storm Watcher",
                        "Hunter",
                        "Lonely Captain",
                        "Secret Warrior",
                        "Cursed"
                    ], descriptionKey: "An island surrounded by high mountains and constantly erupting lava, only brave pirates dare set foot here. Every step brings the threat of death."),
                    
                    Location(nameKey: "Blue Waters Harbor", roles: [
                        "Merchant",
                        "City Guard",
                        "Ship Captain",
                        "Pirate Hunter",
                        "Diver",
                        "Great Warrior",
                        "Bureaucrat"
                    ], descriptionKey: "A lively hub for trade and the central point where authorities battle pirates. The harbor is filled with colorful ships and a bustling marketplace."),
                    
                    Location(nameKey: "Legendary Treasure Cave", roles: [
                        "Treasure Guardian",
                        "Map Maker",
                        "Sorcerer",
                        "Legendary Pirate",
                        "Cave Protector",
                        "Warrior",
                        "Thief"
                    ], descriptionKey: "A hidden treasure in ancient caves, surrounded by historical legends. But every treasure is guarded by deadly traps."),
                    
                    Location(nameKey: "Treehouse Island", roles: [
                        "Pirate Leader",
                        "Investor",
                        "Secret Enemy",
                        "Islander",
                        "Protector",
                        "Rebel",
                        "Ship Guide"
                    ], descriptionKey: "A secret base hidden among giant trees. The tall trees are home to hanging houses and dangerous traps, making survival a challenge."),
                    
                    Location(nameKey: "Wild Ocean Depths", roles: [
                        "Sea Monster",
                        "Diver",
                        "Pirate Captain",
                        "Target Seeker",
                        "Sailor",
                        "Treasure Hunter",
                        "Slave"
                    ], descriptionKey: "A dark ocean abyss, home to lost underwater cities and sea monsters. Only the bravest sailors survive in these depths."),
                    
                    Location(nameKey: "Pirate Fortress", roles: [
                        "Fortress Commander",
                        "Pirate Captain",
                        "Rebel",
                        "Treasure Guardian",
                        "Great Pirate",
                        "Pirate Soldier",
                        "Slave"
                    ], descriptionKey: "A fortress built atop a giant rock, defended against government forces by pirates and rebels. It is surrounded by massive walls and strong guards."),
                    
                    Location(nameKey: "Great Storm Island", roles: [
                        "Captain",
                        "Storm Bringer",
                        "Sailor",
                        "Pirate",
                        "Legendary Cannoneer",
                        "Cruel Queen",
                        "Prisoner"
                    ], descriptionKey: "An island famous for its rapidly changing weather, where storms constantly rage, and survival is nearly impossible."),
                    
                    Location(nameKey: "Mysterious Coral Reef", roles: [
                        "Coral Hunter",
                        "Sea Sorcerer",
                        "Treasure Hunter",
                        "Pirate Captain",
                        "First Mate",
                        "Ship Engineer",
                        "Diver"
                    ], descriptionKey: "A region surrounded by large coral reefs, each corner hiding new dangers. Lost ancient treasures and forgotten sea creatures lie hidden among the corals."),
                    
                    Location(nameKey: "Dark Reef Island", roles: [
                        "Pirate Gang Leader",
                        "Evil Knight",
                        "Sea Monster",
                        "Pirate Guide",
                        "Rebel",
                        "Investor",
                        "Swordsman"
                    ], descriptionKey: "Famous for its dark reputation, this island is a center for forbidden trade and bloody gangs. Its interior is filled with abandoned villages, and danger is always close."),
                    
                    Location(nameKey: "Golden Shallows", roles: [
                        "Treasure Hunter",
                        "Pirate Captain",
                        "Sailor",
                        "Trapsmith",
                        "Pirate Warrior",
                        "Fighter",
                        "Wounded"
                    ], descriptionKey: "A region surrounded by shallow waters and rocks, filled with sunken ships full of gold. Navigating here is perilous, and survival is incredibly difficult."),
                    
                    Location(nameKey: "Endless Isles", roles: [
                        "Captain",
                        "Guardian",
                        "Sailor",
                        "Treasure Seeker",
                        "Pirate",
                        "Sorcerer",
                        "Secret Rebel"
                    ], descriptionKey: "A labyrinthine region formed by a chain of massive islands. Each island holds its own secret, many of which have yet to be discovered."),
                    
                    Location(nameKey: "Blue Sands", roles: [
                        "Pirate Captain",
                        "Island Guardian",
                        "Pirate Merchant",
                        "Sailor",
                        "Treasure Seeker",
                        "Storm Guardian",
                        "Investor"
                    ], descriptionKey: "A beautiful yet dangerous island surrounded by pure white sands and crystal-clear waters. A treasure is always guarded somewhere on the shores, but few can reach it."),
                    
                    Location(nameKey: "Cursed Rocks", roles: [
                        "Pirate Ghost",
                        "Sailor",
                        "City Guard",
                        "Sorcerer",
                        "Old Captain",
                        "Seaman",
                        "Poisonous Beast"
                    ], descriptionKey: "An abandoned rocky region that hides the darkest secrets of the sea. Ghostly pirates and dangerous sea monsters haunt the area."),
                    
                    Location(nameKey: "Vicious Storms", roles: [
                        "Storm Captain",
                        "Ship Engineer",
                        "Trapsmith",
                        "Sea Monster",
                        "Storm Seer",
                        "Pirate Warrior",
                        "Sailor"
                    ], descriptionKey: "A region where storms constantly shatter sea routes and the ocean's surface is tumultuous. Surviving here is nearly impossible, but those who endure the storms can gain great rewards."),
                    
                    Location(nameKey: "Dead Pirates' Vow", roles: [
                        "Ghost Pirate",
                        "Prisoner",
                        "Warrior",
                        "Sailor",
                        "Captain",
                        "Storm Seeker",
                        "Trapsmith"
                    ], descriptionKey: "An island cursed by the spirits of dead pirates. Now a place haunted by ghosts and the ruins of old structures, entering here means certain disappearance."),
                    
                    Location(nameKey: "Sunken Shipwrecks", roles: [
                        "Sunken Ship Captain",
                        "Trapsmith",
                        "Treasure Hunter",
                        "Ship Engineer",
                        "Sailor",
                        "Bloody Captain",
                        "Secret Villain"
                    ], descriptionKey: "The remnants of ancient ships lying deep beneath the ocean. Sunken treasures and dangerous sea creatures are hidden among the wreckage."),
                    
                    Location(nameKey: "Thieves' Haven", roles: [
                        "Merchant",
                        "Great Thief",
                        "Pirate Captain",
                        "Sailor",
                        "Trapsmith",
                        "Warrior",
                        "Treasure Seeker"
                    ], descriptionKey: "Once the pirate capital, now an abandoned pirate base, inhabited only by thieves and fugitives."),
                    
                    Location(nameKey: "Bloody City", roles: [
                        "Pirate Leader",
                        "Islander",
                        "Rebel",
                        "Treasure Seeker",
                        "Sailor",
                        "Secret Sorcerer",
                        "Warrior"
                    ], descriptionKey: "A pirate city where the people struggle against tyrannical rule. Constant conflicts and robberies take place throughout the city."),
                    
                    Location(nameKey: "The Lost Island", roles: [
                        "Treasure Hunter",
                        "Pirate",
                        "Sailor",
                        "Secret Enemy",
                        "Bloody Captain",
                        "Seaman",
                        "Rebel"
                    ], descriptionKey: "A forgotten island, abandoned by those searching for its lost treasures. Dangers and traps lurk at every corner.")
                ]
        
            case .wildWestTheme:
                    return [
                        Location(nameKey: "Gold Mine", roles: [
                            "Cowboy",
                            "Gold Prospector",
                            "Outlaw",
                            "Miner",
                            "Sheriff",
                            "Desert Native",
                            "Bad Guy"
                        ], descriptionKey: "The gold mine is a treacherous place located deep within the desert. Many brave souls have ventured in to find riches, but few return. It is filled with hidden tunnels, dangerous caves, and the echo of old, forgotten treasure."),
                        
                        Location(nameKey: "Dusty Town", roles: [
                            "Town Sheriff",
                            "Outlaw",
                            "Bartender",
                            "Gunslinger",
                            "Bounty Hunter",
                            "Shopkeeper",
                            "Street Urchin"
                        ], descriptionKey: "Dusty Town is a small, run-down western town. The sun never seems to stop beating down on the main street, where saloons, gunfights, and secret deals take place daily. It's a place where danger lurks in every shadow, and everyone is watching their backs."),
                        
                        Location(nameKey: "Cactus Valley", roles: [
                            "Cowboy",
                            "Stagecoach Driver",
                            "Rancher",
                            "Outlaw",
                            "Trail Scout",
                            "Desert Traveler",
                            "Hunter"
                        ], descriptionKey: "Cactus Valley is a vast, arid expanse surrounded by towering cacti. The heat is relentless, and only the toughest survive here. Outlaws use the valley to hide from the law, while travelers and ranchers brave the harsh conditions for their livelihood."),
                        
                        Location(nameKey: "Sheriff’s Office", roles: [
                            "Sheriff",
                            "Deputy",
                            "Outlaw",
                            "Bounty Hunter",
                            "Prisoner",
                            "Town Doctor",
                            "Gunslinger"
                        ], descriptionKey: "The Sheriff’s Office is the law’s last stand in the Wild West. It's a small building at the edge of town, where prisoners are held and justice is served. Behind its walls, fierce gunfights are often fought as outlaws try to escape their fate."),
                        
                        Location(nameKey: "Tumbleweed Canyon", roles: [
                            "Outlaw",
                            "Rancher",
                            "Prospector",
                            "Cowboy",
                            "Gunslinger",
                            "Explorer",
                            "Bandit"
                        ], descriptionKey: "Tumbleweed Canyon is a narrow, winding gorge surrounded by jagged rocks and endless tumbleweeds. It’s known as a hideout for bandits and outlaws, where they plan their next robbery. Only the bravest venture into its depths, seeking riches or revenge."),
                        
                        Location(nameKey: "Saloons and Bars", roles: [
                            "Bartender",
                            "Gunslinger",
                            "Cowboy",
                            "Outlaw",
                            "Drunken Gambler",
                            "Dancer",
                            "Sheriff"
                        ], descriptionKey: "The saloons and bars are the heart of social life in the Wild West. Here, gamblers test their luck, cowboys share their stories, and outlaws plot their next crime. The sound of piano music, clinking glasses, and the occasional gunshot fills the air as tensions rise."),
                        
                        Location(nameKey: "Horse Ranch", roles: [
                            "Rancher",
                            "Cowboy",
                            "Cattle Driver",
                            "Outlaw",
                            "Veterinarian",
                            "Farmer",
                            "Blacksmith"
                        ], descriptionKey: "The horse ranch is a place of hard work and reward. Cowboys and ranchers care for the horses and cattle that roam the vast plains. It’s a peaceful spot unless an outlaw gang decides to raid the ranch for supplies or livestock."),
                        
                        Location(nameKey: "Train Robbery Site", roles: [
                            "Outlaw",
                            "Bounty Hunter",
                            "Train Engineer",
                            "Sheriff",
                            "Passenger",
                            "Gang Member"
                        ], descriptionKey: "Train robbery sites are notorious in the Wild West. A moving train filled with gold and valuables is a tempting target for outlaws. The narrow, winding tracks are the perfect place for a high-speed chase and a dangerous heist."),
                        
                        Location(nameKey: "Bandit Camp", roles: [
                            "Outlaw",
                            "Gunslinger",
                            "Explorer",
                            "Bounty Hunter",
                            "Torturer",
                            "Spy",
                            "Leader"
                        ], descriptionKey: "The bandit camp is hidden deep in the forest or canyons, a haven for criminals. Here, outlaws plan their raids, divide spoils, and sometimes get caught in bloody infighting. It’s a dangerous place for anyone who isn’t part of the gang."),
                        
                        Location(nameKey: "Rancher's House", roles: [
                            "Rancher",
                            "Farmer",
                            "Cowboy",
                            "Cook",
                            "Servant",
                            "Neighbor",
                            "Outlaw"
                        ], descriptionKey: "The rancher’s house is a small, humble abode where a hardworking family lives. It is surrounded by vast fields and animals. Though peaceful, it can quickly become the target of an outlaw raid or a dispute with neighboring ranchers."),
                        
                        Location(nameKey: "Old Church", roles: [
                            "Priest",
                            "Outlaw",
                            "Traveler",
                            "Churchgoer",
                            "Bandit",
                            "Witness",
                            "Gunslinger"
                        ], descriptionKey: "The old church stands as a symbol of hope amidst the chaos of the Wild West. It has witnessed many stories—of love, loss, and redemption. Some come here for peace, while others seek shelter or hide from the law."),
                        
                        Location(nameKey: "Abandoned Town", roles: [
                            "Explorer",
                            "Outlaw",
                            "Ghost",
                            "Ranger",
                            "Historian",
                            "Bandit",
                            "Drifter"
                        ], descriptionKey: "The abandoned town is a desolate place, once filled with life but now left to decay. Buildings crumble, and the streets are eerily silent. It’s a place where only the bravest dare to explore, seeking old secrets or forgotten treasures."),
                        
                        Location(nameKey: "Cattle Ranch", roles: [
                            "Rancher",
                            "Cowboy",
                            "Cattle Driver",
                            "Outlaw",
                            "Gunslinger",
                            "Farmer",
                            "Blacksmith"
                        ], descriptionKey: "The cattle ranch is a vast open space where cowboys and ranchers work tirelessly to tend to herds of cattle. It’s a harsh environment with extreme weather, but it’s also a critical part of life in the West."),
                        
                        Location(nameKey: "Mountain Pass", roles: [
                            "Explorer",
                            "Outlaw",
                            "Sheriff",
                            "Traveler",
                            "Scout",
                            "Gunslinger",
                            "Hunter"
                        ], descriptionKey: "The mountain pass is a dangerous route through the rugged mountains. It’s a shortcut for those who know the land, but it’s fraught with peril. Bandits often ambush travelers here, hoping to steal their goods."),
                        
                        Location(nameKey: "Fort", roles: [
                            "Soldier",
                            "Captain",
                            "Outlaw",
                            "Native Warrior",
                            "Explorer",
                            "Medic",
                            "Scout"
                        ], descriptionKey: "The fort is a military stronghold, built to protect settlers from attacks by outlaws or native tribes. It’s a place of order and discipline, but its soldiers are often stretched thin as they face constant threats."),
                        
                        Location(nameKey: "Ghost Town", roles: [
                            "Ghost",
                            "Outlaw",
                            "Explorer",
                            "Traveler",
                            "Bandit",
                            "Sheriff",
                            "Gunslinger"
                        ], descriptionKey: "The ghost town is a relic of the past, now empty and haunted by the spirits of those who once lived here. The creaking wood and broken windows tell tales of a once-thriving community, now swallowed by time."),
                        
                        Location(nameKey: "Train Station", roles: [
                            "Stationmaster",
                            "Passenger",
                            "Outlaw",
                            "Engineer",
                            "Bounty Hunter",
                            "Traveler",
                            "Ticket Seller"
                        ], descriptionKey: "The train station is a busy hub of activity, where travelers come and go, and where secrets are exchanged. Trains arrive with goods, people, and opportunities, but they also bring danger and conflict."),
                        
                        Location(nameKey: "Mine Shaft", roles: [
                            "Miner",
                            "Prospector",
                            "Outlaw",
                            "Gunslinger",
                            "Bounty Hunter",
                            "Explorer",
                            "Laborer"
                        ], descriptionKey: "The mine shaft is a deep, dark hole in the ground, filled with the potential for wealth and the danger of collapse. It’s a treacherous place where miners risk their lives in search of precious metals."),
                        
                        Location(nameKey: "Outlaw Hideout", roles: [
                            "Outlaw",
                            "Leader",
                            "Scout",
                            "Gunslinger",
                            "Spy",
                            "Bounty Hunter",
                            "Gang Member"
                        ], descriptionKey: "The outlaw hideout is hidden deep in the wilds, a safe place for criminals on the run. It’s a place where plans are made, supplies are stored, and alliances are forged. But it’s also a place of constant paranoia, as outlaws fear the law catching up to them."),
                        
                        Location(nameKey: "Desert Oasis", roles: [
                            "Traveler",
                            "Outlaw",
                            "Rancher",
                            "Explorer",
                            "Cattle Driver",
                            "Merchant",
                            "Gunslinger"
                        ], descriptionKey: "The desert oasis is a rare, life-saving spot in the vast, unforgiving desert. It’s a place where travelers stop to rest, refill their water, and gather strength before continuing their journey across the barren land."),
                        
                        Location(nameKey: "Windmill", roles: [
                            "Farmer",
                            "Rancher",
                            "Outlaw",
                            "Traveler",
                            "Merchant",
                            "Gunslinger",
                            "Builder"
                        ], descriptionKey: "The windmill is a symbol of hard work and perseverance in the West. It pumps water for the cattle and provides power for the farm, standing tall against the desert winds. It’s a lifeline in the wilderness."),
                        
                        Location(nameKey: "Bunkhouse", roles: [
                            "Cowboy",
                            "Rancher",
                            "Traveler",
                            "Outlaw",
                            "Servant",
                            "Shopkeeper",
                            "Cook"
                        ], descriptionKey: "The bunkhouse is a modest building where cowboys, ranchers, and travelers rest after long days of hard work. It’s a place of camaraderie, where stories are shared and meals are cooked in the warmth of the fire."),
                        
                        Location(nameKey: "Tavern", roles: [
                            "Bartender",
                            "Gunslinger",
                            "Outlaw",
                            "Cowboy",
                            "Drunken Gambler",
                            "Sheriff",
                            "Traveler"
                        ], descriptionKey: "The tavern is a gathering place for locals and strangers alike. It’s where deals are made, fights are started, and rumors spread. The smell of whiskey and the sound of laughter fill the air as cowboys and outlaws mingle."),
                        
                        Location(nameKey: "Wild West Show", roles: [
                            "Performer",
                            "Gunslinger",
                            "Rancher",
                            "Townsperson",
                            "Outlaw",
                            "Bystander",
                            "Sheriff"
                        ], descriptionKey: "The Wild West Show is a traveling spectacle that brings the thrills of cowboy life to town. There are daring stunts, trick shooting, and dramatic reenactments of famous gunfights. It’s a celebration of the West’s rugged, exciting history.")
                    ]

 
        }
    }
}

var CurrentSelectedLocationSet: LocationSets = .spyfallOne

extension Location {
    static var locationData: [Location] = CurrentSelectedLocationSet.locations
}

