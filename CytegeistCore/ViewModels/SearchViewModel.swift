import RealmSwift

class SearchViewModel: ObservableObject {
    private var realm = try! Realm()
    @Published var results: [Experiment] = []

    func search(byParameter parameter: String) {
        let objects = realm.objects(Experiment.self)
            .filter("ANY parameterList == %@", parameter)
        results = Array(objects)
    }
}
