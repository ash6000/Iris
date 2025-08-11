import UIKit
import AVFoundation

// MARK: - Data Models
struct SoundscapeItem {
    let id: String
    let title: String
    let duration: String
    let imageName: String
    let isFeatured: Bool
    let audioURL: URL?
    var isFavorite: Bool
    let category: String
}

struct StoryItem {
    let id: String
    let title: String
    let tag: String
    let duration: String
    let imageName: String
    var isFavorite: Bool
    let audioURL: URL?
}

struct CategoryItem {
    let title: String
    let isSelected: Bool
}

// MARK: - RelaxViewController
class RelaxViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedSegmentIndex = 0
    private var audioPlayer: AVPlayer?
    private var currentSoundscape: SoundscapeItem?
    private var selectedCategoryIndex = 0
    private var filteredSoundscapes: [SoundscapeItem] = []
    private var playbackTimeObserver: Any?
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()
    
    // Segmented Control
    private let segmentedControl = UISegmentedControl()
    
    // Content Container
    private let contentContainer = UIView()
    private let soundscapesView = UIView()
    private let sleepStoriesView = UIView()
    
    // Soundscapes Tab
    private let featuredLabel = UILabel()
    private let featuredCollectionView: UICollectionView
    private let categoriesScrollView = UIScrollView()
    private let categoriesStackView = UIStackView()
    private let moreSoundsLabel = UILabel()
    private let moreSoundsCollectionView: UICollectionView
    
    // Sleep Stories Tab
    private let searchTextField = UISearchTextField()
    private let filterButton = UIButton()
    private let storiesTableView = UITableView()
    
    // Mini Player
    private let miniPlayerView = UIView()
    private let miniPlayerTrackLabel = UILabel()
    private let miniPlayerSubtitleLabel = UILabel()
    private let miniPlayerPlayButton = UIButton()
    private let miniPlayerNextButton = UIButton()
    
    // Now Playing Sheet
    private var nowPlayingSheet: NowPlayingViewController?
    
    // Data
    private var featuredSoundscapes: [SoundscapeItem] = []
    private var moreSoundscapes: [SoundscapeItem] = []
    private var categories: [CategoryItem] = []
    private var stories: [StoryItem] = []
    
    // MARK: - Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Initialize collection views with layouts
        let featuredLayout = UICollectionViewFlowLayout()
        featuredLayout.scrollDirection = .horizontal
        featuredLayout.minimumLineSpacing = 16
        featuredLayout.minimumInteritemSpacing = 0
        featuredCollectionView = UICollectionView(frame: .zero, collectionViewLayout: featuredLayout)
        
        let moreSoundsLayout = UICollectionViewFlowLayout()
        moreSoundsLayout.minimumLineSpacing = 8
        moreSoundsLayout.minimumInteritemSpacing = 8
        moreSoundsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: moreSoundsLayout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupData()
        setupUI()
        setupConstraints()
        setupCollectionViews()
        setupTableView()
        showSoundscapesTab()
        
        // Debug: Check what's in UserDefaults on app start
        let stored = UserDefaults.standard.array(forKey: "FavoriteSoundscapes") as? [String] ?? []
        print("🚀 App started - UserDefaults contains: \(stored)")
        
        // Force reload collection views to ensure favorites are shown correctly
        featuredCollectionView.reloadData()
        moreSoundsCollectionView.reloadData()
        storiesTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Reload collection views after layout to ensure proper sizing
        featuredCollectionView.reloadData()
        moreSoundsCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        cleanupPlayer()
    }
    
    // MARK: - Data Setup
    private func setupData() {
        featuredSoundscapes = [
            SoundscapeItem(id: "forest-rain", title: "Forest Rain", duration: "45m", imageName: "🌧️", isFeatured: true, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature"),
            SoundscapeItem(id: "ocean-waves", title: "Ocean Waves", duration: "60m", imageName: "🌊", isFeatured: true, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature"),
            SoundscapeItem(id: "mountain-wind", title: "Mountain Wind", duration: "30m", imageName: "🏔️", isFeatured: true, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature")
        ]
        
        moreSoundscapes = [
            SoundscapeItem(id: "gentle-breeze", title: "Gentle Breeze", duration: "30m", imageName: "🍃", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature"),
            SoundscapeItem(id: "bird-songs", title: "Bird Songs", duration: "45m", imageName: "🐦", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature"),
            SoundscapeItem(id: "thunder-storm", title: "Thunder Storm", duration: "25m", imageName: "⚡", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature"),
            SoundscapeItem(id: "tibetan-bowls", title: "Tibetan Bowls", duration: "60m", imageName: "🎵", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Focus"),
            SoundscapeItem(id: "dripping-cave", title: "Dripping Cave", duration: "30m", imageName: "💧", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "White Noise"),
            SoundscapeItem(id: "night-crickets", title: "Night Crickets", duration: "40m", imageName: "🌙", isFeatured: false, audioURL: Bundle.main.url(forResource: "sleep music", withExtension: "mp3"), isFavorite: false, category: "Nature")
        ]
        
        categories = [
            CategoryItem(title: "Nature", isSelected: true),
            CategoryItem(title: "Focus", isSelected: false),
            CategoryItem(title: "White Noise", isSelected: false),
            CategoryItem(title: "Binaural", isSelected: false),
            CategoryItem(title: "Lofi", isSelected: false)
        ]
        
        // Load favorites FIRST, then filter
        loadFavoritesFromUserDefaults()
        loadStoryFavoritesFromUserDefaults()
        filterSoundscapesByCategory()
        
        // Ensure UI shows correct favorite states on startup
        DispatchQueue.main.async { [weak self] in
            self?.featuredCollectionView.reloadData()
            self?.moreSoundsCollectionView.reloadData()
            self?.storiesTableView.reloadData()
        }
        
        // Use sleep music MP3 for stories
        let sleepMusicURL = Bundle.main.url(forResource: "sleep music", withExtension: "mp3")
        
        stories = [
            StoryItem(id: "starlit-voyage", title: "Starlit Voyage", tag: "AI-narrated", duration: "1h 10m", imageName: "✨", isFavorite: false, audioURL: sleepMusicURL),
            StoryItem(id: "enchanted-forest", title: "Enchanted Forest", tag: "Guided", duration: "45m", imageName: "🌲", isFavorite: true, audioURL: sleepMusicURL),
            StoryItem(id: "ocean-depths", title: "Ocean Depths", tag: "AI-narrated", duration: "55m", imageName: "🐋", isFavorite: false, audioURL: sleepMusicURL),
            StoryItem(id: "mountain-cabin", title: "Mountain Cabin", tag: "Ambient", duration: "1h 25m", imageName: "🏔️", isFavorite: false, audioURL: sleepMusicURL)
        ]
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Audio Playback
    private func playAudio(for soundscape: SoundscapeItem) {
        print("🚀 playAudio called for: \(soundscape.title)")
        
        guard let audioURL = soundscape.audioURL else {
            print("❌ No audio URL found for soundscape: \(soundscape.title)")
            return
        }
        
        print("🎵 Starting playback for: \(soundscape.title)")
        print("🎵 Audio URL: \(audioURL)")
        
        // IMMEDIATELY update UI to show pause button
        miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        miniPlayerSubtitleLabel.text = "Currently playing"
        miniPlayerTrackLabel.text = soundscape.title
        print("🔄 IMMEDIATE UI update - showing pause button")
        
        // Clean up previous player
        cleanupPlayer()
        
        // Create new player
        audioPlayer = AVPlayer(url: audioURL)
        currentSoundscape = soundscape
        
        // Set volume to ensure audio is audible
        audioPlayer?.volume = 1.0
        
        // Start playback
        audioPlayer?.play()
        
        // Force UI to show pause button immediately
        DispatchQueue.main.async { [weak self] in
            self?.miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self?.miniPlayerSubtitleLabel.text = "Currently playing"
            self?.miniPlayerTrackLabel.text = soundscape.title
            print("🔄 UI updated - should show pause button now")
        }
        
        // Add time observer for continuous updates
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playbackTimeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateMiniPlayerFromObserver()
        }
        
        print("🎵 Player created and play() called")
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
    }
    
    private func playStory(for story: StoryItem) {
        print("🎬 Starting story playback for: \(story.title)")
        
        guard let audioURL = story.audioURL else {
            print("❌ No audio URL found for story: \(story.title)")
            return
        }
        
        print("🎬 Story URL: \(audioURL)")
        
        // Clean up previous player
        cleanupPlayer()
        
        // Create new player for story
        audioPlayer = AVPlayer(url: audioURL)
        currentSoundscape = SoundscapeItem(id: story.id, title: story.title, duration: story.duration, imageName: story.imageName, isFeatured: false, audioURL: story.audioURL, isFavorite: story.isFavorite, category: "Stories")
        
        // Set volume to ensure audio is audible
        audioPlayer?.volume = 1.0
        
        // Start playback
        audioPlayer?.play()
        
        // Force UI to show pause button immediately
        miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        miniPlayerSubtitleLabel.text = "Currently playing"
        miniPlayerTrackLabel.text = story.title
        
        // Add time observer for continuous updates
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playbackTimeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateMiniPlayerFromObserver()
        }
        
        print("🎬 Story player created and play() called")
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
    }
    
    private func cleanupPlayer() {
        if let observer = playbackTimeObserver {
            audioPlayer?.removeTimeObserver(observer)
            playbackTimeObserver = nil
        }
        audioPlayer?.pause()
    }
    
    private func updateMiniPlayerFromObserver() {
        guard let player = audioPlayer, let soundscape = currentSoundscape else { return }
        
        let rate = player.rate
        let status = player.timeControlStatus
        
        // Use rate as primary indicator - rate > 0 means playing
        if rate > 0 {
            miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniPlayerSubtitleLabel.text = "Currently playing"
        } else {
            miniPlayerPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal) 
            miniPlayerSubtitleLabel.text = "Paused"
        }
        
        miniPlayerTrackLabel.text = soundscape.title
    }
    
    private func pauseAudio() {
        audioPlayer?.pause()
        miniPlayerPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        miniPlayerSubtitleLabel.text = "Paused"
    }
    
    private func resumeAudio() {
        audioPlayer?.play()
        miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        miniPlayerSubtitleLabel.text = "Currently playing"
    }
    
    private func updateMiniPlayer() {
        guard let soundscape = currentSoundscape else { 
            print("No current soundscape")
            return 
        }
        
        miniPlayerTrackLabel.text = soundscape.title
        
        if let player = audioPlayer {
            let status = player.timeControlStatus
            let isPlaying = status == .playing
            let isPaused = status == .paused
            let isWaiting = status == .waitingToPlayAtSpecifiedRate
            
            print("🎵 Player status update: \(status.rawValue) | Playing: \(isPlaying) | Paused: \(isPaused) | Waiting: \(isWaiting)")
            
            // Update button based on actual state
            if isPlaying {
                print("✅ Setting pause button")
                miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                miniPlayerSubtitleLabel.text = "Currently playing"
            } else if isPaused {
                print("⏸️ Setting play button (paused)")
                miniPlayerPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                miniPlayerSubtitleLabel.text = "Paused"
            } else if isWaiting {
                print("⏳ Setting pause button (waiting to play)")
                miniPlayerPlayButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                miniPlayerSubtitleLabel.text = "Loading..."
            } else {
                print("❓ Unknown state, setting play button")
                miniPlayerPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                miniPlayerSubtitleLabel.text = "Ready"
            }
        } else {
            print("❌ No audio player available")
        }
    }
    
    // MARK: - Category Filtering
    private func filterSoundscapesByCategory() {
        let selectedCategory = categories[selectedCategoryIndex].title
        filteredSoundscapes = moreSoundscapes.filter { $0.category == selectedCategory }
    }
    
    // MARK: - Favorites Management
    private func toggleFavorite(for soundscape: SoundscapeItem) {
        print("🔄 Toggling favorite for: \(soundscape.title) (currently: \(soundscape.isFavorite))")
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
        hapticFeedback.impactOccurred()
        
        var wasToggled = false
        
        // Toggle in featured soundscapes
        if let index = featuredSoundscapes.firstIndex(where: { $0.id == soundscape.id }) {
            featuredSoundscapes[index].isFavorite.toggle()
            print("✅ Toggled in featured: \(featuredSoundscapes[index].title) -> \(featuredSoundscapes[index].isFavorite)")
            wasToggled = true
        }
        
        // Toggle in more soundscapes
        if let index = moreSoundscapes.firstIndex(where: { $0.id == soundscape.id }) {
            moreSoundscapes[index].isFavorite.toggle()
            print("✅ Toggled in more sounds: \(moreSoundscapes[index].title) -> \(moreSoundscapes[index].isFavorite)")
            wasToggled = true
        }
        
        // Save only once after all toggles
        if wasToggled {
            saveFavoritesToUserDefaults()
            filterSoundscapesByCategory()
            
            featuredCollectionView.reloadData()
            moreSoundsCollectionView.reloadData()
        }
    }
    
    private func loadFavoritesFromUserDefaults() {
        let favorites = UserDefaults.standard.array(forKey: "FavoriteSoundscapes") as? [String] ?? []
        print("💾 Loading favorites from UserDefaults: \(favorites)")
        
        for i in 0..<featuredSoundscapes.count {
            featuredSoundscapes[i].isFavorite = favorites.contains(featuredSoundscapes[i].id)
            if featuredSoundscapes[i].isFavorite {
                print("✅ Loaded favorite: \(featuredSoundscapes[i].title)")
            }
        }
        
        for i in 0..<moreSoundscapes.count {
            moreSoundscapes[i].isFavorite = favorites.contains(moreSoundscapes[i].id)
            if moreSoundscapes[i].isFavorite {
                print("✅ Loaded favorite: \(moreSoundscapes[i].title)")
            }
        }
    }
    
    private func saveFavoritesToUserDefaults() {
        let allSoundscapes = featuredSoundscapes + moreSoundscapes
        let favorites = allSoundscapes.filter { $0.isFavorite }.map { $0.id }
        print("💾 Saving favorites to UserDefaults: \(favorites)")
        UserDefaults.standard.set(favorites, forKey: "FavoriteSoundscapes")
        UserDefaults.standard.synchronize() // Force immediate save
    }
    
    private func loadStoryFavoritesFromUserDefaults() {
        let storyFavorites = UserDefaults.standard.array(forKey: "FavoriteStories") as? [String] ?? []
        print("💾 Loading story favorites from UserDefaults: \(storyFavorites)")
        
        for i in 0..<stories.count {
            stories[i].isFavorite = storyFavorites.contains(stories[i].id)
            if stories[i].isFavorite {
                print("✅ Loaded favorite story: \(stories[i].title)")
            }
        }
    }
    
    func updateFavoriteStatus(for soundscape: SoundscapeItem) {
        if let index = featuredSoundscapes.firstIndex(where: { $0.id == soundscape.id }) {
            featuredSoundscapes[index].isFavorite = soundscape.isFavorite
        }
        
        if let index = moreSoundscapes.firstIndex(where: { $0.id == soundscape.id }) {
            moreSoundscapes[index].isFavorite = soundscape.isFavorite
        }
        
        filterSoundscapesByCategory()
        saveFavoritesToUserDefaults()
        
        featuredCollectionView.reloadData()
        moreSoundsCollectionView.reloadData()
    }
    
    private func toggleStoryFavorite(for story: StoryItem) {
        print("🔄 Toggling story favorite for: \(story.title) (currently: \(story.isFavorite))")
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
        hapticFeedback.impactOccurred()
        
        if let index = stories.firstIndex(where: { $0.id == story.id }) {
            stories[index].isFavorite.toggle()
            print("✅ Toggled story: \(stories[index].title) -> \(stories[index].isFavorite)")
            
            // Save story favorites to UserDefaults
            let storyFavorites = stories.filter { $0.isFavorite }.map { $0.id }
            UserDefaults.standard.set(storyFavorites, forKey: "FavoriteStories")
            UserDefaults.standard.synchronize()
            
            storiesTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        setupHeader()
        setupSegmentedControl()
        setupSoundscapesTab()
        setupSleepStoriesTab()
        setupMiniPlayer()
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        contentView.addSubview(headerView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Relax"
        titleLabel.font = UIFont(name: "Georgia", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Soundscapes", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Sleep Stories", at: 1, animated: false)
        segmentedControl.selectedSegmentIndex = 0
        
        // Style the segmented control
        segmentedControl.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        segmentedControl.selectedSegmentTintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ], for: .selected)
        
        segmentedControl.layer.cornerRadius = 18
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        contentView.addSubview(segmentedControl)
    }
    
    private func setupSoundscapesTab() {
        soundscapesView.translatesAutoresizingMaskIntoConstraints = false
        soundscapesView.alpha = 1.0
        contentView.addSubview(soundscapesView)
        
        // Featured Label
        featuredLabel.translatesAutoresizingMaskIntoConstraints = false
        featuredLabel.text = "Featured"
        featuredLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        featuredLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        soundscapesView.addSubview(featuredLabel)
        
        // Featured Collection View
        featuredCollectionView.translatesAutoresizingMaskIntoConstraints = false
        featuredCollectionView.backgroundColor = .clear
        featuredCollectionView.showsHorizontalScrollIndicator = false
        featuredCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        soundscapesView.addSubview(featuredCollectionView)
        
        // Categories
        setupCategoriesView()
        
        // More Sounds Label
        moreSoundsLabel.translatesAutoresizingMaskIntoConstraints = false
        moreSoundsLabel.text = "More Sounds"
        moreSoundsLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        moreSoundsLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        soundscapesView.addSubview(moreSoundsLabel)
        
        // More Sounds Collection View
        moreSoundsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        moreSoundsCollectionView.backgroundColor = .clear
        moreSoundsCollectionView.showsVerticalScrollIndicator = false
        soundscapesView.addSubview(moreSoundsCollectionView)
    }
    
    private func setupCategoriesView() {
        categoriesScrollView.translatesAutoresizingMaskIntoConstraints = false
        categoriesScrollView.showsHorizontalScrollIndicator = false
        categoriesScrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        soundscapesView.addSubview(categoriesScrollView)
        
        categoriesStackView.translatesAutoresizingMaskIntoConstraints = false
        categoriesStackView.axis = .horizontal
        categoriesStackView.spacing = 12
        categoriesStackView.distribution = .fill
        categoriesScrollView.addSubview(categoriesStackView)
        
        // Add category buttons
        for category in categories {
            let button = createCategoryButton(title: category.title, isSelected: category.isSelected)
            categoriesStackView.addArrangedSubview(button)
        }
    }
    
    private func createCategoryButton(title: String, isSelected: Bool) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 18
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        if isSelected {
            button.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
            button.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
        }
        
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return button
    }
    
    private func setupSleepStoriesTab() {
        sleepStoriesView.translatesAutoresizingMaskIntoConstraints = false
        sleepStoriesView.alpha = 0.0
        contentView.addSubview(sleepStoriesView)
        
        // Search Container
        let searchContainer = UIView()
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        sleepStoriesView.addSubview(searchContainer)
        
        // Search TextField
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "🔍 Find a story..."
        searchTextField.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        searchTextField.layer.cornerRadius = 20
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        searchTextField.leftViewMode = .always
        searchTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        searchTextField.rightViewMode = .always
        searchContainer.addSubview(searchTextField)
        
        // Filter Button
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        filterButton.layer.cornerRadius = 20
        filterButton.setImage(UIImage(systemName: "line.3.horizontal.decrease"), for: .normal)
        filterButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        searchContainer.addSubview(filterButton)
        
        // Stories Table View
        storiesTableView.translatesAutoresizingMaskIntoConstraints = false
        storiesTableView.backgroundColor = .clear
        storiesTableView.separatorStyle = .none
        storiesTableView.showsVerticalScrollIndicator = false
        sleepStoriesView.addSubview(storiesTableView)
        
        // Search container constraints
        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: sleepStoriesView.topAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: sleepStoriesView.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: sleepStoriesView.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 40),
            
            searchTextField.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12),
            
            filterButton.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            filterButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor),
            filterButton.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupMiniPlayer() {
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        miniPlayerView.layer.cornerRadius = 16
        miniPlayerView.layer.shadowColor = UIColor.black.cgColor
        miniPlayerView.layer.shadowOpacity = 0.1
        miniPlayerView.layer.shadowRadius = 8
        miniPlayerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.addSubview(miniPlayerView)
        
        // Track Label
        miniPlayerTrackLabel.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerTrackLabel.text = "Ocean Waves"
        miniPlayerTrackLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        miniPlayerTrackLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        miniPlayerView.addSubview(miniPlayerTrackLabel)
        
        // Subtitle Label
        miniPlayerSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerSubtitleLabel.text = "Currently playing"
        miniPlayerSubtitleLabel.font = UIFont.systemFont(ofSize: 14)
        miniPlayerSubtitleLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        miniPlayerView.addSubview(miniPlayerSubtitleLabel)
        
        // Play Button
        miniPlayerPlayButton.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerPlayButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        miniPlayerPlayButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        miniPlayerPlayButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        miniPlayerView.addSubview(miniPlayerPlayButton)
        
        // Next Button
        miniPlayerNextButton.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerNextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        miniPlayerNextButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        miniPlayerNextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        miniPlayerView.addSubview(miniPlayerNextButton)
        
        let miniPlayerTapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerTapped))
        miniPlayerView.addGestureRecognizer(miniPlayerTapGesture)
    }
    
    // MARK: - Collection Views Setup
    private func setupCollectionViews() {
        // Featured Collection View
        featuredCollectionView.delegate = self
        featuredCollectionView.dataSource = self
        featuredCollectionView.register(FeaturedSoundscapeCell.self, forCellWithReuseIdentifier: "FeaturedCell")
        
        // More Sounds Collection View
        moreSoundsCollectionView.delegate = self
        moreSoundsCollectionView.dataSource = self
        moreSoundsCollectionView.register(MoreSoundsCell.self, forCellWithReuseIdentifier: "MoreSoundsCell")
    }
    
    // MARK: - Table View Setup
    private func setupTableView() {
        storiesTableView.delegate = self
        storiesTableView.dataSource = self
        storiesTableView.register(StoryCell.self, forCellReuseIdentifier: "StoryCell")
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: miniPlayerView.topAnchor, constant: -12),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),
            
            // Soundscapes View
            soundscapesView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            soundscapesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            soundscapesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            soundscapesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            featuredLabel.topAnchor.constraint(equalTo: soundscapesView.topAnchor),
            featuredLabel.leadingAnchor.constraint(equalTo: soundscapesView.leadingAnchor, constant: 16),
            
            featuredCollectionView.topAnchor.constraint(equalTo: featuredLabel.bottomAnchor, constant: 16),
            featuredCollectionView.leadingAnchor.constraint(equalTo: soundscapesView.leadingAnchor),
            featuredCollectionView.trailingAnchor.constraint(equalTo: soundscapesView.trailingAnchor),
            featuredCollectionView.heightAnchor.constraint(equalToConstant: 180),
            
            categoriesScrollView.topAnchor.constraint(equalTo: featuredCollectionView.bottomAnchor, constant: 24),
            categoriesScrollView.leadingAnchor.constraint(equalTo: soundscapesView.leadingAnchor),
            categoriesScrollView.trailingAnchor.constraint(equalTo: soundscapesView.trailingAnchor),
            categoriesScrollView.heightAnchor.constraint(equalToConstant: 36),
            
            categoriesStackView.topAnchor.constraint(equalTo: categoriesScrollView.topAnchor),
            categoriesStackView.leadingAnchor.constraint(equalTo: categoriesScrollView.leadingAnchor),
            categoriesStackView.trailingAnchor.constraint(equalTo: categoriesScrollView.trailingAnchor),
            categoriesStackView.bottomAnchor.constraint(equalTo: categoriesScrollView.bottomAnchor),
            categoriesStackView.heightAnchor.constraint(equalTo: categoriesScrollView.heightAnchor),
            
            moreSoundsLabel.topAnchor.constraint(equalTo: categoriesScrollView.bottomAnchor, constant: 32),
            moreSoundsLabel.leadingAnchor.constraint(equalTo: soundscapesView.leadingAnchor, constant: 16),
            
            moreSoundsCollectionView.topAnchor.constraint(equalTo: moreSoundsLabel.bottomAnchor, constant: 16),
            moreSoundsCollectionView.leadingAnchor.constraint(equalTo: soundscapesView.leadingAnchor, constant: 16),
            moreSoundsCollectionView.trailingAnchor.constraint(equalTo: soundscapesView.trailingAnchor, constant: -16),
            moreSoundsCollectionView.heightAnchor.constraint(equalToConstant: 200),
            moreSoundsCollectionView.bottomAnchor.constraint(lessThanOrEqualTo: soundscapesView.bottomAnchor, constant: -20),
            
            // Sleep Stories View
            sleepStoriesView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 24),
            sleepStoriesView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sleepStoriesView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sleepStoriesView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            storiesTableView.topAnchor.constraint(equalTo: sleepStoriesView.topAnchor, constant: 72),
            storiesTableView.leadingAnchor.constraint(equalTo: sleepStoriesView.leadingAnchor, constant: 16),
            storiesTableView.trailingAnchor.constraint(equalTo: sleepStoriesView.trailingAnchor, constant: -16),
            storiesTableView.bottomAnchor.constraint(equalTo: sleepStoriesView.bottomAnchor),
            
            // Mini Player
            miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            miniPlayerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            miniPlayerView.heightAnchor.constraint(equalToConstant: 64),
            
            miniPlayerTrackLabel.topAnchor.constraint(equalTo: miniPlayerView.topAnchor, constant: 8),
            miniPlayerTrackLabel.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor, constant: 16),
            miniPlayerTrackLabel.trailingAnchor.constraint(equalTo: miniPlayerPlayButton.leadingAnchor, constant: -16),
            
            miniPlayerSubtitleLabel.topAnchor.constraint(equalTo: miniPlayerTrackLabel.bottomAnchor, constant: 2),
            miniPlayerSubtitleLabel.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor, constant: 16),
            miniPlayerSubtitleLabel.trailingAnchor.constraint(equalTo: miniPlayerPlayButton.leadingAnchor, constant: -16),
            miniPlayerSubtitleLabel.bottomAnchor.constraint(equalTo: miniPlayerView.bottomAnchor, constant: -8),
            
            miniPlayerNextButton.trailingAnchor.constraint(equalTo: miniPlayerView.trailingAnchor, constant: -16),
            miniPlayerNextButton.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            miniPlayerNextButton.widthAnchor.constraint(equalToConstant: 24),
            miniPlayerNextButton.heightAnchor.constraint(equalToConstant: 24),
            
            miniPlayerPlayButton.trailingAnchor.constraint(equalTo: miniPlayerNextButton.leadingAnchor, constant: -16),
            miniPlayerPlayButton.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor),
            miniPlayerPlayButton.widthAnchor.constraint(equalToConstant: 24),
            miniPlayerPlayButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            if self.selectedSegmentIndex == 0 {
                self.showSoundscapesTab()
            } else {
                self.showSleepStoriesTab()
            }
        }
    }
    
    private func showSoundscapesTab() {
        soundscapesView.alpha = 1.0
        sleepStoriesView.alpha = 0.0
    }
    
    private func showSleepStoriesTab() {
        soundscapesView.alpha = 0.0
        sleepStoriesView.alpha = 1.0
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let tappedTitle = sender.titleLabel?.text,
              let newIndex = categories.firstIndex(where: { $0.title == tappedTitle }) else { return }
        
        selectedCategoryIndex = newIndex
        
        for (index, _) in categories.enumerated() {
            categories[index] = CategoryItem(title: categories[index].title, isSelected: index == selectedCategoryIndex)
        }
        
        updateCategoryButtons()
        filterSoundscapesByCategory()
        moreSoundsCollectionView.reloadData()
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
        hapticFeedback.impactOccurred()
    }
    
    private func updateCategoryButtons() {
        for (index, button) in categoriesStackView.arrangedSubviews.enumerated() {
            guard let categoryButton = button as? UIButton, index < categories.count else { continue }
            
            let category = categories[index]
            if category.isSelected {
                categoryButton.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
                categoryButton.setTitleColor(.white, for: .normal)
            } else {
                categoryButton.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
                categoryButton.setTitleColor(UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), for: .normal)
            }
        }
    }
    
    @objc private func filterButtonTapped() {
        print("Filter button tapped")
    }
    
    @objc private func playButtonTapped() {
        guard let player = audioPlayer else { return }
        
        if player.timeControlStatus == .playing {
            pauseAudio()
        } else {
            resumeAudio()
        }
    }
    
    @objc private func nextButtonTapped() {
        let allSoundscapes = featuredSoundscapes + moreSoundscapes
        guard let currentId = currentSoundscape?.id,
              let currentIndex = allSoundscapes.firstIndex(where: { $0.id == currentId }) else { return }
        
        let nextIndex = (currentIndex + 1) % allSoundscapes.count
        let nextSoundscape = allSoundscapes[nextIndex]
        playAudio(for: nextSoundscape)
    }
    
    @objc private func miniPlayerTapped() {
        guard currentSoundscape != nil else { return }
        presentNowPlayingSheet()
    }
    
    private func presentNowPlayingSheet() {
        guard let soundscape = currentSoundscape else { return }
        
        let nowPlaying = NowPlayingViewController()
        
        // Check if this is a story (from Sleep Stories) or a soundscape
        if let story = stories.first(where: { $0.title == soundscape.title }) {
            nowPlaying.configure(with: story, player: audioPlayer)
        } else {
            nowPlaying.configure(with: soundscape, player: audioPlayer)
        }
        
        nowPlaying.delegate = self
        
        // Present as full screen modal
        nowPlaying.modalPresentationStyle = .fullScreen
        nowPlaying.modalTransitionStyle = .coverVertical
        
        nowPlayingSheet = nowPlaying
        present(nowPlaying, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension RelaxViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == featuredCollectionView {
            return featuredSoundscapes.count
        } else {
            return filteredSoundscapes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == featuredCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturedCell", for: indexPath) as! FeaturedSoundscapeCell
            let soundscape = featuredSoundscapes[indexPath.item]
            cell.configure(with: soundscape)
            cell.onPlay = { [weak self] in
                self?.playAudio(for: soundscape)
            }
            cell.onFavorite = { [weak self] in
                self?.toggleFavorite(for: soundscape)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreSoundsCell", for: indexPath) as! MoreSoundsCell
            let soundscape = filteredSoundscapes[indexPath.item]
            cell.configure(with: soundscape)
            cell.onPlay = { [weak self] in
                self?.playAudio(for: soundscape)
            }
            cell.onFavorite = { [weak self] in
                self?.toggleFavorite(for: soundscape)
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RelaxViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == featuredCollectionView {
            return CGSize(width: 140, height: 180)
        } else {
            // Full width for more sounds to show complete titles
            let width = collectionView.bounds.width
            return CGSize(width: width, height: 56)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == featuredCollectionView ? 16 : 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == featuredCollectionView ? 0 : 8
    }
}

// MARK: - UITableViewDataSource
extension RelaxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell", for: indexPath) as! StoryCell
        let story = stories[indexPath.row]
        cell.configure(with: story)
        cell.onFavorite = { [weak self] in
            self?.toggleStoryFavorite(for: story)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RelaxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let story = stories[indexPath.row]
        playStory(for: story)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downloadAction = UIContextualAction(style: .normal, title: "Download") { _, _, completion in
            print("Download story: \(self.stories[indexPath.row].title)")
            completion(true)
        }
        downloadAction.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { _, _, completion in
            print("Share story: \(self.stories[indexPath.row].title)")
            completion(true)
        }
        shareAction.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [shareAction, downloadAction])
    }
}

// MARK: - Custom Cells

// Featured Soundscape Cell
class FeaturedSoundscapeCell: UICollectionViewCell {
    private let imageLabel = UILabel()
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let playIcon = UIImageView()
    private let favoriteButton = UIButton()
    
    var onPlay: (() -> Void)?
    var onFavorite: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 0.8, green: 0.77, blue: 0.74, alpha: 1.0).cgColor
        
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.font = UIFont.systemFont(ofSize: 60)
        imageLabel.textAlignment = .center
        contentView.addSubview(imageLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        durationLabel.textAlignment = .center
        contentView.addSubview(durationLabel)
        
        playIcon.translatesAutoresizingMaskIntoConstraints = false
        playIcon.image = UIImage(systemName: "play.fill")
        playIcon.tintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        playIcon.isUserInteractionEnabled = false
        contentView.addSubview(playIcon)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: imageLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            durationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32),
            
            playIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            playIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            playIcon.widthAnchor.constraint(equalToConstant: 20),
            playIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with item: SoundscapeItem) {
        imageLabel.text = item.imageName
        titleLabel.text = item.title
        durationLabel.text = item.duration
        
        let heartImage = item.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = item.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    @objc private func cellTapped() {
        onPlay?()
    }
    
    @objc private func favoriteButtonTapped() {
        onFavorite?()
    }
}

// More Sounds Cell
class MoreSoundsCell: UICollectionViewCell {
    private let iconView = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let durationLabel = UILabel()
    private let favoriteButton = UIButton()
    
    var onPlay: (() -> Void)?
    var onFavorite: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        contentView.layer.cornerRadius = 12
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        iconView.layer.cornerRadius = 20
        contentView.addSubview(iconView)
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        iconView.addSubview(iconLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.numberOfLines = 1
        contentView.addSubview(titleLabel)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        durationLabel.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        durationLabel.layer.cornerRadius = 8
        durationLabel.textAlignment = .center
        durationLabel.layer.masksToBounds = true
        contentView.addSubview(durationLabel)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            iconLabel.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: durationLabel.leadingAnchor, constant: -8),
            
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            
            durationLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            durationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            durationLabel.widthAnchor.constraint(equalToConstant: 40),
            durationLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Set content priorities to ensure title label gets space
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        durationLabel.setContentHuggingPriority(.required, for: .horizontal)
        durationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configure(with item: SoundscapeItem) {
        iconLabel.text = item.imageName
        titleLabel.text = item.title
        durationLabel.text = item.duration
        
        let heartImage = item.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = item.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    @objc private func cellTapped() {
        onPlay?()
    }
    
    @objc private func favoriteButtonTapped() {
        onFavorite?()
    }
}

// Story Cell
class StoryCell: UITableViewCell {
    private let artworkView = UIView()
    private let artworkLabel = UILabel()
    private let titleLabel = UILabel()
    private let tagLabel = UILabel()
    private let durationLabel = UILabel()
    private let favoriteButton = UIButton()
    
    var onFavorite: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        cardView.layer.cornerRadius = 16
        contentView.addSubview(cardView)
        
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        artworkView.layer.cornerRadius = 28
        cardView.addSubview(artworkView)
        
        artworkLabel.translatesAutoresizingMaskIntoConstraints = false
        artworkLabel.font = UIFont.systemFont(ofSize: 32)
        artworkLabel.textAlignment = .center
        artworkView.addSubview(artworkLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        cardView.addSubview(titleLabel)
        
        let detailsStackView = UIStackView()
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.axis = .horizontal
        detailsStackView.spacing = 8
        detailsStackView.alignment = .center
        cardView.addSubview(detailsStackView)
        
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        tagLabel.textColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        tagLabel.backgroundColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 0.2)
        tagLabel.layer.cornerRadius = 10
        tagLabel.textAlignment = .center
        tagLabel.layer.masksToBounds = true
        detailsStackView.addArrangedSubview(tagLabel)
        
        let clockIcon = UIImageView()
        clockIcon.image = UIImage(systemName: "clock")
        clockIcon.tintColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.addArrangedSubview(clockIcon)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        detailsStackView.addArrangedSubview(durationLabel)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        cardView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            artworkView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            artworkView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            artworkView.widthAnchor.constraint(equalToConstant: 56),
            artworkView.heightAnchor.constraint(equalToConstant: 56),
            
            artworkLabel.centerXAnchor.constraint(equalTo: artworkView.centerXAnchor),
            artworkLabel.centerYAnchor.constraint(equalTo: artworkView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: artworkView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -16),
            
            detailsStackView.leadingAnchor.constraint(equalTo: artworkView.trailingAnchor, constant: 16),
            detailsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            detailsStackView.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -16),
            
            tagLabel.heightAnchor.constraint(equalToConstant: 20),
            tagLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            clockIcon.widthAnchor.constraint(equalToConstant: 16),
            clockIcon.heightAnchor.constraint(equalToConstant: 16),
            
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 32),
            favoriteButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Add padding to tag label
        tagLabel.setContentHuggingPriority(.required, for: .horizontal)
        tagLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func configure(with story: StoryItem) {
        artworkLabel.text = story.imageName
        titleLabel.text = story.title
        tagLabel.text = "  \(story.tag)  "
        durationLabel.text = story.duration
        
        let heartImage = story.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = story.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
    }
    
    @objc private func favoriteButtonTapped() {
        onFavorite?()
    }
}

