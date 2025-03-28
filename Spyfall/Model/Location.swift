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
    
    var name: String {
        NSLocalizedString(nameKey, comment: "")
    }
    
    var localizedRoles: [String] {
        roles.map { NSLocalizedString($0, comment: "") }
    }
}

enum LocationSets {
    case spyfallOne
    case spyfallTwo
    case spyfallCombined
    case spyfallExtra
    case spyfallAll
    
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
        }
    }
}

var CurrentSelectedLocationSet: LocationSets = .spyfallOne

extension Location {
    static var locationData: [Location] = CurrentSelectedLocationSet.locations
}

