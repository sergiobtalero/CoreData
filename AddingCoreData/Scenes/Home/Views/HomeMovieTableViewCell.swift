import SnapKit
import UIKit

struct HomeMovieCellModel: CellModel {    
    let movieName: String
    
    func getCell(forTableView tableView: UITableView,
                 indexPath: IndexPath) -> HomeMovieTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMovieTableViewCell",
                                                       for: indexPath) as? HomeMovieTableViewCell else {
            fatalError("Could not load cell")
        }
        cell.configure(with: self)
        return cell
    }
}

class HomeMovieTableViewCell: UITableViewCell {
    private var movieNameLabel: UILabel!
    
    // MARK: - Initializer    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    func configure(with model: HomeMovieCellModel) {
        movieNameLabel.text = model.movieName
    }
}

private extension HomeMovieTableViewCell {
    private func setupUI() {
        setupLabel()
    }
    
    private func setupLabel() {
        movieNameLabel = UILabel()
        addSubview(movieNameLabel)
        
        movieNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
    }
}