// MARK: - NowPlaying Sheet
protocol NowPlayingDelegate: AnyObject {
    func nowPlayingDidRequestPlay()
    func nowPlayingDidRequestPause()
    func nowPlayingDidRequestNext()
    func nowPlayingDidSeek(to time: TimeInterval)
}

class NowPlayingViewController: UIViewController {
    weak var delegate: NowPlayingDelegate?
    
    private var currentSoundscape: SoundscapeItem?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var playerLayer: AVPlayerLayer?
    
    // UI Components
    private let videoContainerView = UIView()
    private let artworkView = UIView()
    private let artworkLabel = UILabel()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let timeSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    private let playButton = UIButton()
    private let nextButton = UIButton()
    private let favoriteButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTimeObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    func configure(with soundscape: SoundscapeItem, player: AVPlayer?) {
        currentSoundscape = soundscape
        self.player = player
        
        // Setup video layer if this is a video file
        if let audioURL = soundscape.audioURL,
           audioURL.pathExtension.lowercased() == "mp4" {
            setupVideoLayer()
        }
        
        updateUI()
    }
    
    func configure(with story: StoryItem, player: AVPlayer?) {
        self.player = player
        
        // Setup video layer for MP4 story
        setupVideoLayer()
        
        // Update UI for story
        artworkLabel.text = story.imageName
        titleLabel.text = story.title
        categoryLabel.text = story.tag
        
        let heartImage = story.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = story.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        updatePlayButton()
        updateTimeDisplay()
    }
    
