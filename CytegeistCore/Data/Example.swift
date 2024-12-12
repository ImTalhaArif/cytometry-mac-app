import RealmSwift

class Experiment: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var name: String
    @Persisted var createdAt: Date = Date()
    @Persisted var parameterList: List<String>
    @Persisted var externalFileURL: String?
}
