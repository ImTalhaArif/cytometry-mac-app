import RealmSwift

class HistogramViewModel: ObservableObject {
    private var realm = try! Realm()

    func fetchHistogramData(forPatientID patientID: String) -> [Double] {
        let experiments = realm.objects(Experiment.self)
            .filter("patientID == %@", patientID)
        // Process data into histogram format
        return experiments.map { $0.someNumericValue }
    }
}
