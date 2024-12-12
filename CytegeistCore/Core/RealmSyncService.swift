import RealmSwift

class RealmSyncService {
    func configureSync() {
        let app = App(id: "your-realm-app-id")
        app.login(credentials: .anonymous) { result in
            switch result {
            case .success(let user):
                let configuration = user.configuration(partitionValue: "partitionKey")
                let realm = try! Realm(configuration: configuration)
                // Realm sync enabled
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}
