Pod::Spec.new do |s|

  s.name         = "InstrumentUtils_iOS"
  s.version      = "1.0.2"
  s.summary      = "Handy tools for iOS from Instrument in Portland, OR"

  s.description  = <<-DESC

Package includes these iOS utils (+ more if we forget to update this description - visit the GitHub link for the latest!):

- EasyFormInput: A handsome iOS text input component that can handle single and multiline text, email, numerical, date and select with type-in search.
- BlockingProgressIndicator: A simple blocking spinnner view with the option to show a text string. Font and text color are configurable prior to use.
- ConstraintsHelpers: Shortcut methods for working with auto-layout constraints.
- TwoLineNavBarTitle: Shows two lines of text in your UINavigationController's top bar, with two different display modes.

Utils are in Swift 2.0, and can be used from Objective-C.

DESC

  s.homepage         = "https://github.com/Instrument/InstrumentUtils_iOS"
  s.license          = { :type => "FreeBSD", :file => "LICENSE" }
  s.authors          = { "Instrument Marketing, Inc." => "appledev@weareinstrument.com", "Moses Gunesch" => "moses.gunesch@instrument.com" }
  s.social_media_url = "https://twitter.com/instrument"
  s.platform         = :ios, "8.0"
  s.requires_arc     = true
  s.source           = { :git => "https://github.com/Instrument/InstrumentUtils_iOS.git", :tag => "1.0.2" }
  s.source_files     = 'Pod/Source/**/*'

end

