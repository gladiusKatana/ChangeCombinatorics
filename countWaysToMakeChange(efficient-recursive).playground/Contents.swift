//  countWaysToMakeChange(efficient-recursive).playground
//  1st commit Apr. 23, 2019  ∙  Created by Garth Snyder (a.k.a. gladiusKatana ⚔️)


//$ counts the number of ways to make up a given sum with change, using a given number of types of coins (assuming all types are available, up to a given denomination — picture a bank-sized cash register.)

//  setting the parameter 'boosted' to true is what makes the algorithm more efficient, by implementing a lookup table (a dictionary, with 2-tuples as keys) to tabulate values returned from pairs of parameters (amount, denominations) that the function was already called with (thus avoiding redundant tree recursion recalculations.)

//  (It's kind of neat, if you haven't seen Xcode playgrounds in action, to see the processes running during slower computations (to do one, call  countWaysToMakeChange(:), with  boosted: false, and a fairly large value of  amount. Pull the dark-grey sidebar (at-right) leftward to display frequencies of calls.)


//  To use: call on line 83


import UIKit

struct Pair<T: Hashable, U: Hashable>: Hashable {
    let values : (T, U)
    func hash(into hasher: inout Hasher) {
        let (a,b) = values
        hasher.combine(a.hashValue &* 31 &+ b.hashValue)
    }
}

func ==<T:Hashable,U:Hashable>(lhs: Pair<T,U>, rhs: Pair<T,U>) -> Bool { // comparison function
    return lhs.values == rhs.values                                      // for conforming to Equatable protocol
}

var pairMap = Dictionary<Pair<Int,Int>,Int>()


func addToTableOfValues(amount: Int, denominations: Int, ways: Int) {
    let pair = Pair(values:(amount, denominations))
    if pairMap[pair] == nil {
        pairMap[pair] = ways
    }
}

func lookupFromTableOfValues(amount: Int, denominations: Int, ways: Int) -> Int? {
    let pair = Pair(values:(amount, denominations))
    let lookup = pairMap[pair]               //; print("looked up (\(amount), \(denominations)) -> \(lookup)")
    return lookup
}
//---------------
//-------------------------

func countWaysToMakeChange(_ amount: Int, denominations: Int, boosted efficiencyBoost: Bool) -> Int {
    var ways = 0
    
    if efficiencyBoost, let lookupFromTable = lookupFromTableOfValues(amount: amount, denominations: denominations, ways: ways) {
        ways = lookupFromTable
    }
    else {
        if amount < 0 || denominations == 0 {
            ways = 0
        }
        else if amount == 0 {
            ways = 1
        }
        else {
            ways = countWaysToMakeChange(amount, denominations: denominations - 1,
                                         boosted: efficiencyBoost)
                + countWaysToMakeChange(amount - amountOfLargest(denominations), denominations: denominations,
                                        boosted: efficiencyBoost)
        }
    }
    addToTableOfValues(amount: amount, denominations: denominations, ways: ways)
    return ways
}


func amountOfLargest(_ denominations: Int) -> Int {
    switch denominations {
    case 1: return 1
    case 2: return 5
    case 3: return 10
    case 4: return 25
    case 5: return 100
    default: return 0
    }
}

countWaysToMakeChange(391, denominations: 5, boosted: true) // note: if boosed: false, can take a long time to run, and consume a large amount of CPU (see comments at top)...
//  ...To break from a slow computation without quitting, simply set boosted: true & run again



                                            //Notes


//  Lines 17-29 adapted from Stack Overflow user Marek Gregor (see answer: Nov 6 '14 by same): https://stackoverflow.com/questions/24131323/in-swift-can-i-use-a-tuple-as-the-key-in-a-dictionary

//  Inspired by an example from Structure and Interpretation of Computer Programs (section 1.2.2, "Counting change", link below); see below for a Scheme version of this program (no lookup table though, presently) https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-11.html#%_sec_1.2.2
//    https://download.racket-lang.org/ <Here is a good implementation / REPL

/*  In Scheme:

 (define (countWaysToMakeChange amount)
    (define (cwc amount denominations)
      (define (amountsOfLargestUsed denominations)
        (cond ((= denominations 1) 1)
              ((= denominations 2) 5)
              ((= denominations 3) 10)
              ((= denominations 4) 25)
              ((= denominations 5) 100)))
      (cond ((or (< amount 0) (= denominations 0)) 0)
            ((= amount 0) 1)
            (else (+ (cwc amount
                          (- denominations 1))
                     (cwc (- amount
                             (amountsOfLargestUsed denominations))
                          denominations)))))
    (cwc amount 5))
 
*/
