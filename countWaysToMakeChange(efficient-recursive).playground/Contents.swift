//  countWaysToMakeChange(efficient-recursive).playground
//  1st commit Apr. 24, 2019  ∙  Created by Garth Snyder (a.k.a. gladiusKatana ⚔️)


//  counts the number of ways to make up a given sum with change, using a given number of types of coins (assuming all types are available, up to a given denomination. Picture a giant cash register.) I prefer to assume the largest coin will be 100 cents (could have said 200 though: Canada has 'toonies'.)

//  to use the function: line 85.  ⬅️
//  all values are in CENTS.

//  *about Xcode playgrounds:
//  it's kind of neat, if you haven't seen them in action before, to see running processes being tracked (especially during slower computations -- to do one, call  countWaysToMakeChange(:), with  boosted: false, and a fairly large value of  amount.  Pull the right sidebar leftward if it isn't already displaying frequencies of calls.

import UIKit

struct Pair<T: Hashable, U: Hashable>: Hashable {
    let values : (T, U)
    func hash(into hasher: inout Hasher) {
        let (a,b) = values
        hasher.combine(a.hashValue &* 31 &+ b.hashValue)
    }
}

//------------------------- code between the bars is for lookup table 'boosting'

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
    let lookup = pairMap[pair]      //; print("looked up (\(amount), \(denominations)) -> \(lookup)")
    return lookup
}

//------------------------- counting algorithm

func countWaysToMakeChange(cents amount: Int, denominations: Int, boosted efficiencyBoost: Bool) -> Int {
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
            ways = countWaysToMakeChange(cents: amount,
                                         denominations: denominations - 1,
                                         boosted: efficiencyBoost)
                + countWaysToMakeChange(cents: amount - amountOfLargest(denominations),
                                        denominations: denominations,
                                        boosted: efficiencyBoost)
        }
    }
    if efficiencyBoost{addToTableOfValues(amount: amount, denominations: denominations, ways: ways)}
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

countWaysToMakeChange(cents: 700, denominations: 5, boosted: true)
//                                              ❗️ If boosted: false, can take a long time to run,
//                                                  and use a lot of CPU (see comments at top)...
//                                                  ...To break from a slow computation without quitting,
//                                                  simply set boosted: true & run again immediately

//  (setting 'boosted' to true makes the algorithm more efficient by implementing a lookup table (a dictionary with 2-tuples as keys) to tabulate values returned from pairs of parameters (amount, denominations) that the function was already called with; this avoids the redundant tree recursion function calls.


                                            // Notes

//  Lines 15-29 adapted from Stack Overflow user Marek Gregor (see answer: Nov 6 '14 by same): https://stackoverflow.com/questions/24131323/in-swift-can-i-use-a-tuple-as-the-key-in-a-dictionary

/*  Inspired by an example from Structure and Interpretation of Computer Programs (section 1.2.2, "Counting change": https://mitpress.mit.edu/sites/default/files/sicp/index.html
 
    ...Here is the same procedure from the text (rewritten slightly) in Scheme. (No 'tabulation boost' yet)

 
 
 
 (define (countWaysToMakeChange amount) ; using somewhat Swifty naming
    (define (recursiveCount amount denominations)
      (define (amountsOfLargestUsed denominations)
        (cond ((= denominations 1) 1)
              ((= denominations 2) 5)
              ((= denominations 3) 10)
              ((= denominations 4) 25)
              ((= denominations 5) 100)))
      (cond ((or (< amount 0) (= denominations 0)) 0)
            ((= amount 0) 1)
            (else (+ (recursiveCount amount
                          (- denominations 1))
                     (recursiveCount (- amount
                             (amountsOfLargestUsed denominations))
                          denominations)))))
    (recursiveCount amount 5))

 ; ...Calling the procedure: e.g.:  (countWaysToMakeChange 700)
 
 
 
 
 ; ...and here is the Scheme implementation I use: https://download.racket-lang.org/ (it has a nice open-source REPL, that makes reading super-easy, with parenthesis-matching & auto-highlighting of definitions, control flow expressions, etc. similar to Xcode's).
 ; To use Racket make sure you specify the language first. (Type '#lang scheme' at-top then hit Run to enter it)

 ; 💡observation
 This is interesting.  The Scheme version of this program (implemented in Racket) runs just as fast (or faster) than this Swift version in an Xcode Playground, even after setting boosted: true, if the value of the amount is up to ~$700 (by my experimentation).  With boosted: false -- that is, comparing apples to apples with two tree recursive processes -- the Scheme one is significantly faster, for an amount > ~100.  Of course, for small enough amounts they both take a short time and for large enough ones they both take a long time and use a lot of resources. I am curious, though, to implement tabulation in the Scheme version then see what it can handle.)*/
