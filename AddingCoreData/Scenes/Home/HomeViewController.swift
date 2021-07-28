import SnapKit
import UIKit

protocol HomeViewContract {
    func renderMovies(_ movies: [HomeMovieCellModel])
}

class HomeViewController: UIViewController {
    private var tableView: UITableView!
    private var textField: UITextField!
    private var button: UIButton!
    
    private var presenter: HomePresenterContract!
    
    private var cellModels: [HomeMovieCellModel] = []
    
    // MARK: - Initializers
    init(storageProvider: StorageProviderContract) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = HomePresenter(view: self,
                                  storageProvider: storageProvider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Movies"
        
        setupUI()
        presenter.didLoadView()
    }
}

// MARK: - Action Methods
extension HomeViewController {
    @objc private func didTapAddMovie(_ sender: UIButton) {
        if let movieName = textField.text, !movieName.isEmpty {
            presenter.didTapSaveMovie(named: movieName)
            textField.text = ""
        }
        view.endEditing(true)
    }
    
    private func didTapUpdateAction(forModel model: HomeMovieCellModel) {
        let alertController = UIAlertController(title: "Update Movie", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "New movie name"
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned alertController, weak self] _ in
            guard let strongSelf = self else { return }
            if let newMovieName = alertController.textFields?.first?.text,
               !newMovieName.isEmpty {
                strongSelf.presenter.didEnteredNewMovieName(newMovieName, model: model)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - HomeViewContract
extension HomeViewController: HomeViewContract {
    func renderMovies(_ movies: [HomeMovieCellModel]) {
        cellModels = movies
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cellModels[indexPath.row]
        return model.getCell(forTableView: tableView, indexPath: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let strongSelf = self else {
                completion(true)
                return
            }
            
            strongSelf.presenter.didTapDeleteMovie(model: strongSelf.cellModels[indexPath.row])
            completion(true)
        }
        
        let updateAction = UIContextualAction(style: .normal, title: "Update") { [weak self] _, _, completion in
            guard let strongSelf = self else {
                completion(true)
                return
            }
            strongSelf.didTapUpdateAction(forModel: strongSelf.cellModels[indexPath.row])
            completion(true)
        }
        
        updateAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }
}

// MARK: - SetupUI
private extension HomeViewController {
    private func setupUI() {
        setupTextField()
        setupButton()
        setupTableView()
        
        view.backgroundColor = .white
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(HomeMovieTableViewCell.self,
                           forCellReuseIdentifier: "HomeMovieTableViewCell")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(10.0)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupTextField(){
        textField = UITextField()
        textField.placeholder = "Movie name"
        textField.borderStyle = .roundedRect
        
        view.addSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(10.0)
            make.leading.equalToSuperview().inset(10.0)
        }
    }
    
    private func setupButton() {
        button = UIButton()
        button.setTitle("Add movie", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self,
                         action: #selector(didTapAddMovie(_:)),
                         for: .touchUpInside)
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.top.bottom.equalTo(textField)
            make.leading.equalTo(textField.snp.trailing).offset(5.0)
            make.trailing.equalToSuperview().inset(10.0)
        }
    }
}

