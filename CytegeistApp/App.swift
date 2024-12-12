//
//  ExperimentStore.swift
//  filereader
//
//  Created by Adam Treister on 7/28/24.
// Modified version by: John Irving dated: 9/12/24
// The modifications here focus on the core priniciples of Realm.
//

import Foundation
import CytegeistLibrary
import CytegeistCore
import SwiftUI
import RealmSwift

@Observable
final class App {
    
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var experiments: [Experiment] = []
    var selectedExperiment: Experiment.ID?
    private var databaseFileUrl: URL? {
        Bundle.main.url(forResource: "database", withExtension: "json")
    }
    
    private var realm: Realm?
    
    init() {
        setupRealm()
        loadExperimentsFromRealm()
    }
    
    // MARK: - Realm Setup
    private func setupRealm() {
        do {
            var config = Realm.Configuration()
            config.fileURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourapp.cytometry")?
                .appendingPathComponent("default.realm")
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
        } catch {
            print("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Experiments
    private func loadExperimentsFromRealm() {
        guard let realm = realm else {
            print("Realm not initialized")
            return
        }
        let realmExperiments = realm.objects(Experiment.self)
        experiments = Array(realmExperiments)
    }
    
    // MARK: - Save Experiments
    func saveExperimentsToRealm() {
        guard let realm = realm else {
            print("Realm not initialized")
            return
        }
        do {
            try realm.write {
                realm.delete(realm.objects(Experiment.self)) // Clear existing experiments
                realm.add(experiments)
            }
        } catch {
            print("Failed to save experiments to Realm: \(error.localizedDescription)")
        }
    }
    
    func append(_ experiment: Experiment) {
        experiments.append(experiment)
        saveExperimentsToRealm()
    }
    
    @discardableResult
    func createNewExperiment() -> Experiment {
        let exp = Experiment()
        let names = experiments.map { $0.name }
        exp.name = exp.name.generateUnique(existing: names)
        experiments.append(exp)
        selectedExperiment = exp.id
        saveExperimentsToRealm()
        return exp
    }
    
    func removeExperiment(_ experiment: Experiment) {
        experiments.removeAll { $0.id == experiment.id }
        if selectedExperiment == experiment.id {
            selectedExperiment = experiments.sorted(by: \.modifiedDate).first?.id
        }
        saveExperimentsToRealm()
    }
}

extension App {
    func experimentsModified(year: Int) -> [Experiment] {
        experiments.filter { $0.modifiedDate[.year] == year }
    }
    
    var recentExperiments: [Experiment] {
        experiments.sorted(by: \.modifiedDate)
    }
}
