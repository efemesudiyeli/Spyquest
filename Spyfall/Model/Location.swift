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

extension Location {
    static let locationData: [Location] = [
        Location(
            nameKey: "Beach",
            roles: ["Beach Waitress", "Kite Surfer", "Lifeguard", "Thief", "Beach Photographer", "Ice Cream Trucker Driver", "Beach Goer"]),
        Location(
            nameKey: "Broadway Theater",
            roles: ["Coat Check Manager", "Prompter", "Cashier", "Director", "Actor", "Backstage Crew", "Audience Member"]),
        Location(
            nameKey: "Casino",
            roles: ["Bartender", "Head Security Guard", "Bouncer", "Manager", "Hustler", "Dealer", "Gambler"]),
        Location(
            nameKey: "Circus Tent",
            roles: ["Acrobat", "Animal Trainer", "Magician", "Fire Eater", "Clown", "Juggler", "Visitor"]),
        Location(
            nameKey: "Corporate Party",
            roles: ["Entertainer", "Manager", "Unwanted Guest", "Owner", "Secretary", "Delivery Boy", "Accountant"]),
        Location(
            nameKey: "Art Museum",
            roles: ["Ticket Seller", "Student", "Visitor", "Teacher", "Security Guard", "Painter", "Art Collector", "Art Critic", "Photographer", "Tourist"]),
        Location(
            nameKey: "Baseball Stadium",
            roles: ["Pitcher", "Catcher", "Commenter", "Spectator", "Security Guard", "Umpire", "Food Vendor", "Manager", "First Baseman", "Shortstop", "Outfielder", "Second Baseman", "Third Baseman", "Mascot", "Team Owner"]),
        Location(
            nameKey: "Bank",
            roles: ["Armored Car Driver", "Manager", "Consultant", "Robber", "Security Guard", "Teller", "Customer"]),
        Location(
            nameKey: "Hotel",
            roles: ["Doorman", "Security Guard", "Manager", "Housekeeper", "Bartender", "Bellman", "Customer"]),
        Location(
            nameKey: "Restaurant",
            roles: ["Musician", "Bouncer", "Hostess", "Head Chef", "Food Critic", "Waiter", "Customer"]),
        Location(
            nameKey: "Mechanic Shop",
            roles: ["Manager", "Tire Specialist", "Biker", "Car Owner", "Car Wash Operator", "Electrician", "Auto Mechanic"]),
        Location(
            nameKey: "Vineyard",
            roles: ["Gardener", "Gourmet Guide", "Winemaker", "Exporter", "Butler", "Wine Taster", "Sommelier", "Owner", "Vineyard Manager"]),
        Location(
            nameKey: "Construction Site",
            roles: ["Free-Roaming Toddler", "Contractor", "Crane Driver", "Trespasser", "Safety Officer", "Electrician", "Engineer", "Architect", "Construction Worker"]),
        Location(
            nameKey: "Hospital",
            roles: ["Nurse", "Doctor", "Anesthesiologist", "Intern", "Therapist", "Surgeon", "Patient"]),
        Location(
            nameKey: "Military Base",
            roles: ["Deserter", "Colonel", "Medic", "Sniper", "Officer", "Tank Engineer", "Soldier"]),
        Location(
            nameKey: "Police Station",
            roles: ["Detective", "Lawyer", "Journalist", "Criminalist", "Archivist", "Criminal", "Patrol Officer"]),
        Location(
            nameKey: "Library",
            roles: ["Old Man", "Journalist", "Author", "Volunteer", "Know-It-All", "Student", "Librarian", "Loudmouth", "Book Fanatic", "Nerd"]),
        Location(
            nameKey: "Jail",
            roles: ["Wrongly Accused Man", "CCTV Operator", "Guard", "Visitor", "Lawyer", "Janitor", "Jailkeeper", "Criminal", "Correction Officer", "Maniac"]),
        Location(
            nameKey: "Airplane",
            roles: ["First Class Passenger", "Air Marshal", "Mechanic", "Flight Attendant", "Co-Pilot", "Captain", "Economy Class Passenger"]),
        Location(
            nameKey: "Passenger Train",
            roles: ["Mechanic", "Border Patrol", "Train Attendant", "Restaurant Chef", "Train Driver", "Stoker", "Passenger"]),
        Location(
            nameKey: "Submarine",
            roles: ["Cook", "Commander", "Sonar Technician", "Electronics Technician", "Radioman", "Navigator", "Sailor"]),
        Location(
            nameKey: "Pirate Ship",
            roles: ["Cook", "Deckhand", "Cannoneer", "Prisoner", "Cabin Boy", "Captain", "Sailor"]),
        Location(
            nameKey: "Cathedral",
            roles: ["Priest", "Beggar", "Sinner", "Tourist", "Sponsor", "Chorister", "Parishioner"]),
        Location(
            nameKey: "Cemetery",
            roles: ["Priest", "Grave Robber", "Poet", "Mourner", "Gatekeeper", "Dead Person", "Relative", "Flower Seller", "Grave Digger", "Goth Girl/Boy"]),
        Location(
            nameKey: "Space Station",
            roles: ["Engineer", "Alien", "Pilot", "Commander", "Scientist", "Doctor", "Space Tourist"]),
        Location(
            nameKey: "Retirement Home",
            roles: ["Relative", "Cribbage Player", "Old Person", "Nurse", "Janitor", "Cook", "Psychologist"]),
        Location(
            nameKey: "Subway",
            roles: ["Tourist", "Subway Operator", "Pregnant Lady", "Pickpocket", "Cleaner", "Businessman", "Old Lady", "Performer"]),
        Location(
            nameKey: "Gas Station",
            roles: ["Car Enthusiast", "Service Attendant", "Shopkeeper", "Customer", "Car Washer", "Cashier", "Manager"]),
        Location(
            nameKey: "Local Park",
            roles: ["Jogger", "Police", "Child", "Parent", "Gardener", "Vendor"]),
        Location(
            nameKey: "Ski Resort",
            roles: ["Skier", "Ski Lift Operator", "Ski Run Groomer", "Ski Shop Manager", "Ski Instructor"]),
        Location(
            nameKey: "The Last Supper",
            roles: ["Jesus", "Judas", "John the Baptist", "Matthew the Apostle", "Mark the Apostle", "Simon the Apostle"]),
        Location(
            nameKey: "Post-Office",
            roles: ["Mail Man", "Customer", "Mail Sorter", "Security", "Notary", "Janitor"]),
        Location(
            nameKey: "Clue Board Game",
            roles: ["Player", "Miss Scarlet", "Mr. Green", "Colonel Mustard", "Prof. Plum", "Mrs. Peacock", "Mrs. White"]),
        Location(
            nameKey: "Golden Gate Bridge",
            roles: ["Jumper", "Painter", "Driver", "Biker", "Runner", "Maintenance Worker", "Tourist"]),
        Location(
            nameKey: "Brewery",
            roles: ["Brewmaster", "Tour Guide", "Customer", "Bar Back", "Bar Tender", "Manager", "Food Server"])
    ]
}
