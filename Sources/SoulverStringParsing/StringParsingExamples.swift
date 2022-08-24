import SoulverCore

/// Requires Swift 5.7
// import RegexBuilder

@main
public struct RunStringParsingExamples {
    
    public static func main() {
        
        self.runExamples()
        self.runBasicPercentageParse()
        self.runEmailParse()
        self.runPayrollParse()
        self.runDataParseAndReduceFromArray()
        self.runWhitespaceStandardization()
        self.runNumberFormatStandardization()
        self.runTemperatureStringArrayConversion()
        self.runCustomTypeParsingExample()
        // self.runRegexBuildingExample()
        
    }
    
    static func runExamples() {
        
        let (testCount, failureCount, timeTaken) = "Executed 4 tests, with 1 failure in 0.009 seconds".find(.number, .number, .time)!

        print(testCount) // 4
        print(failureCount) // 1
        print(timeTaken) // 0.009 seconds

        let (date, temperature, humidity) = "On August 23, 2022 the temperature in Chicago was 68.3 ºF (with a humidity of 74%)".find(.date, .temperature, .percentage)!
        print(date) // August 23, 2022
        print(temperature) // 68.3 ºF
        print(humidity) // 74%
        
        let (earnings, fileSize, url) = "Total Earnings From PDF: $12.2k (3.25 MB, at https://lifeadvice.co.uk/pdfs/download?id=guide)".find(.currency, .fileSize, .url)!
        print(earnings) // 12,200 USD
        print(fileSize) // 3.25 MB
        print(url) // https://lifeadvice.co.uk/pdfs/download?id=guide

        
    }
    
    static func runBasicPercentageParse() {
        
        let percentage = "Results of likeness test: 83% match".find(.percentage)!
        print(percentage)
                
    }
    
    static func runEmailParse() {
        
        let email = "Email me at scott@tracyisland.com".find(.emailAddress)!
        print(email)

    }
    
    static func runPayrollParse() {
        
        // this string has inconsistent whitespace between entities, but this isn't a problem for us
        let payrollEntry = "CREDIT            03/02/2022            Payroll from employer                $200.23"
        let (date, currency) = payrollEntry.find(.date, .currency)!
        
        print(date) // Either February 3, or March 2, depending on your system locale
        print(currency) // UnitExpression object (use .value to get the decimalValue, and .unit.identifier to get the currency code)
        
    }
    
    static func runDataParseAndReduceFromArray() {
        
        let amounts = ["Jude spent $50", "Sasha spent US$81.9 (with her 10% discount)", "Theodore spent $43.90 USD"].find(.currency)
        
        let totalAmount = amounts.reduce(0.0) {
            $0 + $1.value
        }
        
        print(totalAmount)
        
    }
    
    static func runWhitespaceStandardization() {
        
        let standardized = "CREDIT            03/02/2022            Payroll from employer                $200.23".replacingAll(.whitespace) { whitespace in
            return " "
        }
        
        print(standardized)
        
    }
    
    static func runNumberFormatStandardization() {
        let standardized = "10.330,99 8.330,22 330,99".replacingAll(.number, locale: Locale(identifier: "en_DE")) { number in
            
            return NumberFormatter.localizedString(from: number as NSNumber, number: .decimal)
            
        }
        
        print(standardized)
        
    }
    
    static func runTemperatureStringArrayConversion() {
        
        let convertedTemperatures = ["25 °C", "12.5 degrees celsius", "-22.6 C"].replacingAll(.temperature) { celsius in
            
            let measurementC: Measurement<UnitTemperature> = Measurement(value: celsius.value.doubleValue, unit: .celsius)
            let measurementF = measurementC.converted(to: .fahrenheit)
            
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            return formatter.string(from: measurementF)
            
        }
        
        print(convertedTemperatures)
        
    }
    
    static func runCustomTypeParsingExample() {
        
        let container1 = Container("Color: blue, size: medium, volume: 12.5 cm3".find(.color, .size, .volume)!)
        let container2 = Container("Color: red, size: small, volume: 6.2 cm3".find(.color, .size, .volume)!)
        let container3 = Container("Color: yellow, size: large, volume: 17.82 cm3".find(.color, .size, .volume)!)
        
        _ = [container1, container2, container3]
        
    }
    
    /// Requires Swift 5.7
    // static func runRegexBuildingExample() {
//
//         let input = "Cost: 365.45, Date: March 12, 2022"
//
//         if #available(macOS 13.0, iOS 16.0, *) {
//
//             let regex = Regex {
//                 "Cost: "
//                 Capture {
//                     DataPoint<NumberFromTokenParser>.number
//                 }
//                 ", Date: "
//                 Capture {
//                     DataPoint<DateFromTokenParser>.date
//                 }
//             }
//
//             guard let match = input.wholeMatch(of: regex) else {
//                 return
//             }
//
//             print(match.1)
//             print(match.2)
//
//         }
//
//     }
    
}


// MARK: - Custom Types for the Custom Parsing Example

enum Color: String, RawRepresentable {
    case blue
    case red
    case yellow
}

enum Size: String, RawRepresentable {
    case small
    case medium
    case large
}

struct Container {
    
    let color: Color
    let size: Size
    let volume: Decimal
    
    init(_ data: (Color, Size, UnitExpression)) {
        
        self.color = data.0
        self.size = data.1
        self.volume = data.2.value
        
    }
    
}

// MARK: -  Implementation of parsers for the custom types above

/// In both cases, we simply check to see if we can create an enum case from the token's stringValue

struct ColorParser: DataFromTokenParser {
    typealias DataType = Color
    
    func parseDataFrom(token: SoulverCore.Token) -> Color? {
        return Color(rawValue: token.stringValue.lowercased())
    }
}

struct SizeParser: DataFromTokenParser {
    typealias DataType = Size
    
    func parseDataFrom(token: SoulverCore.Token) -> Size? {
        return Size(rawValue: token.stringValue.lowercased())
    }
}

extension DataPoint {
    
    static var color: DataPoint<ColorParser> {
        return DataPoint<ColorParser>(parser: ColorParser())
    }
    
    static var size: DataPoint<SizeParser> {
        return DataPoint<SizeParser>(parser: SizeParser())
    }
    
}
