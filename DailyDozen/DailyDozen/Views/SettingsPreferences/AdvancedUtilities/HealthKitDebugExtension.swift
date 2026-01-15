//
//  HealthKitDebugExtension.swift
//  DailyDozen
//

#if DEBUG
import HealthKit

extension HealthManager {
    
    //func debugPrintAuthorizationStatus() {
    //    Task { @MainActor in
    //        guard HKHealthStore.isHealthDataAvailable() else {
    //            print("•HK• HealthKit not available")
    //            return
    //        }
    //        
    //        let bodyMass = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    //        let readTypes: Set<HKObjectType> = [bodyMass]
    //        let writeTypes: Set<HKSampleType> = Set(readTypes.compactMap { $0 as? HKSampleType })
    //        
    //        print("=== HealthKit Authorization Status ===")
    //        print("Read  \(bodyMass.identifier): \(hkHealthStore.authorizationStatus(for: bodyMass).humanReadable)")
    //        
    //        // THIS IS THE ONE THAT ALWAYS WORKS — the callback version
    //        hkHealthStore.getRequestStatusForAuthorization(toShare: writeTypes, read: readTypes) { status, error in
    //            Task { @MainActor in
    //                if let error = error {
    //                    print("•HK• Error: \(error.localizedDescription)")
    //                } else {
    //                    print("Overall: \(status.humanReadable)")
    //                }
    //                print("========================================\n")
    //            }
    //        }
    //    }
    //}
    
    //func debugForceHealthKitPermissionPrompt() {
    //    Task { @MainActor in
    //        let bodyMass = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    //        let readTypes: Set<HKObjectType> = [bodyMass]
    //        let writeTypes: Set<HKSampleType> = Set(readTypes.compactMap { $0 as? HKSampleType })
    //
    //        do {
    //            try await hkHealthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    //            print("•HK• Permission prompt shown (or skipped)")
    //        } catch {
    //            print("•HK• Request failed: \(error)")
    //        }
    //    }
    //}
}

// Extensions (unchanged)
extension HKAuthorizationStatus {
    var humanReadable: String {
        switch self {
        case .sharingAuthorized: return "Authorized"
        case .sharingDenied:     return "Denied"
        case .notDetermined:     return "Not Asked"
        @unknown default:        return "Unknown"
        }
    }
}

extension HKAuthorizationRequestStatus {
    var humanReadable: String {
        switch self {
        case .shouldRequest: return "Will Show Sheet"
        case .unnecessary:   return "Already Done"
        case .unknown:       return "Unknown"
        @unknown default:    return "Future"
        }
    }
}
#endif

#if DEBUG
extension HealthManager {
    
    /// Deletes ALL bodyMass samples your app ever saved — instantly
    func debugDeleteAllBodyMassData() {
        Task { @MainActor in
            guard let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {
                print("•HK• bodyMass type not available")
                return
            }
            
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: nil)
            
            let query = HKSampleQuery(
                sampleType: bodyMassType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                guard let samples = samples, !samples.isEmpty else {
                    print("•HK• No bodyMass samples to delete")
                    return
                }
                
                self.hkHealthStore.delete(samples) { success, error in
                    if success {
                        print("•HK• Deleted \(samples.count) bodyMass samples")
                    } else if let error = error {
                        print("•HK• Delete failed: \(error.localizedDescription)")
                    }
                }
            }
            
            hkHealthStore.execute(query)
            print("•HK• Deleting all your saved bodyMass data...")
        }
    }
}
#endif
