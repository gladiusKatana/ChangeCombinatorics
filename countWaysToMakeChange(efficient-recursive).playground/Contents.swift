//  countWaysToMakeChange(efficient-recursive).playground
//  1st commit Apr. 24, 2019  ∙  Created by Garth Snyder (a.k.a. gladiusKatana ⚔️)


//$ counts the number of ways to make up a given sum with change, using a given number of types of coins (assuming all types are available, up to a given denomination. Picture a giant cash register.) I prefer to assume the largest coin will be 100 cents (but could have said 200: Canadians have 'toonies'.)

//  the algorithm is made more efficient by setting the parameter 'boosted' to true, which implements a lookup table (a dictionary, with 2-tuples as keys) to tabulate values returned from pairs of parameters (amount, denominations) that the function was already called with; thus are the redundant tree recursion function calls avoided.

//  (About Xcode playgrounds: it's kind of neat, if you haven't seen them in action before, to see running processes being tracked (especially during slower computations -- to do one, call  countWaysToMakeChange(:), with  boosted: false, and a fairly large value of  amount. Pull the right sidebar leftward if it isn't already displaying frequencies of calls.)


//  To use the function: line 86.
//  All monetary values are in CENTS.


import UIKit

struct Pair<T: Hashable, U: Hashable>: Hashable {
    let values : (T, U)
    func hash(into hasher: inout Hasher) {
        let (a,b) = values
        hasher.combine(a.hashValue &* 31 &+ b.hashValue)
    }
}

//------------------------- // code between these bars is for the lookup table 'boosting';
//------------------------- // counting algorithm is below
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
//-------------------------
//------------------------- // counting algorithm:

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
    if efficiencyBoost{addToTableOfValues(amount: amount, denominations: denominations, ways: ways)}
    return ways
}


func amountOfLargest(_ denominations: Int) -> Int {
    switch denominations {
    case 1: return 1
    case 2: return 5
    case 3: return 10
    case 4: return 25
    case 5: return 100  // return values are in CENTS
    default: return 0
    }
}

countWaysToMakeChange(512, denominations: 5, boosted: true)// amounts are in CENTS
// ❗️ If boosted: false, can take a long time to run, and use a lot of CPU (see comments at top)...
//  ...To break from a slow computation without quitting, simply set boosted: true & run again immediately



                                        //Notes


//  Lines 17-29 adapted from Stack Overflow user Marek Gregor (see answer: Nov 6 '14 by same): https://stackoverflow.com/questions/24131323/in-swift-can-i-use-a-tuple-as-the-key-in-a-dictionary

/*  Inspired by an example from Structure and Interpretation of Computer Programs (section 1.2.2, "Counting change": https://mitpress.mit.edu/sites/default/files/sicp/index.html
 
    ...Here is the same procedure from the text (rewritten slightly), in Scheme. (No 'tabulation boost' yet)

 
 
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
 
 
 ; ...To call the above procedure (for, e.g., amount $654): (countWaysToMakeChange 512)
 
 ; Here is the Scheme implementation I use: https://download.racket-lang.org/ (it has a nice open-source REPL, that makes reading super-easy, with parenthesis-matching & auto-highlighting of definitions, control flow expressions, etc. similar to Xcode's).
 ; To use Racket make sure you specify the language first. (Type '#lang scheme' at-top then hit Run to enter it)

 ; The Scheme version of is program (implemented in Racket) runs just as fast (or faster) than this Swift version in an Xcode Playground... even after setting boosted: true... if the value of the amount is up to ~$700 (by my experimentation).  With boosted: false (comparing apples to apples with two tree recursive processes), the Scheme one is significantly faster, for an amount > ~100.  Of course for small enough amounts they're both fast and for large enough ones, they're both slow and use a lot of resources regardless. I am curious, though, to implement tabulation in the Scheme version and see what it can handle.)*/
