//
//  KMeans.swift
//  DominantColor
//
//  Created by Indragie on 12/20/14.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

import Darwin

// Represents a type that can be clustered using the k-means clustering
// algorithm.
protocol ClusteredType {
    // Used to compute average values to determine the cluster centroids.
    func +(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Int) -> Self

    // Identity value such that x + identity = x. Typically the 0 vector.
    static var identity: Self { get }
}

struct Cluster<T: ClusteredType> {
    let centroid: T
    let size: Int
}

// k-means clustering algorithm from
// http://users.eecs.northwestern.edu/~wkliao/Kmeans/

func kmeans<T: ClusteredType>(
        points: [T],
        k: Int,
        seed: UInt32,
        distance: ((T, T) -> Float),
        threshold: Float = 0.0001
    ) -> [Cluster<T>] {

    let n = points.count
    assert(k <= n, "k cannot be larger than the total number of points")

    var centroids = points.randomValues(seed, num: k)
    var memberships = [Int](count: n, repeatedValue: -1)
    var clusterSizes = [Int](count: k, repeatedValue: 0)

    var error: Float = 0
    var previousError: Float = 0

    repeat {
        error = 0
        var newCentroids = [T](count: k, repeatedValue: T.identity)
        var newClusterSizes = [Int](count: k, repeatedValue: 0)

        for i in 0..<n {
            let point = points[i]
            let clusterIndex = findNearestCluster(point, centroids: centroids, k: k, distance: distance)
            if memberships[i] != clusterIndex {
                error += 1
                memberships[i] = clusterIndex
            }
            newClusterSizes[clusterIndex] += 1
            newCentroids[clusterIndex] = newCentroids[clusterIndex] + point
        }
        for i in 0..<k {
            let size = newClusterSizes[i]
            if size > 0 {
                centroids[i] = newCentroids[i] / size
            }
        }

        clusterSizes = newClusterSizes
        previousError = error
    } while abs(error - previousError) > threshold

    return Zip2Sequence(centroids, clusterSizes).map { Cluster(centroid: $0, size: $1) }
}

private func findNearestCluster<T: ClusteredType>(point: T, centroids: [T], k: Int, distance: (T, T) -> Float) -> Int {
    var minDistance = Float.infinity
    var clusterIndex = 0
    for i in 0..<k {
        let distance = distance(point, centroids[i])
        if distance < minDistance {
            minDistance = distance
            clusterIndex = i
        }
    }
    return clusterIndex
}

private extension Array {
    private func randomValues(seed: UInt32, num: Int) -> [Element] {
        let r = RandomNumbers(seed: seed)
        var indices = [Int]()
        indices.reserveCapacity(num)
        for _ in 0..<num {
            var random = 0
            repeat {
                random = Int(r.uniformDistributedWithMax(UInt64(count - 1)))
            } while indices.contains(random)
            indices.append(random)
        }
        return indices.map { self[$0] }
    }
}
