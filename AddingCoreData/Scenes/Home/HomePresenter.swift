protocol HomePresenterContract {
    func didLoadView()
    func didTapSaveMovie(named: String)
    func didTapUpdateMoviesList()
    func didTapDeleteMovie(model: HomeMovieCellModel)
    func didEnteredNewMovieName(_ newName: String, model: HomeMovieCellModel)
}

final class HomePresenter {
    private let view: HomeViewContract
    private let storageProvider: StorageProviderContract
    
    private var movies: [Movie] = []
    
    // MARK: - Initializer
    init(view: HomeViewContract,
         storageProvider: StorageProviderContract) {
        self.view = view
        self.storageProvider = storageProvider
    }
}

// MARK: - HomePresenterContract
extension HomePresenter: HomePresenterContract {
    func didLoadView() {
        updateMoviesList()
    }
    
    func didTapSaveMovie(named: String) {
        storageProvider.saveMovie(named: named)
    }
    
    func didTapUpdateMoviesList() {
        updateMoviesList()
    }
    
    func didTapDeleteMovie(model: HomeMovieCellModel) {
        guard let movie = movies.first(where: { $0.name == model.movieName }) else {
            return
        }
        do {
            try storageProvider.deleteMovie(movie)
            
            if let index = movies.firstIndex(of: movie) {
                movies.remove(at: index)
                makeMovieCellModels()
            }
            
        } catch {
            print("Could not delete movie with error: \(error)")
        }
    }
    
    func didEnteredNewMovieName(_ newName: String, model: HomeMovieCellModel) {
        guard let movie = movies.first(where: { $0.name == model.movieName }) else {
            return
        }
        movie.name = newName
        storageProvider.updateMovies()
    }
}

private extension HomePresenter {
    private func updateMoviesList() {
        movies = storageProvider.getAllMovies()
        makeMovieCellModels()
    }
    
    private func makeMovieCellModels() {
        let models = movies.map { HomeMovieCellModel(movieName: $0.name ?? "") }
        view.renderMovies(models)
    }
}
