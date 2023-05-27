import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var items = [String]()
    var manufacturers = [String]()
    var favorites = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.items = UserDefaults.standard.stringArray(forKey: "items") ?? []
        self.manufacturers = UserDefaults.standard.stringArray(forKey: "manufacturers") ?? []
        self.favorites = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
        title = "Car Dealers"
        
        view.addSubview(table)
        table.dataSource = self
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd)),
            UIBarButtonItem(title: "Favorites", style: .plain, target: self, action: #selector(didTapFavorites))
        ]
        
        let manufacturerButton = UIButton(type: .system)
        manufacturerButton.setTitle("Manufacturer", for: .normal)
        manufacturerButton.addTarget(self, action: #selector(didTapManufacturer), for: .touchUpInside)
        view.addSubview(manufacturerButton)
        manufacturerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            manufacturerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            manufacturerButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
        
        let favoritesButton = UIButton(type: .system)
        favoritesButton.setTitle("Favorites", for: .normal)
        favoritesButton.addTarget(self, action: #selector(didTapFavorites), for: .touchUpInside)
        view.addSubview(favoritesButton)
        favoritesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoritesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            favoritesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "Add New Car", message: "Enter a Car name to Add to the List", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter a new Car name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    // Enter new car item
                    DispatchQueue.main.async {
                        var currentItems = UserDefaults.standard.stringArray(forKey: "items") ?? []
                        currentItems.append(text)
                        UserDefaults.standard.setValue(currentItems, forKey: "items")
                        self?.items.append(text)
                        self?.table.reloadData()
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapManufacturer() {
        let alert = UIAlertController(title: "Add Manufacturer", message: "Enter a manufacturer name to add to the list", preferredStyle: .alert)
        alert.addTextField { field in
            field.placeholder = "Enter a new manufacturer name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] _ in
            if let field = alert.textFields?.first {
                if let text = field.text, !text.isEmpty {
                    // Enter new manufacturer item
                    DispatchQueue.main.async {
                        var currentManufacturers = UserDefaults.standard.stringArray(forKey: "manufacturers") ?? []
                        currentManufacturers.append(text)
                        UserDefaults.standard.setValue(currentManufacturers, forKey: "manufacturers")
                        self?.manufacturers.append(text)
                        self?.table.reloadData()
                    }
                }
            }
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapFavorites() {
        let favoritesVC = FavoritesViewController(favorites: favorites)
        favoritesVC.delegate = self
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    // MARK: - Table View DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Heading for Car Dealers
        } else if section == 1 {
            return items.count
        } else if section == 2 {
            return manufacturers.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Car Dealers"
        } else if indexPath.section == 1 {
            let item = items[indexPath.row]
            cell.textLabel?.text = item
            if favorites.contains(item) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if indexPath.section == 2 {
            cell.textLabel?.text = manufacturers[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let item = items[indexPath.row]
            
            if favorites.contains(item) {
                favorites.removeAll { $0 == item }
            } else {
                favorites.append(item)
            }
            
            UserDefaults.standard.setValue(favorites, forKey: "favorites")
            tableView.reloadData()
        }
    }
}

extension ViewController: FavoritesViewControllerDelegate {
    func didUpdateFavorites(favorites: [String]) {
        self.favorites = favorites
        table.reloadData()
    }
}

protocol FavoritesViewControllerDelegate: AnyObject {
    func didUpdateFavorites(favorites: [String])
}

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FavoritesViewControllerDelegate?
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var favorites = [String]()
    
    init(favorites: [String]) {
        super.init(nibName: nil, bundle: nil)
        self.favorites = favorites
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
    }
    
    @objc private func didTapDone() {
        delegate?.didUpdateFavorites(favorites: favorites)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row]
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedFavorite = favorites[indexPath.row]
        let alert = UIAlertController(title: "Remove from Favorites", message: "Are you sure you want to remove \(selectedFavorite) from favorites?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            self?.favorites.remove(at: indexPath.row)
            tableView.reloadData()
        }))
        
        present(alert, animated: true)
    }
}
