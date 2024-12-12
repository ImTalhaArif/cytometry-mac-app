//
//  Batching.swift
//  CytegeistCore
//
//  Created by Adam Treister on 10/26/24.
//  Modified by John Irving on 8/12/24
//

import Foundation
import RealmSwift

// BatchContext manages data from Realm and provides methods for fetching and managing samples.
@Observable
public class BatchContext {
    public static let empty = BatchContext(allSamples: [])
    
    // Realm instance
    private var realm: Realm
    
    // All samples, now stored in Realm
    public var allSamples: [Sample]
    
    // Initialize with Realm
    public init(realm: Realm = try! Realm()) {
        self.realm = realm
        self.allSamples = Array(realm.objects(Sample.self))
    }
    
    // Get sample by ID
    public func getSample(_ id: Sample.ID) -> Sample? {
        allSamples.first { $0.id == id }
    }
    
    // Get sample by keyword and value
    public func getSample(keyword: String, value: String) -> Sample? {
        allSamples.first { $0.meta?.keywordLookup[keyword] == value }
    }
    
    // Get sample by two keywords and values
    public func getSample(keyword: String, value: String, keyword2: String, value2: String) -> Sample? {
        allSamples.first { $0.meta?.keywordLookup[keyword] == value && $0.meta?.keywordLookup[keyword2] == value2 }
    }
    
    // Fetch samples asynchronously using concurrency
    public func fetchSamplesAsync() async -> [Sample] {
        await withTaskGroup(of: [Sample].self) { group in
            group.addTask {
                return self.fetchSamplesFromRealm()
            }
            var results: [Sample] = []
            for await result in group {
                results.append(contentsOf: result)
            }
            return results
        }
    }
    
    private func fetchSamplesFromRealm() -> [Sample] {
        // Perform Realm query (just as an example)
        let samples = realm.objects(Sample.self)
        return Array(samples)
    }
}

// BatchProcessor handles the file processing tasks concurrently, such as file analysis.
class BatchProcessor {
    private var batchContext: BatchContext
    
    init(batchContext: BatchContext = BatchContext()) {
        self.batchContext = batchContext
    }
    
    // Process files concurrently using async/await
    func processFiles(fileURLs: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for fileURL in fileURLs {
                group.addTask {
                    await self.analyzeFile(url: fileURL)
                }
            }
        }
    }

    // Analyze a single file asynchronously
    private func analyzeFile(url: URL) async {
        // Perform file processing (e.g., gating, statistics)
        print("Processing file at \(url.path)")

        // Example of interacting with the batch context (getting samples)
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                let samples = await self.batchContext.fetchSamplesAsync()
                print("Fetched \(samples.count) samples.")
            }
        }
    }
}

// Sample model for Realm database
class Sample: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var meta: Meta?
    
    // Define other properties
}

// Meta model for storing keyword lookup
class Meta: Object {
    @objc dynamic var keywordLookup: [String: String] = [:]
}
