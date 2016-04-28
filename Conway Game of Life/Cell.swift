//
//  Cell.swift
//  Conway Game of Life
//
//  Created by Shannon on 4/28/16.
//  Copyright © 2016 Elena Ariza. All rights reserved.
//

import Foundation


class Cell {
    var x: Int;
    var y: Int;
    var isAlive: Bool;
    /*
    * x0: initial x location of cell
    * y0: initial y location of cell
    */
    init(x0: Int, y0: Int) {
        x = x0;
        y = y0;
        isAlive = false;
    }
    
}
