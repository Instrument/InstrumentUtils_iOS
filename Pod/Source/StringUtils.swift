/*
Copyright (c) 2015, Instrument Marketing, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of the FreeBSD Project.
*/

extension String
{
    static let emailPattern = "^([a-zA-Z0-9_\\-\\.\\+]+)@([a-zA-Z0-9_\\-\\.]+)\\.([a-zA-Z]{2,4})$"
    static var basicNumberFormatter:NSNumberFormatter {
        get {
            if _basicNumberFormatter == nil {
                _basicNumberFormatter = NSNumberFormatter()
                _basicNumberFormatter!.numberStyle = NSNumberFormatterStyle.DecimalStyle
            }
            return _basicNumberFormatter!
        }
    }
    private static var _basicNumberFormatter:NSNumberFormatter?
    private static var _numbersAndDecimalSet = NSCharacterSet(charactersInString: "1234567890.-")
    
    /**
    - Returns: whether the string is a valid email address
    */
    public func isValidEmail() -> Bool
    {
        let regex = try! NSRegularExpression(pattern: String.emailPattern, options: [NSRegularExpressionOptions.CaseInsensitive])
        return regex.numberOfMatchesInString(self, options: [], range: NSMakeRange(0, self.characters.count)) > 0
    }
    
    /**
    - Returns: a double for a string containing a number, where non-numerical characters will be ignored
    */
    public func extractedDoubleValue() -> Double
    {
        return (self.extractedDecimalDigits() as NSString).doubleValue
    }
    
    /**
    - Returns: simple numerical string including minus sign, decimal and digits only
    */
    public func extractedDecimalDigits() -> String
    {
        return self.componentsSeparatedByCharactersInSet(String._numbersAndDecimalSet.invertedSet).joinWithSeparator("")
    }
    
    /**
    A simplified replacement for using NSNumberFormatter, which is a pain to use with text input.
    
    Formatting includes:
    - minus sign and decimal point
    - optional minimum and maximum decimal places
    - optional comma separators
    
    - Returns: Extracted number string from this string with basic formatting
    */
    public func extractedNumberString(decimalPlaces places:Int = 0, decimalPlacesAreFixed:Bool = false, includeCommas:Bool = false) -> String
    {
        var firstPart:String = ""
        var secondPart:String = ""
        if self.rangeOfString(".") != nil || (decimalPlacesAreFixed && places > 0) {
            let parts = self.componentsSeparatedByString(".")
            firstPart = parts.first!.extractedDecimalDigits()
            if places > 0 {
                if parts.count == 2 {
                    secondPart = parts.last!.extractedDecimalDigits()
                }
                if secondPart.characters.count > places {
                    secondPart = secondPart.substringToIndex(secondPart.startIndex.advancedBy(places))
                }
                else if decimalPlacesAreFixed && secondPart.characters.count < places {
                    secondPart += String(count: places - secondPart.characters.count, repeatedValue:Character("0"))
                }
                secondPart = "." + secondPart
            }
        }
        else {
            firstPart = self.extractedDecimalDigits()
        }
        
        if includeCommas {
            
            firstPart = String.basicNumberFormatter.stringFromNumber(firstPart.extractedDoubleValue())!
        }
        return (self.characters.first == "-" ? "-" : "") + (firstPart + secondPart)
    }
}
