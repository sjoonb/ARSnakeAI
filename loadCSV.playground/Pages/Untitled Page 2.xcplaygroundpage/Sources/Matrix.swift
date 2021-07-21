//
//  Matrix.swift
//  ARSnakeAI
//
//  Created by 백성준 on 2021/07/14.
//

class Matrix {
    var rows, cols: Int
    var matrix: [[Double]]!
    
    init(r: Int, c: Int) {
        rows = r
        cols = c
        matrix = [[Double]]()
        
        for _ in 0..<rows {
            var rowMatrx = [Double]()
            for _ in 0..<cols {
                rowMatrx.append(0)
            }
            matrix.append(rowMatrx)
        }
    }
    
    init(m: [[Double]]) {
        matrix = m
        rows = matrix.count
        cols = matrix[0].count
    }
    
    func randomize() {
        for i in 0..<rows {
            for j in 0..<cols {
                matrix[i][j] = Double.random(in: -1..<1)
            }
        }
        
    }
    
    func singleColumnMatrixFromArray(arr: [Double]) -> Matrix {
        let n = Matrix(r: arr.count, c: 1);
        for i in 0..<arr.count {
            n.matrix[i][0] = arr[i]
        }
        return n
    }
    
    func addBias() -> Matrix {
        let n = Matrix(r: rows+1, c: 1)
        for i in 0..<rows {
            n.matrix[i][0] = matrix[i][0]
        }
        n.matrix[rows][0] = 1
        return n
    }
    
    func dot(input: Matrix) -> Matrix {
        let result: Matrix = Matrix(r: rows, c: input.cols)
        if(cols == input.rows) {
            for i in 0..<rows {
                for j in 0..<input.cols {
                    var sum: Double = 0
                    for k in 0..<cols {
                        sum += matrix[i][k] * input.matrix[k][j]
                    }
                    result.matrix[i][j] = sum
                }
            }
        }
        return result
    }
    
    func activate() -> Matrix {
        let n: Matrix = Matrix(r: rows, c: cols)
        for i in 0..<rows {
            for j in 0..<cols {
                n.matrix[i][j] = relu(x: matrix[i][j])
            }
        }
        return n
    }
    
    func relu(x: Double) -> Double {
        return max(0, x)
    }
    
    func toArray() -> [Double] {
        var arr: [Double] = [Double](repeating: 0, count: rows*cols)
        for i in 0..<rows {
            for j in 0..<cols {
                arr[j+i*cols] = matrix[i][j]
            }
        }
        return arr
    }
    
    
    func clone() -> Matrix {
        let clone: Matrix = Matrix(r: rows, c: cols)
        for i in 0..<rows {
            for j in 0..<cols {
                clone.matrix[i][j] = matrix[i][j]
            }
        }
        return clone
    }
}
