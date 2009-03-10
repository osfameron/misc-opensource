import Data.Maybe

-- we want to fold something like this
g = [
    [ 1, 2, 3 ],
    [ 4, 5, 6 ],
    [ 7, 8, 9 ]
    ]

-- into a Cell { value=1, right=(the Cell with value 2), down=(the cell with value 4) }

data Cell a = Cell {
    value :: a,
    down  :: Maybe (Cell a),
    right :: Maybe (Cell a)
    }
    deriving Show

mkRow :: [a] -> Maybe (Cell a) -> Maybe (Cell a)
mkRow xs c = foldr mkCell Nothing valAndDown
    where valAndDown     = zip xs $ iterate (>>= right) c
          mkCell (v,d) r = Just $ Cell { value=v, down=d, right=r }

mkGrid :: [[a]] -> Cell a
mkGrid = fromJust . foldr mkRow Nothing
