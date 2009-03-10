
-- we want to fold something like this
g = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
    ]

-- into a Cell { value=1, right=(the Cell with value 2), down=(the cell with value 4) }

data Cell a = Cell {
    value :: a,
    down  :: Cell a,
    right :: Cell a
    }
    | Nil
    deriving Show

right' :: Cell a -> Cell a
right' c@(Cell {}) = right c
right' Nil         = Nil

mkRow :: [a] -> Cell a -> Cell a
mkRow xs c = foldr mkCell Nil valAndDown
    where valAndDown = zip xs (iterate right' c)
          mkCell (v,d) r = Cell { value=v, down=d, right=r }

mkGrid :: [[a]] -> Cell a
mkGrid = foldr mkRow Nil
