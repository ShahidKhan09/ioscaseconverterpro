import SwiftUI
import AVFoundation

@main
struct TextTransformerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Screen 1: Main Transformer
            NavigationView {
                UltimateTextTransformer()
            }
            .tabItem {
                Image(systemName: "wand.and.stars")
                Text("Transformer")
            }
            .tag(0)
            
            // Screen 2: Favorites & History
            NavigationView {
                FavoritesHistoryView()
            }
            .tabItem {
                Image(systemName: "star.fill")
                Text("Favorites")
            }
            .tag(1)
            
            // Screen 3: Text Analysis
            NavigationView {
                TextAnalysisView()
            }
            .tabItem {
                Image(systemName: "chart.bar.doc.horizontal")
                Text("Analysis")
            }
            .tag(2)
            
            // Screen 4: Templates & Presets
            NavigationView {
                TemplatesView()
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Templates")
            }
            .tag(3)
            
            // Screen 5: Settings & Tools
            NavigationView {
                SettingsToolsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
            .tag(4)
        }
        .accentColor(.blue)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Screen 1: Main Transformer
struct UltimateTextTransformer: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("favoriteTransformations") private var favoriteTransformationsData: Data = Data()
    @AppStorage("transformationHistory") private var historyData: Data = Data()
    
    @State private var text = ""
    @State private var showDownloadAlert = false
    @State private var showShareSheet = false
    @State private var selectedCategory = 0
    @State private var textSize: CGFloat = 16
    @State private var isSpeaking = false
    @State private var searchText = ""
    @State private var showStats = false
    @State private var lastTransformation = ""
    
    @State private var favoriteTransformations: Set<String> = []
    @State private var transformationHistory: [String] = []
    
    private let synthesizer = AVSpeechSynthesizer()
    
    let categories = ["All", "Case & Formatting", "Social Media", "Text Effects", "Cleanup & Analysis", "Encoding & Technical", "Favorites"]
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : .white
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? .gray : .gray
    }
    
    var accentColor: Color {
        .blue
    }
    
    var filteredTransformations: [Transformation] {
        let filtered = transformations.filter { transformation in
            let matchesSearch = searchText.isEmpty ||
                transformation.name.localizedCaseInsensitiveContains(searchText) ||
                transformation.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == 0 ||
                (selectedCategory == categories.count - 1 ? favoriteTransformations.contains(transformation.id) : transformation.category == categories[selectedCategory])
            
            return matchesSearch && matchesCategory
        }
        return filtered
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Text Transformer")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(textColor)
                            Text("50+ text transformations")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: { showStats.toggle() }) {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: 18))
                                    .foregroundColor(accentColor)
                                    .padding(8)
                                    .background(cardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                            
                            Button(action: {
                                isDarkMode.toggle()
                            }) {
                                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(isDarkMode ? .yellow : .purple)
                                    .padding(8)
                                    .background(cardBackground)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    
                    if showStats {
                        StatsOverview(text: text, textColor: textColor, cardBackground: cardBackground)
                            .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search transformations...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(textColor)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 12)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            CategoryChip(
                                title: categories[index],
                                isSelected: selectedCategory == index,
                                textColor: textColor,
                                accentColor: accentColor,
                                cardBackground: cardBackground
                            ) {
                                selectedCategory = index
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                
                // Text Editor
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Text")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Text("\(text.count) chars")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                            
                            Button(action: { textSize = max(12, textSize - 1) }) {
                                Image(systemName: "textformat.size.smaller")
                                    .foregroundColor(accentColor)
                            }
                            
                            Button(action: { textSize = min(24, textSize + 1) }) {
                                Image(systemName: "textformat.size.larger")
                                    .foregroundColor(accentColor)
                            }
                        }
                    }
                    
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        TextEditor(text: $text)
                            .padding(12)
                            .background(Color.clear)
                            .foregroundColor(textColor)
                            .font(.system(size: textSize))
                            .frame(height: 120)
                        
                        if text.isEmpty {
                            Text("Start typing or paste your text here...")
                                .foregroundColor(.gray)
                                .padding(20)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Recent Transformation
                if !lastTransformation.isEmpty {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundColor(.orange)
                        Text("Last: \(lastTransformation)")
                            .font(.caption)
                            .foregroundColor(secondaryTextColor)
                        Spacer()
                        Button("Apply Again") {
                            if let transformation = transformations.first(where: { $0.name == lastTransformation }) {
                                transformText(transformation)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(accentColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Transformations Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                        ForEach(filteredTransformations) { transformation in
                            TransformationCard(
                                transformation: transformation,
                                isFavorite: favoriteTransformations.contains(transformation.id),
                                textColor: textColor,
                                accentColor: accentColor,
                                cardBackground: cardBackground,
                                onTap: {
                                    transformText(transformation)
                                    lastTransformation = transformation.name
                                    addToHistory(transformation.name)
                                },
                                onFavorite: {
                                    toggleFavorite(transformation.id)
                                }
                            )
                        }
                    }
                    .padding()
                }
                .padding(.top, 8)
                
                // Quick Actions Bar
                HStack(spacing: 12) {
                    ActionButton(
                        icon: "doc.on.doc",
                        title: "Copy",
                        color: .green,
                        cardBackground: cardBackground
                    ) {
                        copyToClipboard()
                    }
                    
                    ActionButton(
                        icon: "square.and.arrow.down",
                        title: "Save",
                        color: .blue,
                        cardBackground: cardBackground
                    ) {
                        downloadText()
                    }
                    
                    ActionButton(
                        icon: "square.and.arrow.up",
                        title: "Share",
                        color: .orange,
                        cardBackground: cardBackground
                    ) {
                        showShareSheet = true
                    }
                    
                    ActionButton(
                        icon: isSpeaking ? "stop.circle" : "play.circle",
                        title: isSpeaking ? "Stop" : "Speak",
                        color: .purple,
                        cardBackground: cardBackground
                    ) {
                        toggleSpeech()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [text])
        }
        .alert("Download Complete", isPresented: $showDownloadAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            loadFavorites()
            loadHistory()
        }
        .onChange(of: favoriteTransformations) { _ in
            saveFavorites()
        }
        .onChange(of: transformationHistory) { _ in
            saveHistory()
        }
    }
    
    private func transformText(_ transformation: Transformation) {
        var currentText = text
        
        switch transformation.id {
        // Case & Formatting
        case "sentenceCase":
            currentText = currentText.capitalized
        case "lowercase":
            currentText = currentText.lowercased()
        case "uppercase":
            currentText = currentText.uppercased()
        case "capitalized":
            currentText = currentText.capitalized
        case "titleCase":
            currentText = currentText.capitalized
        case "alternatingCase":
            currentText = currentText.enumerated().map { $0.offset % 2 == 0 ? $0.element.lowercased() : $0.element.uppercased() }.joined()
        case "inverseCase":
            currentText = currentText.map { char in
                let str = String(char)
                return str == str.uppercased() ? str.lowercased() : str.uppercased()
            }.joined()
            
        // Social Media Fonts
        case "boldText":
            currentText = currentText.unicodeBold()
        case "italicText":
            currentText = currentText.unicodeItalic()
        case "smallText":
            currentText = currentText.unicodeSmall()
        case "bubbleText":
            currentText = currentText.bubbleText()
        case "gothicText":
            currentText = currentText.gothicText()
        case "wideText":
            currentText = currentText.wideText()
        case "superscript":
            currentText = currentText.superscript()
        case "subscript":
            currentText = currentText.subscriptText()
        case "strikethrough":
            currentText = currentText.strikethroughText()
        case "underline":
            currentText = currentText.underlineText()
        case "discordFont":
            currentText = currentText.discordFont()
        case "instagramFont":
            currentText = currentText.instagramFont()
        case "twitterFont":
            currentText = currentText.twitterFont()
        case "facebookFont":
            currentText = currentText.facebookFont()
            
        // Text Effects
        case "reverseText":
            currentText = String(currentText.reversed())
        case "upsideDown":
            currentText = currentText.upsideDown()
        case "mirrorText":
            currentText = currentText.mirrorText()
        case "zalgoText":
            currentText = currentText.zalgoText()
        case "invisibleText":
            currentText = currentText.invisibleText()
        case "cursedText":
            currentText = currentText.cursedText()
        case "slashText":
            currentText = currentText.slashText()
        case "stackedText":
            currentText = currentText.stackedText()
        case "wingdings":
            currentText = currentText.wingdings()
        case "whitespaceText":
            currentText = currentText.whitespaceText()
            
        // Cleanup & Analysis
        case "removeSpaces":
            currentText = currentText.replacingOccurrences(of: " ", with: "")
        case "removeLineBreaks":
            currentText = currentText.replacingOccurrences(of: "\n", with: " ")
        case "removeUnderscores":
            currentText = currentText.replacingOccurrences(of: "_", with: "")
        case "removeFormatting":
            currentText = currentText.removeFormatting()
        case "removeLetters":
            currentText = currentText.removeLetters()
        case "duplicateLineRemover":
            currentText = currentText.removeDuplicateLines()
        case "duplicateWordFinder":
            currentText = currentText.findDuplicateWords()
        case "plainText":
            currentText = currentText.plainText()
        case "whitespaceRemover":
            currentText = currentText.compressText()
        case "addLineNumbers":
            currentText = currentText.addLineNumbers()
        case "sortLines":
            currentText = currentText.sortLines()
            
        // Encoding & Technical
        case "apaFormat":
            currentText = currentText.apaFormat()
        case "phoneticSpelling":
            currentText = currentText.phoneticSpelling()
        case "pigLatin":
            currentText = currentText.pigLatin()
        case "unicodeText":
            currentText = currentText.unicodeConverted()
        case "base64Encode":
            currentText = currentText.base64Encode()
        case "base64Decode":
            currentText = currentText.base64Decode()
        case "extractEmails":
            currentText = currentText.extractEmails()
        case "compressText":
            currentText = currentText.compressText()
        case "bigText":
            currentText = currentText.bigText()
            
        default:
            break
        }
        
        text = currentText
    }
    
    private func toggleFavorite(_ id: String) {
        if favoriteTransformations.contains(id) {
            favoriteTransformations.remove(id)
        } else {
            favoriteTransformations.insert(id)
        }
    }
    
    private func addToHistory(_ transformation: String) {
        transformationHistory.insert(transformation, at: 0)
        if transformationHistory.count > 10 {
            transformationHistory = Array(transformationHistory.prefix(10))
        }
    }
    
    private func loadFavorites() {
        if let favorites = try? JSONDecoder().decode(Set<String>.self, from: favoriteTransformationsData) {
            favoriteTransformations = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteTransformations) {
            favoriteTransformationsData = data
        }
    }
    
    private func loadHistory() {
        if let history = try? JSONDecoder().decode([String].self, from: historyData) {
            transformationHistory = history
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(transformationHistory) {
            historyData = data
        }
    }
    
    private func downloadText() {
        guard let data = text.data(using: .utf8) else { return }
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("transformed_text.txt")
        do {
            try data.write(to: tempURL)
            showDownloadAlert = true
        } catch {
            print("Error writing file: \(error)")
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = text
    }
    
    private func toggleSpeech() {
        if isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
        } else {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
            isSpeaking = true
        }
    }
}

// MARK: - Screen 2: Favorites & History
struct FavoritesHistoryView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("favoriteTransformations") private var favoriteTransformationsData: Data = Data()
    @AppStorage("transformationHistory") private var historyData: Data = Data()
    
    @State private var favoriteTransformations: Set<String> = []
    @State private var history: [String] = []
    @State private var searchText = ""
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : .white
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var filteredFavorites: [Transformation] {
        transformations.filter { favoriteTransformations.contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Favorites & History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        Text("Your most used transformations")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search favorites...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(textColor)
                    }
                    .padding(12)
                    .background(cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Favorites Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Favorite Transformations")
                                .font(.headline)
                                .foregroundColor(textColor)
                            Spacer()
                            Text("\(favoriteTransformations.count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(6)
                                .background(Color.black.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        if filteredFavorites.isEmpty {
                            EmptyStateView(
                                icon: "star.slash",
                                title: "No Favorites",
                                description: "Tap the heart icon on transformations to add them here",
                                textColor: textColor
                            )
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredFavorites) { transformation in
                                    FavoriteHistoryCard(
                                        transformation: transformation,
                                        type: .favorite,
                                        textColor: textColor,
                                        cardBackground: cardBackground
                                    ) {
                                        // Action when tapped
                                        print("Tapped: \(transformation.name)")
                                    } onRemove: {
                                        favoriteTransformations.remove(transformation.id)
                                        saveFavorites()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // History Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Recent History")
                                .font(.headline)
                                .foregroundColor(textColor)
                            Spacer()
                            Button("Clear All") {
                                history.removeAll()
                                saveHistory()
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        
                        if history.isEmpty {
                            EmptyStateView(
                                icon: "clock.badge.xmark",
                                title: "No History",
                                description: "Your transformation history will appear here",
                                textColor: textColor
                            )
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(history, id: \.self) { item in
                                    FavoriteHistoryCard(
                                        transformation: Transformation(id: item, name: item, description: "Recently used", category: "History"),
                                        type: .history,
                                        textColor: textColor,
                                        cardBackground: cardBackground
                                    ) {
                                        print("Tapped history: \(item)")
                                    } onRemove: {
                                        if let index = history.firstIndex(of: item) {
                                            history.remove(at: index)
                                            saveHistory()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Quick Stats
                    VStack(spacing: 12) {
                        Text("Usage Statistics")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        HStack(spacing: 16) {
                            StatBadge(count: favoriteTransformations.count, label: "Favorites", color: .yellow, textColor: textColor, cardBackground: cardBackground)
                            StatBadge(count: history.count, label: "History", color: .blue, textColor: textColor, cardBackground: cardBackground)
                            StatBadge(count: transformations.count, label: "Total", color: .green, textColor: textColor, cardBackground: cardBackground)
                        }
                    }
                    .padding()
                    .background(cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFavorites()
            loadHistory()
        }
    }
    
    private func loadFavorites() {
        if let favorites = try? JSONDecoder().decode(Set<String>.self, from: favoriteTransformationsData) {
            favoriteTransformations = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteTransformations) {
            favoriteTransformationsData = data
        }
    }
    
    private func loadHistory() {
        if let loadedHistory = try? JSONDecoder().decode([String].self, from: historyData) {
            history = loadedHistory
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            historyData = data
        }
    }
}

// MARK: - Screen 3: Text Analysis
struct TextAnalysisView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State private var text = "This is a sample text for analysis. It contains multiple words and sentences. You can replace this with your own text to see detailed analysis results."
    @State private var analysisResults: [AnalysisItem] = []
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : .white
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Text Analysis")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        Text("Detailed analysis of your text content")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Text Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter text to analyze:")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            TextEditor(text: $text)
                                .padding(12)
                                .background(Color.clear)
                                .foregroundColor(textColor)
                                .frame(height: 120)
                            
                            if text.isEmpty {
                                Text("Paste or type text to analyze...")
                                    .foregroundColor(.gray)
                                    .padding(20)
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        Button(action: analyzeText) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("Analyze Text")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                        .disabled(text.isEmpty)
                        .opacity(text.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)
                    
                    // Analysis Results
                    if analysisResults.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar",
                            title: "No Analysis",
                            description: "Enter text and tap 'Analyze Text' to see detailed analysis",
                            textColor: textColor
                        )
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(analysisResults) { item in
                                AnalysisCard(item: item, textColor: textColor, cardBackground: cardBackground)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            analyzeText()
        }
        .onChange(of: text) { _ in
            if text.isEmpty {
                analysisResults.removeAll()
            } else {
                analyzeText()
            }
        }
    }
    
    private func analyzeText() {
        var results: [AnalysisItem] = []
        
        // Basic Statistics
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let wordCount = words.count
        let charCount = text.count
        let charWithoutSpaces = text.replacingOccurrences(of: " ", with: "").count
        let lineCount = text.components(separatedBy: .newlines).count
        let sentenceCount = text.components(separatedBy: CharacterSet(charactersIn: ".!?")).count - 1
        let paragraphCount = text.components(separatedBy: "\n\n").count
        
        results.append(AnalysisItem(title: "Basic Statistics", value: "\(wordCount) words, \(charCount) characters", icon: "textformat.abc", color: .blue))
        results.append(AnalysisItem(title: "Characters (no spaces)", value: "\(charWithoutSpaces) characters", icon: "character", color: .green))
        results.append(AnalysisItem(title: "Lines & Paragraphs", value: "\(lineCount) lines, \(paragraphCount) paragraphs", icon: "text.justify", color: .orange))
        results.append(AnalysisItem(title: "Sentences", value: "\(sentenceCount) sentences", icon: "text.quote", color: .purple))
        
        // Advanced Analysis
        let uniqueWords = Set(words.map { $0.lowercased() })
        let avgWordLength = wordCount > 0 ? Double(charWithoutSpaces) / Double(wordCount) : 0
        let readingTime = calculateReadingTime(wordCount)
        
        results.append(AnalysisItem(title: "Unique Words", value: "\(uniqueWords.count) unique words", icon: "text.magnifyingglass", color: .red))
        results.append(AnalysisItem(title: "Average Word Length", value: String(format: "%.1f letters", avgWordLength), icon: "ruler", color: .yellow))
        results.append(AnalysisItem(title: "Reading Time", value: "~\(readingTime) minute\(readingTime == 1 ? "" : "s")", icon: "clock.fill", color: .teal))
        
        // Content Type Detection
        let contentType = detectContentType(text)
        results.append(AnalysisItem(title: "Content Type", value: contentType, icon: "doc.text", color: .indigo))
        
        analysisResults = results
    }
    
    private func calculateReadingTime(_ wordCount: Int) -> Int {
        let wordsPerMinute = 200
        return max(1, wordCount / wordsPerMinute)
    }
    
    private func detectContentType(_ text: String) -> String {
        if text.contains("@") && text.contains(".com") {
            return "Email/Contact"
        } else if text.range(of: #"\d{1,2}/\d{1,2}/\d{4}"#, options: .regularExpression) != nil {
            return "Date Content"
        } else if text.range(of: #"\b\d{3}[-.]?\d{3}[-.]?\d{4}\b"#, options: .regularExpression) != nil {
            return "Phone Numbers"
        } else if text.count < 50 {
            return "Short Text"
        } else if text.count > 500 {
            return "Long Document"
        } else {
            return "General Text"
        }
    }
}

// MARK: - Screen 4: Templates & Presets
struct TemplatesView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State private var searchText = ""
    @State private var selectedCategory = 0
    @State private var textTemplates: [TextTemplate] = []
    @State private var showCopiedAlert = false
    
    let categories = ["All", "Social Media", "Business", "Academic", "Creative", "Technical"]
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : .white
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var filteredTemplates: [TextTemplate] {
        if selectedCategory == 0 {
            return textTemplates
        } else {
            let category = categories[selectedCategory]
            return textTemplates.filter { $0.category == category }
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text Templates")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    Text("Ready-to-use text templates")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search templates...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(textColor)
                }
                .padding(12)
                .background(cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            CategoryChip(
                                title: categories[index],
                                isSelected: selectedCategory == index,
                                textColor: textColor,
                                accentColor: .blue,
                                cardBackground: cardBackground
                            ) {
                                selectedCategory = index
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 16)
                
                // Templates Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(
                                template: template,
                                textColor: textColor,
                                cardBackground: cardBackground
                            ) {
                                UIPasteboard.general.string = template.content
                                showCopiedAlert = true
                            }
                        }
                    }
                    .padding()
                }
                
                if textTemplates.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Templates",
                        description: "Text templates will appear here",
                        textColor: textColor
                    )
                }
                
                Spacer()
                
                // Quick Actions
                VStack(spacing: 12) {
                    Text("Quick Actions")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    HStack(spacing: 12) {
                        ActionButton(
                            icon: "plus.circle",
                            title: "New Template",
                            color: .green,
                            cardBackground: cardBackground
                        ) {
                            // Create new template
                        }
                        
                        ActionButton(
                            icon: "square.and.arrow.down",
                            title: "Import",
                            color: .blue,
                            cardBackground: cardBackground
                        ) {
                            // Import templates
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTemplates()
        }
        .alert("Copied to Clipboard", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Template has been copied to your clipboard. You can now paste it anywhere.")
        }
    }
    
    private func loadTemplates() {
        textTemplates = [
            TextTemplate(id: "1", title: "Email Signature", description: "Professional email signature template", category: "Business", content: "Best regards,\n[Your Name]\n[Your Position]\n[Your Company]\nEmail: [your.email@company.com]\nPhone: [Your Phone Number]"),
            
            TextTemplate(id: "2", title: "Social Media Post", description: "Engaging social media content template", category: "Social Media", content: "Excited to share something amazing! 🚀\n\nJust launched [Your Project/Update] and can't wait to hear what you think!\n\n#exciting #news #update #launch"),
            
            TextTemplate(id: "3", title: "Meeting Agenda", description: "Structured meeting outline template", category: "Business", content: "Meeting Agenda\n\nDate: [Date]\nTime: [Time]\nLocation: [Location/Virtual]\n\n1. Review of previous meeting action items\n2. Current updates and progress\n3. Key discussion topics\n   - Topic 1\n   - Topic 2\n4. Action items and responsibilities\n5. Next steps and follow-up\n6. Next meeting date"),
            
            TextTemplate(id: "4", title: "Creative Writing Starter", description: "Story opening template for creative writing", category: "Creative", content: "The rain fell in sheets, obscuring the city lights that usually glittered like scattered diamonds. Somewhere in the distance, a clock struck midnight, its chimes swallowed by the storm. [Character Name] stood at the window, watching the water trace paths down the glass, each droplet carrying secrets the night refused to tell."),
            
            TextTemplate(id: "5", title: "Code Documentation", description: "Professional code documentation template", category: "Technical", content: "/**\n * Function: [Function Name]\n * Description: [Brief description of what the function does]\n * Parameters: [List and describe parameters]\n *   - param1: [Description]\n *   - param2: [Description]\n * Returns: [Description of return value]\n * Throws: [Exceptions thrown, if any]\n * Example:\n *   [Usage example]\n */"),
            
            TextTemplate(id: "6", title: "Academic Abstract", description: "Research paper abstract template", category: "Academic", content: "This study examines [research topic] through [methodology/approach]. Using [data sources/methods], we analyze [specific aspects]. Results indicate [key findings], which demonstrate [significance of findings]. These findings suggest [implications/conclusions] for [relevant field/industry]. The research contributes to [field] by [specific contributions]."),
            
            TextTemplate(id: "7", title: "Project Proposal", description: "Formal project proposal template", category: "Business", content: "Project Proposal: [Project Name]\n\n1. Executive Summary\n   [Brief overview of the project]\n\n2. Objectives\n   - Primary objective 1\n   - Secondary objective 2\n   - Key deliverables\n\n3. Methodology\n   [Approach and methods to be used]\n\n4. Timeline\n   [Project schedule and milestones]\n\n5. Budget\n   [Cost estimates and resources]\n\n6. Expected Outcomes\n   [Anticipated results and benefits]"),
            
            TextTemplate(id: "8", title: "Product Description", description: "E-commerce product description template", category: "Business", content: "Discover the [Product Name] - [Key benefit/feature].\n\n🌟 Key Features:\n• [Feature 1 with benefit]\n• [Feature 2 with benefit]\n• [Feature 3 with benefit]\n\n💡 Perfect For:\n• [Use case 1]\n• [Use case 2]\n• [Use case 3]\n\n🎯 Specifications:\n• [Spec 1]\n• [Spec 2]\n• [Spec 3]\n\nTransform your [relevant activity] today with [Product Name]!"),
            
            TextTemplate(id: "9", title: "Press Release", description: "Professional press release template", category: "Business", content: "FOR IMMEDIATE RELEASE\n\n[Headline in Title Case]\n\n[CITY, STATE] - [Date] - [Company Name], a [brief company description], today announced [main news/announcement].\n\n[Body paragraph with details and quotes]\n\n\"[Quote from relevant person]\" said [Name], [Title] at [Company]. \"[Supporting quote].\"\n\n[Additional details and information]\n\nAbout [Company Name]:\n[Company description and background]\n\nMedia Contact:\n[Contact Name]\n[Contact Title]\n[Email]\n[Phone]\n[Website]")
        ]
    }
}

// MARK: - Screen 5: Settings & Tools
struct SettingsToolsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("textSize") private var textSize: Double = 16
    @AppStorage("enableHaptics") private var enableHaptics = true
    @AppStorage("enableAutoSave") private var enableAutoSave = false
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    let languages = ["English", "Spanish", "French", "German", "Chinese", "Japanese", "Hindi", "Arabic"]
    
    var backgroundColor: Color {
        isDarkMode ? Color(.systemGray6) : .white
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
    
    var textColor: Color {
        isDarkMode ? .white : .black
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings & Tools")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        Text("Customize your experience")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Appearance Settings
                    SettingsSection(title: "Appearance", icon: "paintbrush", textColor: textColor) {
                        SettingsToggleRow(
                            icon: "moon.fill",
                            title: "Dark Mode",
                            isOn: $isDarkMode,
                            textColor: textColor
                        )
                        
                        SettingsSliderRow(
                            icon: "textformat.size",
                            title: "Text Size",
                            value: $textSize,
                            range: 12...24,
                            textColor: textColor
                        )
                    }
                    
                    // Behavior Settings
                    SettingsSection(title: "Behavior", icon: "gearshape", textColor: textColor) {
                        SettingsToggleRow(
                            icon: "hand.tap.fill",
                            title: "Haptic Feedback",
                            isOn: $enableHaptics,
                            textColor: textColor
                        )
                        
                        SettingsToggleRow(
                            icon: "square.and.arrow.down",
                            title: "Auto Save",
                            isOn: $enableAutoSave,
                            textColor: textColor
                        )
                    }
                    
                    // Language Settings
                    SettingsSection(title: "Language", icon: "globe", textColor: textColor) {
                        SettingsPickerRow(
                            icon: "character.bubble",
                            title: "App Language",
                            selection: $selectedLanguage,
                            options: languages,
                            textColor: textColor
                        )
                    }
                    
                    // Tools Section
                    SettingsSection(title: "Tools", icon: "wrench.and.screwdriver", textColor: textColor) {
                        ToolButton(
                            icon: "trash",
                            title: "Clear All Data",
                            color: .red,
                            cardBackground: cardBackground
                        ) {
                            clearAllData()
                        }
                        
                        ToolButton(
                            icon: "arrow.clockwise",
                            title: "Reset Settings",
                            color: .orange,
                            cardBackground: cardBackground
                        ) {
                            resetSettings()
                        }
                        
                        ToolButton(
                            icon: "square.and.arrow.up",
                            title: "Export Settings",
                            color: .blue,
                            cardBackground: cardBackground
                        ) {
                            // Export settings action
                        }
                    }
                    
                    // App Info
                    SettingsSection(title: "About", icon: "info.circle", textColor: textColor) {
                        InfoRow(icon: "app.badge", title: "Version", value: "2.0.0", textColor: textColor)
                        InfoRow(icon: "calendar", title: "Build Date", value: "2024", textColor: textColor)
                        InfoRow(icon: "person.2", title: "Developer", value: "Text Transformer Team", textColor: textColor)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func resetSettings() {
        isDarkMode = true
        textSize = 16
        enableHaptics = true
        enableAutoSave = false
        selectedLanguage = "English"
    }
    
    private func clearAllData() {
        // Clear all user defaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        resetSettings()
    }
}

// MARK: - Data Models

struct Transformation: Identifiable {
    let id: String
    let name: String
    let description: String
    let category: String
}

struct AnalysisItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct TextTemplate: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let content: String
}

enum CardType {
    case favorite, history
}

// MARK: - Reusable Components

struct FavoriteHistoryCard: View {
    let transformation: Transformation
    let type: CardType
    let textColor: Color
    let cardBackground: Color
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type == .favorite ? "star.fill" : "clock.fill")
                .foregroundColor(type == .favorite ? .yellow : .blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transformation.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor)
                Text(transformation.description)
                    .font(.system(size: 12))
                    .foregroundColor(textColor.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

struct AnalysisCard: View {
    let item: AnalysisItem
    let textColor: Color
    let cardBackground: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .foregroundColor(item.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor)
                Text(item.value)
                    .font(.system(size: 12))
                    .foregroundColor(textColor.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
    }
}

struct TemplateCard: View {
    let template: TextTemplate
    let textColor: Color
    let cardBackground: Color
    let onUse: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(template.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                
                Spacer()
                
                Text(template.category)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
            
            Text(template.description)
                .font(.system(size: 12))
                .foregroundColor(textColor.opacity(0.7))
                .lineLimit(2)
            
            Text(template.content)
                .font(.system(size: 11))
                .foregroundColor(textColor.opacity(0.6))
                .lineLimit(3)
                .padding(8)
                .background(Color.black.opacity(0.2))
                .cornerRadius(6)
            
            Spacer()
            
            Button(action: onUse) {
                Text("Use Template")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .frame(minHeight: 160)
        .background(cardBackground)
        .cornerRadius(12)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let textColor: Color
    let content: Content
    
    init(title: String, icon: String, textColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.textColor = textColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
                Spacer()
            }
            
            VStack(spacing: 8) {
                content
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    let textColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(textColor)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct SettingsSliderRow: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let textColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(textColor)
                
                Spacer()
                
                Text("\(Int(value))")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            Slider(value: $value, in: range, step: 1)
        }
    }
}

struct SettingsPickerRow: View {
    let icon: String
    let title: String
    @Binding var selection: String
    let options: [String]
    let textColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(textColor)
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct ToolButton: View {
    let icon: String
    let title: String
    let color: Color
    let cardBackground: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let textColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(textColor)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

struct StatBadge: View {
    let count: Int
    let label: String
    let color: Color
    let textColor: Color
    let cardBackground: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(cardBackground)
        .cornerRadius(12)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let textColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Original Components

struct StatsOverview: View {
    let text: String
    let textColor: Color
    let cardBackground: Color
    
    private var wordCount: Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private var lineCount: Int {
        text.components(separatedBy: .newlines).count
    }
    
    private var readingTime: String {
        let wordsPerMinute = 200.0
        let wordCount = Double(self.wordCount)
        let minutes = wordCount / wordsPerMinute
        return String(format: "%.1f", max(0.1, minutes))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatItem(value: "\(text.count)", label: "Chars", color: .blue, textColor: textColor, cardBackground: cardBackground)
            StatItem(value: "\(wordCount)", label: "Words", color: .green, textColor: textColor, cardBackground: cardBackground)
            StatItem(value: "\(lineCount)", label: "Lines", color: .orange, textColor: textColor, cardBackground: cardBackground)
            StatItem(value: "\(readingTime)m", label: "Read", color: .purple, textColor: textColor, cardBackground: cardBackground)
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    let textColor: Color
    let cardBackground: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(cardBackground)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let textColor: Color
    let accentColor: Color
    let cardBackground: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : textColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? accentColor : cardBackground)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TransformationCard: View {
    let transformation: Transformation
    let isFavorite: Bool
    let textColor: Color
    let accentColor: Color
    let cardBackground: Color
    let onTap: () -> Void
    let onFavorite: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: getIconForTransformation(transformation.id))
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                        .frame(width: 20)
                    
                    Text(transformation.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textColor)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 12))
                            .foregroundColor(isFavorite ? .red : textColor.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(transformation.description)
                    .font(.system(size: 11))
                    .foregroundColor(textColor.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
            .background(cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIconForTransformation(_ id: String) -> String {
        switch id {
        case _ where id.contains("Case"): return "textformat"
        case _ where id.contains("Text"): return "text.bubble"
        case _ where id.contains("Font"): return "textformat"
        case _ where id.contains("Remove"): return "trash"
        case _ where id.contains("Duplicate"): return "doc.on.doc"
        case _ where id.contains("Encode"): return "lock"
        case _ where id.contains("Decode"): return "lock.open"
        case _ where id.contains("Format"): return "doc.text"
        default: return "wand.and.stars"
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let cardBackground: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Transformations Data

let transformations: [Transformation] = [
    // Case & Formatting
    Transformation(id: "sentenceCase", name: "Sentence Case", description: "Capitalize first letter of each sentence", category: "Case & Formatting"),
    Transformation(id: "lowercase", name: "lower case", description: "Convert to lowercase", category: "Case & Formatting"),
    Transformation(id: "uppercase", name: "UPPER CASE", description: "Convert to uppercase", category: "Case & Formatting"),
    Transformation(id: "capitalized", name: "Capitalized Case", description: "Capitalize Each Word", category: "Case & Formatting"),
    Transformation(id: "titleCase", name: "Title Case", description: "Title Style Capitalization", category: "Case & Formatting"),
    Transformation(id: "alternatingCase", name: "aLtErNaTiNg cAsE", description: "Alternate between upper and lower case", category: "Case & Formatting"),
    Transformation(id: "inverseCase", name: "InVeRsE CaSe", description: "Swap case of all letters", category: "Case & Formatting"),
    
    // Social Media Fonts
    Transformation(id: "boldText", name: "Bold Text", description: "Convert to bold unicode", category: "Social Media"),
    Transformation(id: "italicText", name: "Italic Text", description: "Convert to italic unicode", category: "Social Media"),
    Transformation(id: "smallText", name: "Small Text", description: "Tiny unicode characters", category: "Social Media"),
    Transformation(id: "bubbleText", name: "Bubble Text", description: "Ⓣⓔⓧⓣ ⓘⓝ ⓑⓤⓑⓑⓛⓔⓢ", category: "Social Media"),
    Transformation(id: "gothicText", name: "Gothic Text", description: "𝔊𝔬𝔱𝔥𝔦𝔠 𝔰𝔱𝔶𝔩𝔢 𝔱𝔢𝔵𝔱", category: "Social Media"),
    Transformation(id: "wideText", name: "Wide Text", description: "Ｗｉｄｅ　ｔｅｘｔ　ｃｈａｒａｃｔｅｒｓ", category: "Social Media"),
    Transformation(id: "superscript", name: "Superscript", description: "ˢᵘᵖᵉʳˢᶜʳᶦᵖᵗ ᵗᵉˣᵗ", category: "Social Media"),
    Transformation(id: "subscript", name: "Subscript", description: "ₛᵤᵦₛ꜀ᵣᵢₚₜ ₜₑₓₜ", category: "Social Media"),
    Transformation(id: "strikethrough", name: "Strikethrough", description: "S̶t̶r̶i̶k̶e̶t̶h̶r̶o̶u̶g̶h̶ ̶t̶e̶x̶t̶", category: "Social Media"),
    Transformation(id: "underline", name: "Underline", description: "U̲n̲d̲e̲r̲l̲i̲n̲e̲ ̲t̲e̲x̲t̲", category: "Social Media"),
    Transformation(id: "discordFont", name: "Discord Font", description: "Special font for Discord", category: "Social Media"),
    Transformation(id: "instagramFont", name: "Instagram Font", description: "Stylish fonts for Instagram", category: "Social Media"),
    Transformation(id: "twitterFont", name: "Twitter Font", description: "Fonts for X/Twitter", category: "Social Media"),
    Transformation(id: "facebookFont", name: "Facebook Font", description: "Fonts for Facebook", category: "Social Media"),
    
    // Text Effects
    Transformation(id: "reverseText", name: "Reverse Text", description: "txet esreveR", category: "Text Effects"),
    Transformation(id: "upsideDown", name: "Upside Down", description: "ʇxǝʇ uʍop-ǝpᴉsdn", category: "Text Effects"),
    Transformation(id: "mirrorText", name: "Mirror Text", description: "ɟxǝʇ ɹoɹɹᴉW", category: "Text Effects"),
    Transformation(id: "zalgoText", name: "Zalgo Text", description: "C̵o̵r̵r̵u̵p̵t̵e̵d̵ text", category: "Text Effects"),
    Transformation(id: "invisibleText", name: "Invisible Text", description: "Empty/zero-width characters", category: "Text Effects"),
    Transformation(id: "cursedText", name: "Cursed Text", description: "Weird text effects", category: "Text Effects"),
    Transformation(id: "slashText", name: "Slash Text", description: "T/e/x/t/ /w/i/t/h/ /s/l/a/s/h/e/s", category: "Text Effects"),
    Transformation(id: "stackedText", name: "Stacked Text", description: "T\ne\nx\nt", category: "Text Effects"),
    Transformation(id: "wingdings", name: "Wingdings", description: "Convert to Wingdings symbols", category: "Text Effects"),
    Transformation(id: "whitespaceText", name: "Whitespace Text", description: "Text with extra spaces", category: "Text Effects"),
    
    // Cleanup & Analysis
    Transformation(id: "removeSpaces", name: "Remove Spaces", description: "Delete all spaces", category: "Cleanup & Analysis"),
    Transformation(id: "removeLineBreaks", name: "Remove Line Breaks", description: "Convert to single line", category: "Cleanup & Analysis"),
    Transformation(id: "removeUnderscores", name: "Remove Underscores", description: "Delete all _ characters", category: "Cleanup & Analysis"),
    Transformation(id: "removeFormatting", name: "Remove Formatting", description: "Strip all formatting", category: "Cleanup & Analysis"),
    Transformation(id: "removeLetters", name: "Remove Letters", description: "Keep only numbers/symbols", category: "Cleanup & Analysis"),
    Transformation(id: "duplicateLineRemover", name: "Duplicate Line Remover", description: "Remove repeated lines", category: "Cleanup & Analysis"),
    Transformation(id: "duplicateWordFinder", name: "Duplicate Word Finder", description: "Find repeated words", category: "Cleanup & Analysis"),
    Transformation(id: "plainText", name: "Plain Text", description: "Convert to plain text only", category: "Cleanup & Analysis"),
    Transformation(id: "whitespaceRemover", name: "Whitespace Remover", description: "Remove extra spaces", category: "Cleanup & Analysis"),
    Transformation(id: "addLineNumbers", name: "Add Line Numbers", description: "Number each line", category: "Cleanup & Analysis"),
    Transformation(id: "sortLines", name: "Sort Lines", description: "Alphabetical line order", category: "Cleanup & Analysis"),
    
    // Encoding & Technical
    Transformation(id: "apaFormat", name: "APA Format", description: "Academic citation format", category: "Encoding & Technical"),
    Transformation(id: "phoneticSpelling", name: "Phonetic Spelling", description: "Foh-NEH-tik SPEL-ing", category: "Encoding & Technical"),
    Transformation(id: "pigLatin", name: "Pig Latin", description: "Igpay Atinlay anslatortray", category: "Encoding & Technical"),
    Transformation(id: "unicodeText", name: "Unicode Text", description: "Convert to unicode points", category: "Encoding & Technical"),
    Transformation(id: "base64Encode", name: "Base64 Encode", description: "Encode to base64", category: "Encoding & Technical"),
    Transformation(id: "base64Decode", name: "Base64 Decode", description: "Decode from base64", category: "Encoding & Technical"),
    Transformation(id: "extractEmails", name: "Extract Emails", description: "Find email addresses", category: "Encoding & Technical"),
    Transformation(id: "compressText", name: "Text Compress", description: "Remove extra whitespace", category: "Encoding & Technical"),
    Transformation(id: "bigText", name: "Big Text", description: "Large unicode characters", category: "Encoding & Technical")
]

// MARK: - String Extensions (Keep all your existing string extension methods)

extension String {
    // Social Media Fonts
    func unicodeBold() -> String {
        let boldMap: [Character: String] = [
            "a": "𝗮", "b": "𝗯", "c": "𝗰", "d": "𝗱", "e": "𝗲", "f": "𝗳", "g": "𝗴", "h": "𝗵",
            "i": "𝗶", "j": "𝗷", "k": "𝗸", "l": "𝗹", "m": "𝗺", "n": "𝗻", "o": "𝗼", "p": "𝗽",
            "q": "𝗾", "r": "𝗿", "s": "𝘀", "t": "𝘁", "u": "𝘂", "v": "𝘃", "w": "𝘄", "x": "𝘅",
            "y": "𝘆", "z": "𝘇", "A": "𝗔", "B": "𝗕", "C": "𝗖", "D": "𝗗", "E": "𝗘", "F": "𝗙",
            "G": "𝗚", "H": "𝗛", "I": "𝗜", "J": "𝗝", "K": "𝗞", "L": "𝗟", "M": "𝗠", "N": "𝗡",
            "O": "𝗢", "P": "𝗣", "Q": "𝗤", "R": "𝗥", "S": "𝗦", "T": "𝗧", "U": "𝗨", "V": "𝗩",
            "W": "𝗪", "X": "𝗫", "Y": "𝗬", "Z": "𝗭"
        ]
        return self.map { boldMap[$0] ?? String($0) }.joined()
    }
    
    func unicodeItalic() -> String {
        let italicMap: [Character: String] = [
            "a": "𝑎", "b": "𝑏", "c": "𝑐", "d": "𝑑", "e": "𝑒", "f": "𝑓", "g": "𝑔", "h": "ℎ",
            "i": "𝑖", "j": "𝑗", "k": "𝑘", "l": "𝑙", "m": "𝑚", "n": "𝑛", "o": "𝑜", "p": "𝑝",
            "q": "𝑞", "r": "𝑟", "s": "𝑠", "t": "𝑡", "u": "𝑢", "v": "𝑣", "w": "𝑤", "x": "𝑥",
            "y": "𝑦", "z": "𝑧", "A": "𝐴", "B": "𝐵", "C": "𝐶", "D": "𝐷", "E": "𝐸", "F": "𝐹",
            "G": "𝐺", "H": "𝐻", "I": "𝐼", "J": "𝐽", "K": "𝐾", "L": "𝐿", "M": "𝑀", "N": "𝑁",
            "O": "𝑂", "P": "𝑃", "Q": "𝑄", "R": "𝑅", "S": "𝑆", "T": "𝑇", "U": "𝑈", "V": "𝑉",
            "W": "𝑊", "X": "𝑋", "Y": "𝑌", "Z": "𝑍"
        ]
        return self.map { italicMap[$0] ?? String($0) }.joined()
    }
    
    func unicodeSmall() -> String {
        let smallMap: [Character: String] = [
            "a": "ᵃ", "b": "ᵇ", "c": "ᶜ", "d": "ᵈ", "e": "ᵉ", "f": "ᶠ", "g": "ᵍ", "h": "ʰ",
            "i": "ᶦ", "j": "ʲ", "k": "ᵏ", "l": "ˡ", "m": "ᵐ", "n": "ⁿ", "o": "ᵒ", "p": "ᵖ",
            "q": "ᑫ", "r": "ʳ", "s": "ˢ", "t": "ᵗ", "u": "ᵘ", "v": "ᵛ", "w": "ʷ", "x": "ˣ",
            "y": "ʸ", "z": "ᶻ", "A": "ᴬ", "B": "ᴮ", "C": "ᶜ", "D": "ᴰ", "E": "ᴱ", "F": "ᶠ",
            "G": "ᴳ", "H": "ᴴ", "I": "ᴵ", "J": "ᴶ", "K": "ᴷ", "L": "ᴸ", "M": "ᴹ", "N": "ᴺ",
            "O": "ᴼ", "P": "ᴾ", "Q": "ᑫ", "R": "ᴿ", "S": "ˢ", "T": "ᵀ", "U": "ᵁ", "V": "ⱽ",
            "W": "ᵂ", "X": "ˣ", "Y": "ʸ", "Z": "ᶻ"
        ]
        return self.map { smallMap[$0] ?? String($0) }.joined()
    }
    
    func bubbleText() -> String {
        let bubbleMap: [Character: String] = [
            "a": "ⓐ", "b": "ⓑ", "c": "ⓒ", "d": "ⓓ", "e": "ⓔ", "f": "ⓕ", "g": "ⓖ", "h": "ⓗ",
            "i": "ⓘ", "j": "ⓙ", "k": "ⓚ", "l": "ⓛ", "m": "ⓜ", "n": "ⓝ", "o": "ⓞ", "p": "ⓟ",
            "q": "ⓠ", "r": "ⓡ", "s": "ⓢ", "t": "ⓣ", "u": "ⓤ", "v": "ⓥ", "w": "ⓦ", "x": "ⓧ",
            "y": "ⓨ", "z": "ⓩ", "A": "Ⓐ", "B": "Ⓑ", "C": "Ⓒ", "D": "Ⓓ", "E": "Ⓔ", "F": "Ⓕ",
            "G": "Ⓖ", "H": "Ⓗ", "I": "Ⓘ", "J": "Ⓙ", "K": "Ⓚ", "L": "Ⓛ", "M": "Ⓜ", "N": "Ⓝ",
            "O": "Ⓞ", "P": "Ⓟ", "Q": "Ⓠ", "R": "Ⓡ", "S": "Ⓢ", "T": "Ⓣ", "U": "Ⓤ", "V": "Ⓥ",
            "W": "Ⓦ", "X": "Ⓧ", "Y": "Ⓨ", "Z": "Ⓩ", "0": "⓪", "1": "①", "2": "②", "3": "③",
            "4": "④", "5": "⑤", "6": "⑥", "7": "⑦", "8": "⑧", "9": "⑨"
        ]
        return self.map { bubbleMap[$0] ?? String($0) }.joined()
    }
    
    func gothicText() -> String {
        let gothicMap: [Character: String] = [
            "A": "𝔄", "B": "𝔅", "C": "ℭ", "D": "𝔇", "E": "𝔈", "F": "𝔉", "G": "𝔊", "H": "ℌ",
            "I": "ℑ", "J": "𝔍", "K": "𝔎", "L": "𝔏", "M": "𝔐", "N": "𝔑", "O": "𝔒", "P": "𝔓",
            "Q": "𝔔", "R": "ℜ", "S": "𝔖", "T": "𝔗", "U": "𝔘", "V": "𝔙", "W": "𝔚", "X": "𝔛",
            "Y": "𝔜", "Z": "ℨ"
        ]
        return self.map { gothicMap[$0] ?? String($0) }.joined()
    }
    
    func wideText() -> String {
        let wideMap: [Character: String] = [
            "a": "ａ", "b": "ｂ", "c": "ｃ", "d": "ｄ", "e": "ｅ", "f": "ｆ", "g": "ｇ", "h": "ｈ",
            "i": "ｉ", "j": "ｊ", "k": "ｋ", "l": "ｌ", "m": "ｍ", "n": "ｎ", "o": "ｏ", "p": "ｐ",
            "q": "ｑ", "r": "ｒ", "s": "ｓ", "t": "ｔ", "u": "ｕ", "v": "ｖ", "w": "ｗ", "x": "ｘ",
            "y": "ｙ", "z": "ｚ", "A": "Ａ", "B": "Ｂ", "C": "Ｃ", "D": "Ｄ", "E": "Ｅ", "F": "Ｆ",
            "G": "Ｇ", "H": "Ｈ", "I": "Ｉ", "J": "Ｊ", "K": "Ｋ", "L": "Ｌ", "M": "Ｍ", "N": "Ｎ",
            "O": "Ｏ", "P": "Ｐ", "Q": "Ｑ", "R": "Ｒ", "S": "Ｓ", "T": "Ｔ", "U": "Ｕ", "V": "Ｖ",
            "W": "Ｗ", "X": "Ｘ", "Y": "Ｙ", "Z": "Ｚ", "0": "０", "1": "１", "2": "２", "3": "３",
            "4": "４", "5": "５", "6": "６", "7": "７", "8": "８", "9": "９"
        ]
        return self.map { wideMap[$0] ?? String($0) }.joined()
    }
    
    func superscript() -> String {
        let superscriptMap: [Character: String] = [
            "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵", "6": "⁶", "7": "⁷",
            "8": "⁸", "9": "⁹", "a": "ᵃ", "b": "ᵇ", "c": "ᶜ", "d": "ᵈ", "e": "ᵉ", "f": "ᶠ",
            "g": "ᵍ", "h": "ʰ", "i": "ᶦ", "j": "ʲ", "k": "ᵏ", "l": "ˡ", "m": "ᵐ", "n": "ⁿ",
            "o": "ᵒ", "p": "ᵖ", "r": "ʳ", "s": "ˢ", "t": "ᵗ", "u": "ᵘ", "v": "ᵛ", "w": "ʷ",
            "x": "ˣ", "y": "ʸ", "z": "ᶻ", "+": "⁺", "-": "⁻", "=": "⁼", "(": "⁽", ")": "⁾"
        ]
        return self.map { superscriptMap[$0] ?? String($0) }.joined()
    }
    
    func subscriptText() -> String {
        let subscriptMap: [Character: String] = [
            "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄", "5": "₅", "6": "₆", "7": "₇",
            "8": "₈", "9": "₉", "a": "ₐ", "e": "ₑ", "h": "ₕ", "i": "ᵢ", "k": "ₖ", "l": "ₗ",
            "m": "ₘ", "n": "ₙ", "o": "ₒ", "p": "ₚ", "r": "ᵣ", "s": "ₛ", "t": "ₜ", "u": "ᵤ",
            "v": "ᵥ", "x": "ₓ", "+": "₊", "-": "₋", "=": "₌", "(": "₍", ")": "₎"
        ]
        return self.map { subscriptMap[$0] ?? String($0) }.joined()
    }
    
    func strikethroughText() -> String {
        return self.map { "\($0)\u{0336}" }.joined()
    }
    
    func underlineText() -> String {
        return self.map { "\($0)\u{0332}" }.joined()
    }
    
    // Text Effects
    func upsideDown() -> String {
        let mapping: [Character: String] = [
            "a": "ɐ", "b": "q", "c": "ɔ", "d": "p", "e": "ǝ", "f": "ɟ", "g": "ƃ", "h": "ɥ",
            "i": "ᴉ", "j": "ɾ", "k": "ʞ", "l": "l", "m": "ɯ", "n": "u", "o": "o", "p": "d",
            "q": "b", "r": "ɹ", "s": "s", "t": "ʇ", "u": "n", "v": "ʌ", "w": "ʍ", "x": "x",
            "y": "ʎ", "z": "z", "A": "∀", "B": "B", "C": "Ɔ", "D": "D", "E": "Ǝ", "F": "Ⅎ",
            "G": "פ", "H": "H", "I": "I", "J": "ſ", "K": "ʞ", "L": "˥", "M": "W", "N": "N",
            "O": "O", "P": "Ԁ", "Q": "Q", "R": "ᴚ", "S": "S", "T": "⊥", "U": "∩", "V": "Λ",
            "W": "M", "X": "X", "Y": "ʎ", "Z": "Z", "0": "0", "1": "Ɩ", "2": "ᄅ", "3": "Ɛ",
            "4": "ㄣ", "5": "ϛ", "6": "9", "7": "ㄥ", "8": "8", "9": "6", ".": "˙", ",": "'",
            "'": ",", "!": "¡", "?": "¿", "(": ")", ")": "(", "[": "]", "]": "[",
            "{": "}", "}": "{", "<": ">", ">": "<", "&": "⅋", "_": "‾"
        ]
        
        let transformed = self.map { mapping[$0] ?? String($0) }
        return transformed.reversed().joined()
    }
    
    func mirrorText() -> String {
        return String(self.reversed())
    }
    
    func zalgoText() -> String {
        let zalgoChars = ["̍", "̎", "̄", "̅", "̿", "̑", "̆", "̐", "͒", "͗", "͑", "̇", "̈", "̊", "͂", "̓", "̈", "͊", "͋", "͌", "̃", "̂", "̌", "͐", "̀", "́", "̋", "̏", "̒", "̓", "̔", "̽", "̉", "ͣ", "ͤ", "ͥ", "ͦ", "ͧ", "ͨ", "ͩ", "ͪ", "ͫ", "ͬ", "ͭ", "ͮ", "ͯ", "̾", "͛", "͆", "̚"]
        return self.map { char in
            let base = String(char)
            let zalgoCount = Int.random(in: 1...3)
            let zalgoAdditions = (0..<zalgoCount).map { _ in zalgoChars.randomElement() ?? "" }.joined()
            return base + zalgoAdditions
        }.joined()
    }
    
    func invisibleText() -> String {
        return self.map { _ in "\u{200B}" }.joined()
    }
    
    func cursedText() -> String {
        return self.map { char in
            let cursed = [String(char), "҉", "̴", "̷", "̸"].randomElement() ?? String(char)
            return cursed
        }.joined()
    }
    
    func slashText() -> String {
        return self.map { "\($0)/" }.joined().dropLast().description
    }
    
    func stackedText() -> String {
        return self.map { "\($0)\n" }.joined()
    }
    
    func wingdings() -> String {
        let wingdingsMap: [Character: String] = [
            "a": "✌", "b": "☜", "c": "☞", "d": "☝", "e": "☟", "f": "✋", "g": "☺", "h": "🙏",
            "i": "👌", "j": "👍", "k": "👎", "l": "☹", "m": "💣", "n": "☠", "o": "⚡", "p": "🔑",
            "q": "💎", "r": "👁", "s": "⭐", "t": "🌙", "u": "☁", "v": "🌂", "w": "✂", "x": "📁",
            "y": "📂", "z": "👓", "A": "♈", "B": "♉", "C": "♊", "D": "♋", "E": "♌", "F": "♍",
            "G": "♎", "H": "♏", "I": "♐", "J": "♑", "K": "♒", "L": "♓", "M": "M", "N": "N",
            "O": "●", "P": "❍", "Q": "■", "R": "□", "S": "⧄", "T": "◆", "U": "❖", "V": "⬟",
            "W": "⬢", "X": "⬡", "Y": "⭔", "Z": "◎"
        ]
        return self.map { wingdingsMap[$0] ?? String($0) }.joined()
    }
    
    func whitespaceText() -> String {
        return self.map { "\($0) " }.joined().trimmingCharacters(in: .whitespaces)
    }
    
    // Social Media Specific
    func discordFont() -> String {
        return "```\(self)```"
    }
    
    func instagramFont() -> String {
        return self.unicodeBold() + " " + self.unicodeItalic()
    }
    
    func twitterFont() -> String {
        return "🔹 " + self.unicodeBold() + " 🔹"
    }
    
    func facebookFont() -> String {
        return "📘 " + self + " 📘"
    }
    
    // Cleanup & Analysis
    func removeDuplicateLines() -> String {
        let lines = self.components(separatedBy: .newlines)
        let uniqueLines = Array(Set(lines))
        return uniqueLines.joined(separator: "\n")
    }
    
    func findDuplicateWords() -> String {
        let words = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        let wordCounts = Dictionary(words.map { ($0, 1) }, uniquingKeysWith: +)
        let duplicates = wordCounts.filter { $0.value > 1 }
        return duplicates.map { "\($0.key): \($0.value) times" }.joined(separator: "\n")
    }
    
    func removeFormatting() -> String {
        return self.replacingOccurrences(of: "\\*\\*(.*?)\\*\\*", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "\\*(.*?)\\*", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "_(.*?)_", with: "$1", options: .regularExpression)
            .replacingOccurrences(of: "~~(.*?)~~", with: "$1", options: .regularExpression)
    }
    
    func removeLetters() -> String {
        return self.filter { !$0.isLetter }
    }
    
    func plainText() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    func compressText() -> String {
        var compressed = self
        compressed = compressed.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        compressed = compressed.replacingOccurrences(of: "\\n+", with: "\n", options: .regularExpression)
        return compressed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func addLineNumbers() -> String {
        let lines = self.components(separatedBy: .newlines)
        let numberedLines = lines.enumerated().map { "\($0.offset + 1). \($0.element)" }
        return numberedLines.joined(separator: "\n")
    }
    
    func sortLines() -> String {
        let lines = self.components(separatedBy: .newlines)
        return lines.sorted().joined(separator: "\n")
    }
    
    // Encoding & Technical
    func apaFormat() -> String {
        let lines = self.components(separatedBy: .newlines)
        let formattedLines = lines.enumerated().map { index, line in
            if index == 0 {
                return "**\(line)**" // First line as title
            } else {
                return "• \(line)" // Bullet points for others
            }
        }
        return formattedLines.joined(separator: "\n")
    }
    
    func phoneticSpelling() -> String {
        let phoneticMap: [Character: String] = [
            "a": "Alpha", "b": "Bravo", "c": "Charlie", "d": "Delta", "e": "Echo", "f": "Foxtrot",
            "g": "Golf", "h": "Hotel", "i": "India", "j": "Juliet", "k": "Kilo", "l": "Lima",
            "m": "Mike", "n": "November", "o": "Oscar", "p": "Papa", "q": "Quebec", "r": "Romeo",
            "s": "Sierra", "t": "Tango", "u": "Uniform", "v": "Victor", "w": "Whiskey", "x": "X-ray",
            "y": "Yankee", "z": "Zulu", "A": "ALPHA", "B": "BRAVO", "C": "CHARLIE", "D": "DELTA",
            "E": "ECHO", "F": "FOXTROT", "G": "GOLF", "H": "HOTEL", "I": "INDIA", "J": "JULIET",
            "K": "KILO", "L": "LIMA", "M": "MIKE", "N": "NOVEMBER", "O": "OSCAR", "P": "PAPA",
            "Q": "QUEBEC", "R": "ROMEO", "S": "SIERRA", "T": "TANGO", "U": "UNIFORM", "V": "VICTOR",
            "W": "WHISKEY", "X": "X-RAY", "Y": "YANKEE", "Z": "ZULU"
        ]
        return self.map { phoneticMap[$0] ?? String($0) }.joined(separator: " ")
    }
    
    func pigLatin() -> String {
        let words = self.components(separatedBy: .whitespaces)
        return words.map { word in
            guard let firstChar = word.first, firstChar.isLetter else { return word }
            let vowels = "aeiouAEIOU"
            if vowels.contains(firstChar) {
                return word + "ay"
            } else {
                let index = word.index(word.startIndex, offsetBy: 1)
                return String(word[index...]) + String(firstChar) + "ay"
            }
        }.joined(separator: " ")
    }
    
    func unicodeConverted() -> String {
        return self.unicodeScalars.map { "U+\(String($0.value, radix: 16).uppercased())" }.joined(separator: " ")
    }
    
    func base64Encode() -> String {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return self
    }
    
    func base64Decode() -> String {
        if let data = Data(base64Encoded: self),
           let decodedString = String(data: data, encoding: .utf8) {
            return decodedString
        }
        return self
    }
    
    func extractEmails() -> String {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        if let regex = try? NSRegularExpression(pattern: emailRegex) {
            let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            let emails = matches.map { String(self[Range($0.range, in: self)!]) }
            return emails.joined(separator: "\n")
        }
        return self
    }
    
    func bigText() -> String {
        return self.uppercased().unicodeBold()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