    private func setupVideoLayer() {
        guard let player = player else { return }
        
        // Remove existing layer if any
        playerLayer?.removeFromSuperlayer()
        
        // Create new player layer
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspectFill
        
        // Add to video container
        videoContainerView.layer.addSublayer(layer)
        self.playerLayer = layer
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update player layer frame
        playerLayer?.frame = videoContainerView.bounds
        updateUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1.0)
        
        // Down arrow button instead of Done button
        let downArrowButton = UIButton()
        downArrowButton.translatesAutoresizingMaskIntoConstraints = false
        downArrowButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        downArrowButton.tintColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        downArrowButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        view.addSubview(downArrowButton)
        
        NSLayoutConstraint.activate([
            downArrowButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            downArrowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            downArrowButton.widthAnchor.constraint(equalToConstant: 44),
            downArrowButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Video Container (for MP4 files)
        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        videoContainerView.backgroundColor = UIColor.black
        videoContainerView.layer.cornerRadius = 32
        videoContainerView.clipsToBounds = true
        view.addSubview(videoContainerView)
        
        // Artwork (for audio files)
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.backgroundColor = UIColor(red: 0.88, green: 0.85, blue: 0.82, alpha: 1.0)
        artworkView.layer.cornerRadius = 32
        view.addSubview(artworkView)
        
        artworkLabel.translatesAutoresizingMaskIntoConstraints = false
        artworkLabel.font = UIFont.systemFont(ofSize: 80)
        artworkLabel.textAlignment = .center
        artworkView.addSubview(artworkLabel)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Category
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        categoryLabel.textAlignment = .center
        view.addSubview(categoryLabel)
        
        // Time Slider
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.minimumValue = 0
        timeSlider.tintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        timeSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        view.addSubview(timeSlider)
        
        // Time Labels
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.font = UIFont.systemFont(ofSize: 14)
        currentTimeLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        currentTimeLabel.text = "0:00"
        view.addSubview(currentTimeLabel)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        durationLabel.text = "0:00"
        view.addSubview(durationLabel)
        
        // Controls
        let controlsContainer = UIView()
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlsContainer)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        controlsContainer.addSubview(favoriteButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        controlsContainer.addSubview(playButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        nextButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        controlsContainer.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            controlsContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlsContainer.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 60),
            controlsContainer.heightAnchor.constraint(equalToConstant: 100),
            controlsContainer.widthAnchor.constraint(equalToConstant: 320),
            
            favoriteButton.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 80),
            favoriteButton.heightAnchor.constraint(equalToConstant: 80),
            
            playButton.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 100),
            playButton.heightAnchor.constraint(equalToConstant: 100),
            
            nextButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor),
            nextButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 80),
            nextButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Video Container
            videoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            videoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoContainerView.widthAnchor.constraint(equalToConstant: 200),
            videoContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // Artwork View (same position as video container)
            artworkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            artworkView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            artworkView.widthAnchor.constraint(equalToConstant: 200),
            artworkView.heightAnchor.constraint(equalToConstant: 200),
            
            artworkLabel.centerXAnchor.constraint(equalTo: artworkView.centerXAnchor),
            artworkLabel.centerYAnchor.constraint(equalTo: artworkView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: artworkView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            timeSlider.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 40),
            timeSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            timeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            currentTimeLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 8),
            currentTimeLabel.leadingAnchor.constraint(equalTo: timeSlider.leadingAnchor),
            
            durationLabel.topAnchor.constraint(equalTo: timeSlider.bottomAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: timeSlider.trailingAnchor)
        ])
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateTimeDisplay()
        }
    }
    
    private func updateUI() {
        guard let soundscape = currentSoundscape else { return }
        
        // Show/hide appropriate view based on file type
        let isVideo = soundscape.audioURL?.pathExtension.lowercased() == "mp4"
        videoContainerView.isHidden = !isVideo
        artworkView.isHidden = isVideo
        
        if !isVideo {
            artworkLabel.text = soundscape.imageName
        }
        
        titleLabel.text = soundscape.title
        categoryLabel.text = soundscape.category
        
        let heartImage = soundscape.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = soundscape.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        updatePlayButton()
        updateTimeDisplay()
    }
    
    private func updatePlayButton() {
        guard let player = player else { return }
        let isPlaying = player.timeControlStatus == .playing
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func updateTimeDisplay() {
        guard let player = player else { return }
        
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
        
        if !currentTime.isNaN && currentTime.isFinite {
            currentTimeLabel.text = formatTime(currentTime)
            if !timeSlider.isTracking {
                timeSlider.value = Float(currentTime)
            }
        }
        
        if !duration.isNaN && duration.isFinite {
            durationLabel.text = formatTime(duration)
            timeSlider.maximumValue = Float(duration)
        }
        
        updatePlayButton()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @objc private func dismissSheet() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        dismiss(animated: true)
    }
    
    @objc private func playButtonTapped() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            delegate?.nowPlayingDidRequestPause()
        } else {
            delegate?.nowPlayingDidRequestPlay()
        }
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
    }
    
    @objc private func nextButtonTapped() {
        delegate?.nowPlayingDidRequestNext()
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedback.impactOccurred()
    }
    
    @objc private func favoriteButtonTapped() {
        guard var soundscape = currentSoundscape else { return }
        
        soundscape.isFavorite.toggle()
        currentSoundscape = soundscape
        
        // Update the UI
        let heartImage = soundscape.isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImage), for: .normal)
        favoriteButton.tintColor = soundscape.isFavorite ?
            UIColor(red: 0.85, green: 0.7, blue: 0.8, alpha: 1.0) :
            UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
        hapticFeedback.impactOccurred()
        
        // Notify parent controller to update the data
        if let navController = presentingViewController as? UINavigationController,
           let relaxVC = navController.viewControllers.first as? RelaxViewController {
            relaxVC.updateFavoriteStatus(for: soundscape)
        } else if let relaxVC = presentingViewController as? RelaxViewController {
            relaxVC.updateFavoriteStatus(for: soundscape)
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let seekTime = TimeInterval(sender.value)
        delegate?.nowPlayingDidSeek(to: seekTime)
    }
}

// MARK: - NowPlaying Delegate
extension RelaxViewController: NowPlayingDelegate {
    func nowPlayingDidRequestPlay() {
        resumeAudio()
    }
    
    func nowPlayingDidRequestPause() {
        pauseAudio()
    }
    
    func nowPlayingDidRequestNext() {
        nextButtonTapped()
    }
    
    func nowPlayingDidSeek(to time: TimeInterval) {
        let seekTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        audioPlayer?.seek(to: seekTime)
    }
}
