//
//  ContentView.swift
//  case
//
//  Created by Shahid's MacPro on 25/11/2025.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

//
//  UltimateTextTools.swift
//  UltimateTextTools
//
//  Single-file SwiftUI app (iOS 15+). Copy into a new SwiftUI App project.
//  Provides many text transforms and utilities in a stable, compile-ready form.
//
//  Features included (safe and tested in concept):
//  - Case transforms: sentence, lower, upper, title, alternating, inverse
//  - Remove spaces/underscores/line breaks/extra whitespace
//  - Duplicate line remover & duplicate adjacent-word finder
//  - Reverse text, big text (spaced), add line numbers
//  - Extract emails, Base64 encode/decode, Pig Latin
//  - Zalgo (tunable intensity), Upside-down, Fullwidth, Circled/Bubble (A-Z,a-z only)
//  - Superscript/Subscript (limited mapping), remove diacritics / non-ascii
//  - Copy, Save (.txt), Clear, live stats
//
//  Notes: mapping dictionaries are intentionally limited to ASCII letters to keep behavior predictable.
//  Avoids use of deprecated APIs and duplicate declarations. Should compile on iOS 15+ (Xcode 13+).
//

//import SwiftUI
//import AVFoundation
//import UniformTypeIdentifiers
//
//@main
//struct UltimateTextToolsApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ToolsView()
//                .preferredColorScheme(.dark)
//        }
//    }
//}
//
//struct ToolsView: View {
//    @State private var text: String = ""
//    @State private var textSize: CGFloat = 16
//    @State private var showShareSheet: Bool = false
//    @State private var shareURL: URL?
//    @State private var copiedFeedback: Bool = false
//    @State private var zalgoIntensity: Double = 10
//    @State private var showingZalgoSheet = false
//
//    private let synthesizer = AVSpeechSynthesizer()
//    @State private var isSpeaking = false
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 12) {
//                // Editor
//                ZStack(alignment: .topLeading) {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color(.systemGray5))
//                    TextEditor(text: $text)
//                        .padding(12)
//                        .font(.system(size: textSize))
//                        .foregroundColor(.white)
//                        .frame(minHeight: 220)
//                    if text.isEmpty {
//                        Text("Type or paste your content here")
//                            .foregroundColor(Color(.systemGray2))
//                            .padding(.horizontal, 18)
//                            .padding(.vertical, 14)
//                    }
//                }
//                .padding(.horizontal)
//
//                // Transform buttons (horizontal scroll)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        actionButton("Sentence case") { sentenceCase() }
//                        actionButton("lower case") { applyLower() }
//                        actionButton("UPPER CASE") { applyUpper() }
//                        actionButton("Title Case") { applyTitleCase() }
//                        actionButton("Capitalized") { applyCapitalized() }
//                        actionButton("aLtErNaTiNg cAsE") { applyAlternatingCase() }
//                        actionButton("InVeRsE CaSe") { applyInverseCase() }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // More utilities (horizontal)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        actionButton("Remove Extra Spaces") { removeExtraSpaces() }
//                        actionButton("Remove Underscores") { removeUnderscores() }
//                        actionButton("Remove Line Breaks") { removeLineBreaks() }
//                        actionButton("Duplicate Line Remover") { removeDuplicateLines() }
//                        actionButton("Find Duplicate Words") { findDuplicateWords() }
//                        actionButton("Reverse Text") { reverseText() }
//                        actionButton("Big Text") { bigText() }
//                        actionButton("Add Line Numbers") { addLineNumbers() }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // Unicode & fun transforms
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        actionButton("Fullwidth") { applyFullwidth() }
//                        actionButton("Bubble / Circled") { applyCircled() }
//                        actionButton("Superscript") { applySuperscript() }
//                        actionButton("Subscript") { applySubscript() }
//                        actionButton("Upside Down") { applyUpsideDown() }
//                        actionButton("Zalgo") { showingZalgoSheet = true }
//                        actionButton("Strip Diacritics") { stripDiacritics() }
//                        actionButton("Remove Formatting (ASCII)") { removeFormattingASCII() }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // Encoders, translators
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        actionButton("Base64 Encode") { base64Encode() }
//                        actionButton("Base64 Decode") { base64Decode() }
//                        actionButton("Pig Latin") { pigLatin() }
//                        actionButton("Extract Emails") { extractEmails() }
//                        actionButton("Remove Non-Alnum") { removeNonAlphanumeric() }
//                    }
//                    .padding(.horizontal)
//                }
//
//                // Utilities row
//                HStack(spacing: 12) {
//                    Button(action: copyToClipboard) {
//                        Label("Copy", systemImage: "doc.on.doc")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(PrimaryRounded())
//
//                    Button(action: saveToFile) {
//                        Label("Save .txt", systemImage: "square.and.arrow.up")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(PrimaryRounded())
//
//                    Button(action: { text = "" }) {
//                        Label("Clear", systemImage: "trash")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(DestructiveRounded())
//                }
//                .padding(.horizontal)
//
//                // Stats
//                HStack(spacing: 14) {
//                    statView("Characters", "\(text.count)")
//                    statView("Words", "\(wordCount)")
//                    statView("Sentences", "\(sentenceCount)")
//                    statView("Lines", "\(lineCount)")
//                    statView("Read (mins)", String(format: "%.1f", readingMinutes))
//                    Spacer()
//                }
//                .padding([.horizontal, .bottom])
//
//            } // VStack
//            .navigationTitle("Ultimate Text Tools")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    HStack(spacing: 12) {
//                        if copiedFeedback { Text("Copied").foregroundColor(.green) }
//                        Button(action: speakText) {
//                            Image(systemName: "speaker.wave.2.fill")
//                        }
//                    }
//                }
//            }
//            .sheet(isPresented: $showShareSheet, onDismiss: {
//                if let url = shareURL { try? FileManager.default.removeItem(at: url); shareURL = nil }
//            }) {
//                if let url = shareURL {
//                    ActivityView(activityItems: [url])
//                } else {
//                    Text("Preparing...")
//                }
//            }
//            .sheet(isPresented: $showingZalgoSheet) {
//                ZalgoSheet(intensity: $zalgoIntensity) { intensity in
//                    applyZalgo(intensity: Int(intensity))
//                }
//            }
//        } // NavigationView
//    }
//
//    // MARK: - UI components
//    @ViewBuilder
//    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 13, weight: .semibold))
//                .padding(.vertical, 8)
//                .padding(.horizontal, 12)
//                .background(Color(.systemBlue))
//                .foregroundColor(.white)
//                .cornerRadius(8)
//        }
//    }
//
//    @ViewBuilder
//    private func statView(_ title: String, _ value: String) -> some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title).font(.caption).foregroundColor(Color(.systemGray3))
//            Text(value).font(.headline).foregroundColor(.white)
//        }
//        .padding(6)
//        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5).opacity(0.06)))
//    }
//
//    // MARK: - Stats computed
//    private var wordCount: Int {
//        let comps = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//        return comps.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
//    }
//
//    private var sentenceCount: Int {
//        let ns = text as NSString
//        var count = 0
//        ns.enumerateSubstrings(in: NSRange(location: 0, length: ns.length), options: .bySentences) { _, _, _, _ in count += 1 }
//        if count == 0 && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return 1 }
//        return count
//    }
//
//    private var lineCount: Int {
//        if text.isEmpty { return 0 }
//        return text.components(separatedBy: "\n").count
//    }
//
//    private var readingMinutes: Double {
//        let wpm = 200.0
//        return Double(wordCount) / wpm
//    }
//
//    // MARK: - Core transforms (safe, single implementations)
//
//    private func applyLower() { text = text.lowercased() }
//    private func applyUpper() { text = text.uppercased() }
//    private func applyCapitalized() { text = text.capitalized }
//
//    private func applyInverseCase() {
//        var out = ""
//        out.reserveCapacity(text.count)
//        for ch in text {
//            let s = String(ch)
//            if s == s.uppercased() {
//                out.append(s.lowercased())
//            } else if s == s.lowercased() {
//                out.append(s.uppercased())
//            } else {
//                out.append(ch)
//            }
//        }
//        text = out
//    }
//
//    private func applyAlternatingCase() {
//        var out = ""
//        var upper = false
//        for ch in text {
//            if ch.isLetter {
//                out.append(upper ? String(ch).uppercased() : String(ch).lowercased())
//                upper.toggle()
//            } else {
//                out.append(ch)
//            }
//        }
//        text = out
//    }
//
//    private func applyTitleCase() {
//        // Simple title case: capitalize each word except common small words
//        let smallWords = Set(["a","an","the","and","but","or","for","nor","on","at","to","from","by","in","of","with","as"])
//        let words = text.split(omittingEmptySubsequences: false, whereSeparator: { $0 == " " || $0.isNewline })
//        var outWords: [String] = []
//        for (i, w) in words.enumerated() {
//            let s = String(w)
//            if i != 0 && smallWords.contains(s.lowercased()) {
//                outWords.append(s.lowercased())
//            } else {
//                outWords.append(s.capitalized)
//            }
//        }
//        text = outWords.joined(separator: " ")
//    }
//
//    private func sentenceCase() {
//        // Lowercase all and capitalize start of sentences
//        var out = ""
//        var capitalizeNext = true
//        for ch in text {
//            if ch.isLetter {
//                if capitalizeNext {
//                    out.append(String(ch).uppercased())
//                    capitalizeNext = false
//                } else {
//                    out.append(String(ch).lowercased())
//                }
//            } else {
//                out.append(ch)
//                if ".!?".contains(ch) { capitalizeNext = true }
//                if ch == "\n" { capitalizeNext = true }
//            }
//        }
//        text = out
//    }
//
//    // MARK: - Cleaning
//    private func removeExtraSpaces() {
//        // collapse spaces and newlines
//        var s = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
//        // collapse multiple newlines to single
//        s = s.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
//        text = s.trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    private func removeUnderscores() {
//        text = text.replacingOccurrences(of: "_", with: "")
//    }
//
//    private func removeLineBreaks() {
//        text = text.replacingOccurrences(of: "\n", with: " ")
//    }
//
//    private func removeNonAlphanumeric() {
//        let comps = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
//        text = comps.filter { !$0.isEmpty }.joined(separator: " ")
//    }
//
//    private func removeFormattingASCII() {
//        // strip diacritics and non-ascii
//        let folded = text.folding(options: .diacriticInsensitive, locale: .current)
//        let filtered = folded.unicodeScalars.filter { $0.isASCII }.map { Character($0) }
//        text = String(filtered)
//    }
//
//    private func stripDiacritics() {
//        text = text.folding(options: .diacriticInsensitive, locale: .current)
//    }
//
//    // MARK: - Lines & duplicates
//    private func removeDuplicateLines() {
//        var seen = Set<String>()
//        var out: [String] = []
//        let lines = text.components(separatedBy: .newlines)
//        for line in lines {
//            if !seen.contains(line) {
//                seen.insert(line)
//                out.append(line)
//            }
//        }
//        text = out.joined(separator: "\n")
//    }
//
//    private func findDuplicateWords() {
//        // find adjacent duplicate words like "the the"
//        let pattern = "\\b(\\w+)\\s+\\1\\b"
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return }
//        let ns = text as NSString
//        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: ns.length))
//        if matches.isEmpty {
//            showToast("No adjacent duplicate words found")
//        } else {
//            let sample = matches.prefix(6).compactMap { m -> String? in
//                guard m.numberOfRanges >= 2 else { return nil }
//                let r = m.range(at: 1)
//                return ns.substring(with: r)
//            }
//            showToast("Adjacent duplicates: " + sample.joined(separator: ", "))
//        }
//    }
//
//    // MARK: - Reorders / simple transforms
//    private func reverseText() {
//        text = String(text.reversed())
//    }
//
//    private func bigText() {
//        text = text.uppercased().map { String($0) }.joined(separator: " ")
//    }
//
//    private func addLineNumbers() {
//        let lines = text.components(separatedBy: .newlines)
//        text = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
//    }
//
//    // MARK: - Unicode transforms (limited maps)
//    private func applyFullwidth() {
//        var out = ""
//        for scalar in text.unicodeScalars {
//            let v = scalar.value
//            if v >= 0x21 && v <= 0x7E {
//                if let fw = UnicodeScalar(v + 0xFEE0) {
//                    out.append(Character(fw))
//                } else {
//                    out.append(Character(scalar))
//                }
//            } else {
//                out.append(Character(scalar))
//            }
//        }
//        text = out
//    }
//
//    private func applyCircled() {
//        // basic circled mapping for A-Z and a-z (limited)
//        let upperBase = 0x24B6 // A
//        let lowerBase = 0x24D0 // a
//        var out = ""
//        for ch in text {
//            if let ascii = ch.asciiValue {
//                if ascii >= 65 && ascii <= 90 { // A-Z
//                    if let sc = UnicodeScalar(upperBase + Int(ascii - 65)) {
//                        out.append(Character(sc)); continue
//                    }
//                } else if ascii >= 97 && ascii <= 122 { // a-z
//                    if let sc = UnicodeScalar(lowerBase + Int(ascii - 97)) {
//                        out.append(Character(sc)); continue
//                    }
//                }
//            }
//            out.append(ch)
//        }
//        text = out
//    }
//
//    // Superscript/subscript limited mapping
//    private func applySuperscript() {
//        let map: [Character: Character] = [
//            "0":"⁰","1":"¹","2":"²","3":"³","4":"⁴","5":"⁵","6":"⁶","7":"⁷","8":"⁸","9":"⁹",
//            "a":"ᵃ","b":"ᵇ","c":"ᶜ","d":"ᵈ","e":"ᵉ","f":"ᶠ","g":"ᵍ","h":"ʰ","i":"ⁱ","j":"ʲ","k":"ᵏ","l":"ˡ","m":"ᵐ","n":"ⁿ","o":"ᵒ","p":"ᵖ","r":"ʳ","s":"ˢ","t":"ᵗ","u":"ᵘ","v":"ᵛ","w":"ʷ","x":"ˣ","y":"ʸ","z":"ᶻ",
//            "A":"ᴬ","B":"ᴮ","C":"ᶜ","D":"ᴰ","E":"ᴱ","F":"ᶠ","G":"ᴳ","H":"ᴴ","I":"ᴵ","J":"ᴶ","K":"ᴷ","L":"ᴸ","M":"ᴹ","N":"ᴺ","O":"ᴼ","P":"ᴾ","R":"ᴿ","S":"ˢ","T":"ᵀ","U":"ᵁ","V":"ⱽ","W":"ᵂ"
//        ]
//        text = text.map { ch in
//            if let m = map[ch] { return String(m) } else { return String(ch) }
//        }.joined()
//    }
//
//    private func applySubscript() {
//        let map: [Character: Character] = [
//            "0":"₀","1":"₁","2":"₂","3":"₃","4":"₄","5":"₅","6":"₆","7":"₇","8":"₈","9":"₉",
//            "a":"ₐ","e":"ₑ","h":"ₕ","i":"ᵢ","j":"ⱼ","k":"ₖ","l":"ₗ","m":"ₘ","n":"ₙ","o":"ₒ","p":"ₚ","r":"ᵣ","s":"ₛ","t":"ₜ","u":"ᵤ","v":"ᵥ","x":"ₓ"
//        ]
//        text = text.map { ch in
//            if let m = map[ch] { return String(m) } else { return String(ch) }
//        }.joined()
//    }
//
//    // Upside-down transform (limited)
//    private func applyUpsideDown() {
//        let map: [Character: Character] = [
//            "a":"ɐ","b":"q","c":"ɔ","d":"p","e":"ǝ","f":"ɟ","g":"ɓ","h":"ɥ","i":"ı","j":"ɾ","k":"ʞ","l":"l","m":"ɯ",
//            "n":"u","o":"o","p":"d","q":"b","r":"ɹ","s":"s","t":"ʇ","u":"n","v":"ʌ","w":"ʍ","x":"x","y":"ʎ","z":"z",
//            "A":"∀","B":"𐐒","C":"Ɔ","D":"◖","E":"Ǝ","F":"Ⅎ","G":"⅁","H":"H","I":"I","J":"ſ","K":"⋊","L":"˥","M":"W",
//            "N":"N","O":"O","P":"Ԁ","Q":"Ό","R":"ᴚ","S":"S","T":"⊥","U":"∩","V":"Λ","W":"M","X":"X","Y":"⅄","Z":"Z",
//            "1":"Ɩ","2":"ᄅ","3":"Ɛ","4":"h","5":"ϛ","6":"9","7":"ㄥ","8":"8","9":"6","0":"0",
//            ".":"˙",",":"'","?":"¿","!":"¡","\"":",","'":",","(":")",")":"(","[":"]","]":"[","{":"}","}":"{","<":">",">":"<"
//        ]
//        var out = ""
//        for ch in text.reversed() {
//            if let m = map[ch] { out.append(m) } else { out.append(ch) }
//        }
//        text = out
//    }
//
//    // MARK: - Zalgo
//    private func applyZalgo(intensity: Int) {
//        guard intensity > 0 else { return }
//        text = zalgoize(text, intensity: intensity)
//    }
//
//    private func zalgoize(_ s: String, intensity: Int) -> String {
//        let up = ["\u{030d}","\u{030e}","\u{0304}","\u{0305}","\u{033f}","\u{0311}","\u{0306}","\u{0310}","\u{0352}","\u{0357}"]
//        let mid = ["\u{0315}","\u{031b}","\u{0340}","\u{0341}","\u{0358}","\u{0321}","\u{0322}","\u{0327}","\u{0328}","\u{0334}"]
//        let down = ["\u{0316}","\u{0317}","\u{0318}","\u{0319}","\u{031c}","\u{031d}","\u{031e}","\u{031f}","\u{0320}","\u{0324}"]
//        var out = ""
//        for ch in s {
//            out.append(ch)
//            let countUp = Int.random(in: 0...max(0, intensity/3))
//            let countMid = Int.random(in: 0...max(0, intensity/4))
//            let countDown = Int.random(in: 0...max(0, intensity/3))
//            for _ in 0..<countUp { out.append(up.randomElement()!) }
//            for _ in 0..<countMid { out.append(mid.randomElement()!) }
//            for _ in 0..<countDown { out.append(down.randomElement()!) }
//        }
//        return out
//    }
//
//    // MARK: - Encoding / Decoding
//    private func base64Encode() {
//        if let data = text.data(using: .utf8) {
//            text = data.base64EncodedString()
//        }
//    }
//
//    private func base64Decode() {
//        if let data = Data(base64Encoded: text), let s = String(data: data, encoding: .utf8) {
//            text = s
//        }
//    }
//
//    // MARK: - Pig Latin
//    private func pigLatin() {
//        let vowels = Set("aeiouAEIOU")
//        let words = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
//        let transformed = words.map { word -> String in
//            guard !word.isEmpty else { return "" }
//            var core = word
//            var punct = ""
//            while let last = core.last, !last.isLetter {
//                punct = String(last) + punct
//                core.removeLast()
//            }
//            if core.isEmpty { return word }
//            if vowels.contains(core.first!) {
//                return core + "ay" + punct
//            } else {
//                if let idx = core.firstIndex(where: { vowels.contains($0) }) {
//                    let head = core[..<idx]
//                    let tail = core[idx...]
//                    return String(tail + head) + "ay" + punct
//                } else {
//                    return core + "ay" + punct
//                }
//            }
//        }
//        text = transformed.joined(separator: " ")
//    }
//
//    // MARK: - Extract emails
//    private func extractEmails() {
//        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
//        let ns = text as NSString
//        let matches = regex.matches(in: text, range: NSRange(location: 0, length: ns.length))
//        let emails = matches.map { ns.substring(with: $0.range) }
//        text = emails.joined(separator: "\n")
//    }
//
//    // MARK: - Helpers for save & copy
//    private func copyToClipboard() {
//        UIPasteboard.general.string = text
//        copiedFeedback = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copiedFeedback = false }
//    }
//
//    private func saveToFile() {
//        let fileName = "TextExport.txt"
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//        do {
//            try text.write(to: url, atomically: true, encoding: .utf8)
//            shareURL = url
//            showShareSheet = true
//        } catch {
//            print("Save error: \(error)")
//        }
//    }
//
//    private func speakText() {
//        if isSpeaking {
//            synthesizer.stopSpeaking(at: .immediate)
//            isSpeaking = false
//        } else {
//            let utterance = AVSpeechUtterance(string: text)
//            utterance.rate = AVSpeechUtteranceDefaultSpeechRate
//            synthesizer.speak(utterance)
//            isSpeaking = true
//        }
//    }
//
//    private func showToast(_ message: String) {
//        // quick UX helper — here we simply copy the message to clipboard as subtle feedback or print
//        UIPasteboard.general.string = message
//    }
//}
//
//// MARK: - Zalgo sheet view
//struct ZalgoSheet: View {
//    @Binding var intensity: Double
//    var apply: (Double) -> Void
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 16) {
//                Text("Zalgo intensity: \(Int(intensity))")
//                Slider(value: $intensity, in: 0...50, step: 1)
//                HStack {
//                    Button("Apply") {
//                        apply(intensity)
//                        dismiss()
//                    }
//                    .buttonStyle(.borderedProminent)
//                    Button("Cancel") { dismiss() }
//                }
//            }
//            .padding()
//            .navigationTitle("Zalgo")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - ActivityView for share sheet
//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}
//
//// MARK: - Button styles
//struct PrimaryRounded: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 14, weight: .semibold))
//            .padding(10)
//            .background(Color.blue)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//    }
//}
//struct DestructiveRounded: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 14, weight: .semibold))
//            .padding(10)
//            .background(Color(.systemRed))
//            .foregroundColor(.white)
//            .cornerRadius(10)
//            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//    }
//}
