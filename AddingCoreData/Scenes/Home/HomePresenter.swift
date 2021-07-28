protocol HomePresenterContract {
    func didLoadView()
    func didTapSaveMovie(named: String)
    func didTapUpdateMoviesList()
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
