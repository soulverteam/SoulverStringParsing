## String Parsing with Soulver Core
###### A declarative & type-safe approach to parsing data from strings

[SoulverCore](https://soulver.app/core) gives you human-friendly, type-safe & performant data parsing from Swift strings.

Specify types you want to parse from a string. If they are present, you get back ready-to-use data primitives (not strings!).

This approach to data parsing allows you to ignore:

1. The specifics of how the data you need is formatted in text
2. Random words (or other data points), surrounding the data you need

## Examples

Let's look at a few examples:

```swift
let data = "Executed 4 tests, with 1 failure in 0.009 seconds".(number, .number, .time)
data.0 // 4
data.1 // 1
data.2 // 0.009 seconds
```

```swift
let data = "On August 23, 2022 the temperature in Chicago was 68.3 °F (with a humidity of 74%)".find(.date, .temperature, .percentage)
data.0 // August 23, 2022
data.1 // 68.3 °F
data.2 // 74%
```

```swift
let data = "Total Earnings From PDF: $12.2k (3.25 MB, at https://lifeadvice.co.uk/pdfs/download?id=guide)".(currency, .fileSize, .url)
data.0 // 12,200 USD
data.1 // 3.25 MB
data.2 // https://lifeadvice.co.uk/pdfs/download?id=guide
```

**Note**: the returned data points are **not** strings. They are native Swift data types (available as elements on a tuple), on which you can immediately perform operations:

```swift
let numbers = "100 + 20".find(.number, .number)!
let sum = numbers.0 + numbers.1 // 120
```

Up to 6 data points can be requested in a single call. Variadic generics are planned for Swift 6, so we'll support more in the future.

## The beauty of high order data extraction

Observe the beauty of the higher order concepts used here: numbers come in many formats (1,000, 30k, .456), yet a simple ".number" query "matches" them all. And .date "matches" dates in  commonly used date formats.

For cases where the locale plays a role in the format of data, you may specify a locale in the find method (otherwise the current system Locale is used):

```swift
let europeanNumber = "€1.333,24".find(.currency, locale: Locale(identifier: "en_DE"))
let americanDate = "05/30/21".find(.date, locale: Locale(identifier: "en_US")) // month/day/year
```

Where possible, standard Swift primitives are returned (URL, Date, Decimal, etc). In cases where no Swift primitive wholly captures the data present in the string, a SoulverCore value type is returned with properties containing the relevant data.

## Supported data types

| Symbol | Match Examples | Return Type |
|:--|:--|:--|
| .number |  123.45, 10k, -.3, 3,000, 50_000 | Decimal |
| .binaryNumber |  0b1011010 | UInt |
| .hexNumber  | 0x31FE28 |  UInt |
| .boolean |  'true' or 'false' | Bool |
| .percentage |  10%, 230.99% | Decimal |
| .date |  March 12, 2004, 21/04/77, July the 4th, etc | Date |
| .unixTimestamp |  1661259854 | TimeInterval |
| .place |  Paris, Tokyo, Bali, Israel | SoulverCore.Place |
| .airport |  SFO, LAX, SYD | SoulverCore.Place |
| .timezone |  AEST, GMT, EST | SoulverCore.Place |
| .currencyCode |  USD, EUR, DOGE | String |
| .currency |  $10.00, AU$30k, 350 JPY | SoulverCore.UnitExpression |
| .time |  10 s, 3 min, 4 weeks | SoulverCore.UnitExpression |
| .distance  | 10 km, 3 miles, 4 cm | SoulverCore.UnitExpression |
| .temperature   | 25 °C, 77 °F, 10C, 5 F  | SoulverCore.UnitExpression |
| .weight |  10kg, 45 lb | SoulverCore.UnitExpression |
| .area |  30 m2, 40 in2 | SoulverCore.UnitExpression |
| .speed |  30 mph | SoulverCore.UnitExpression |
| .volume |  3 litres, 4 cups, 10 fl oz | SoulverCore.UnitExpression |
| .timespan |  3 hours 12 minutes | SoulverCore.Timespan |
| .laptime |  01:30:22.490 (hh:mm:ss.ms) | SoulverCore.Laptime |
| .timecode |  03:10:21:16 (hh:mm:ss:frames) | SoulverCore.Frametime |
| .url | https://soulver.app | URL |
| .hashTag |  #this_is_a_tag | String |
| .whitespace |  All whitespace characters (including tabs) are collapsed into a single whitespace token | String |
| .pitch  | A4, Bb7, C#9 | SoulverCore.Pitch |

## Getting started

- The SoulverCore framework includes a highly optimized string parser, which can produce an array of tokens representing data types in a given string. This is exactly what we need.
- Add the [SoulverCore](https://soulver.app/core) binary framework to your project. The package is located at https://github.com/soulverteam/SoulverCore (In Xcode, go File > Add Packages…)
- Be sure to "import SoulverCore" at the top of any Swift files in which you wish to process strings

## Finding data in strings

As we saw above, finding a data point in a string is as simple as asking for it:

```swift
let percent = "Results of likeness test: 83% match".find(.percentage)
// percent is the decimal 0.83
```

Extracting multiple data points is no harder. A tuple is returned with the correct number of arguments and data types:

```swift
let payrollEntry = "CREDIT			03/02/2022			Payroll from employer				$200.23" // this string has inconsistent whitespace between entities, but this isn't a problem for us
let data = payrollEntry.find(.date, .currency)!
data.0 // Either February 3, or March 2, depending on your system locale
data.1 // UnitExpression object (use .value to get the decimalValue, and .unit.identifier to get the currency code - USD)
```

## Extracting a data point from an array of strings

We can also call find with a single data type on an array of strings, and get back an array of the corresponding data type of the match:

```swift
let amounts = ["Zac spent $50", "Molly spent US$81.9 (with her 10% discount)", "Jude spent $43.90 USD"].find(.currency)

let totalAmount = amounts.reduce(0.0) {
	$0 + $1.value
}

// totalAmount is $175.80
```

## Transforming data in strings

Imagine we wanted to standardize the whitespace in the string from the previous example:

```swift
let standardized = "CREDIT			03/02/2022			Payroll from employer				$200.23".replacingAll(.whitespace) { whitespace in
    return " "
}

// standardized is "CREDIT 03/02/2022 Payroll from employer $200.23"
```

Or perhaps you want to convert European formatted numbers into Swift "standard" ones:

```swift
let standardized = "10.330,99 8.330,22 330,99".replacingAll(.number, locale: Locale(identifier: "en_DE")) { number in
    return NumberFormatter.localizedString(from: number as NSNumber, number: .decimal)
}

// standardized is "10,330.99 8,330.22 330.99")
```

Or perhaps you want to convert Celsius temperatures into Fahrenheit:

```swift
let convertedTemperatures = ["25 °C", "12.5 degrees celsius", "-22.6 C"].replacingAll(.temperature) { celsius in
    
    let measurementC: Measurement<UnitTemperature> = Measurement(value: celsius.value.doubleValue, unit: .celsius)
    let measurementF = measurementC.converted(to: .fahrenheit)
    
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    return formatter.string(from: measurementF)
    
}

// convertedTemperatures is ["77°F", "54.5°F", "-8.68°F"]
```


## Extending SoulverCore with your own custom types

Let's imagine we had strings with the following format, describing some containers:

- "Color: blue, size: medium, volume: 12.5 cm3"
- "Color: red, size: small, volume: 6.2 cm3"
- "Color: yellow, size: large, volume: 17.82 cm3"

We want to extract this data into a custom Swift type that represents a Container.

1. Define our model classes (if they don't exist already)

```swift
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
```

2. Then create parsers for Color and Size, and add them static variables on DataPoint

```swift
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
```

3. That's all the setup. You can now parse the data from the string, and populate your model objects:

```swift
  let container1 = Container("Color: blue, size: medium, volume: 12.5 cm3".find(.color, .size, .volume)!)
  let container2 = Container("Color: red, size: small, volume: 6.2 cm3".find(.color, .size, .volume)!)
  let container3 = Container("Color: yellow, size: large, volume: 17.82 cm3".find(.color, .size, .volume)!)
```


## Using SoulverCore as a parser inside Swift Regex Builder (Xcode 14, Swift 5.7+)

SoulverCore can be used to parse data inside the Swift regex builder DSL. This is often easier than figuring out how to match the format of your data with a regular expression.

```swift
if #available(macOS 13.0, iOS 16.0, *) {
    let input = "Cost: 365.45, Date: March 12, 2022"
    
    let regex = Regex {
        "Cost: "
        Capture {
            DataPoint<NumberFromTokenParser>.number
        }
        ", Date: "
        Capture {
            DataPoint<DateFromTokenParser>.date
        }
    }
    
    let match = input.wholeMatch(of: regex).1 // 365.45
}
````
Note: it's confusing and unfortunate that the Swift compiler can't seem to infer the DataPoint generic parameter from a static variable on DataPoint (anyone know why?).

Until this is fixed, you must explicitly specify the DataFromTokenParser corresponding to the type of the data you want to match.

## Performance

SoulverCore is unlikely to be your app's bottleneck.

In our testing SoulverCore does ~6k operations per second on Intel and 10k+ operations/second on  Silicon. 

While this is admittedly not as fast as regex, in fairness, SoulverCore is doing a **lot** more work. Before your query is checked for matches, SoulverCore parses the complete string into tokens representing various data types, of which it can identify more than 20 (including dates, numbers & units in various formats, places, timezones and more…).

A regex that did this would be impossible to construct, and even if such a regex were possible, it would run much more slowly than SoulverCore does.

## Comparison with other data parsing approaches

In addition to regex, Apple's toolkit for string parsing includes Regex, NSScanner & NSDataDetector. Let's compare and contrast each of these with SoulverCore.

#### Regular Expressions

(Regular expressions)[https://en.wikipedia.org/wiki/Regular_expression] will always be with us, but ask yourself, do you _really_ want to use them for data processing?

They're non-trivial to understand at a glance, and constructing a correct regex to match data is, at the minimum, tedious (if not mentally quite _challenging_ sometimes).

Even with the **significant** enhancements to regex in Swift 5.7 (type-safe tuple matches & the regex builder syntax), regex makes you think about data parsing at the *wrong level of abstraction* (i.e. characters, rather than data types).

Regex only "sees" sets of characters/numbers/whitespace so it forces you to think about the string format of the data you want to parse, and also often about how to skip past other strings leading up to it.

If Swift is to achieve its goal of becoming [the world's greatest string & data processing language](https://github.com/apple/swift/blob/main/docs/StringManifesto.md), it needs something more human friendly at the level of abstraction of data, not character sets.

#### NSScanner

A scanner is an imperative (rather than declarative) approach to parsing data out of strings. You move a scanner through a string step-by-step, scanning out the components that you want.

One benefit of NSScanner is that it's able to ignore parts of strings you don't care about. However scanner still only knows about numbers and strings - not higher level data types.

Here is a [StackOverflow post](https://stackoverflow.com/questions/594797/how-to-use-nsscanner) that illustrates the use of NSScanner to scan the integer from the string "user logged (3 attempts)".

```objc
NSString *logString = @"user logged (3 attempts)";
NSString *numberString;
NSScanner *scanner = [NSScanner scannerWithString:logString];
[scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
[scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&numberString];
NSLog(@"Attempts: %i", [numberString intValue]); // 3
```

Regex (in Swift 5.7+) is somewhat more concise

```swift

if #available(macOS 13.0, iOS 16.0, *) {
    let match = "user logged (3 attempts)".firstMatch(of: /([+\\-]?[0-9]+)/)
    let numberSubstring = match!.0
    let number = Int(numberSubstring)
}

```

And now SoulverCore:

```swift
let number = "user logged (3 attempts)".find(.number)
```

#### NSDataDetector

NSDataDetector is an NSRegularExpression subclass that is able to scan a string for dates, URLs, phone numbers, addresses, and flight details. It's a great class, and supports many different formats. Additionally, it return propers data types from strings, like URL and Date (much like SoulverCore).

Compare:

##### NSDataDetector

```swift
let input = "Learn more at https://fascinatingcaptian.com today."
let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
let url = detector.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))!.url!
```

##### SoulverCore

```swift
let url = "Learn more at https://fascinatingcaptian.com today".find(.url)
```

NSDataDetector's downsides are that the API is not particularly "Swifty", supported data types are limited, and it's not part of the platform-independent implementation of Foundation (so you can't use it on Linux, Windows, etc) 

## Licence

SoulverCore is a commercially licensable, **closed-source** Swift framework. The standard licensing terms of SoulverCore do apply for its use in string processing (see [SoulverCore Licence](https://github.com/soulverteam/SoulverCore#licence)).

For personal (non-commercial) projects, you do not need a license. So go ahead and use this great library in your personal projects!

There are also attribution-only licences available for a few commercial use cases.
