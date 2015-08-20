//: Playground - noun: a place where people can play

import UIKit
import CloudKitManager

var str = "Hello, playground"

// Objects from the BT4U API
var stopObjects = Parser.stopsForRoute("PRG")


// find which stops are missing from database
for stop in stopObjects {
    stop.code
}