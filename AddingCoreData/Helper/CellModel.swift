import UIKit

protocol CellModel {
    associatedtype Cell
    
    func getCell(forTableView tableView: UITableView, indexPath: IndexPath) -> Cell
}
