//
//  Models.swift
//  Amigo
//
//  Created by Adam Venturella on 6/29/15.
//  Copyright © 2015 BLITZ. All rights reserved.
//

import Foundation
import CoreData
import Amigo

// ---- To One ----
// A `People` can only have 1 dog and 1 Cat

class Dog: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

class Cat: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

class People: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
    dynamic var dog: Dog!
    dynamic var cat: Cat!
}


// ---- One To Many ----
// We only allow 1 `Author` per `Post`
// But an author can have Many Posts

class Author: AmigoModel {
    dynamic var id: NSNumber!
    dynamic var firstName: String!
    dynamic var lastName: String!
}

class Post: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var title: String!
    dynamic var author: Author!
}


// ---- Many To Many ----
// A Parent can have Many Children
// and children can have Many Parents

class Parent: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

class Child: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

// ---- Many To Many (through model) ----

class Workout: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

class WorkoutExercise: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var label: String!
}

class WorkoutMeta: AmigoModel{
    dynamic var id: NSNumber!
    dynamic var duration: NSNumber!
    dynamic var position: NSNumber!
    dynamic var exercise: WorkoutExercise!
    dynamic var workout: Workout!
}