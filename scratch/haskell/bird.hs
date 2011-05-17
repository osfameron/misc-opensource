import Text.ParserCombinators.Parsec hiding (many, (<|>), optional)
import Control.Applicative

data Bird = Bird  String
          | BirdV String
          | Song [Bird]

instance Show Bird where
    show x = "unsafeBirdFromString " ++ (show $ show' x)
        where show' (Bird  x) =  x
              show' (BirdV x) = x
              show' (Song xs) = concatMap show'' xs
              show'' s@(Song  _) = "(" ++ (show' s) ++ ")"
              show'' b           = show' b

simplify :: Bird -> Bird

simplify (Song [x])           = simplify x
simplify (Song ((Song x):xs)) = Song $ map simplify $ x ++ xs
simplify (Song xs)            = Song $ map simplify xs
simplify b                    = b

birdFromString source = case (parse parseExprOuter "" source) of
    Right x -> return $ simplify x
    Left  e -> error $ show e

unsafeBirdFromString source = case (parse parseExprOuter "" source) of
    Right x -> simplify x
    Left  e -> error $ show e

parseExprOuter = ((try parseSong) <|> parseExprAux) <* eof

parseExprAux   = (try parseList) <|> (try parseBird)  <|> (try parseBirdV)

parseBird  = parseBird' upper Bird
parseBirdV = parseBird' lower BirdV
parseBird' s c = do f <- s 
                    r <- many (digit <|> oneOf "*^")
                    return $ c (f:r)

parseList = char '(' *> parseSong <* char ')'

parseSong = do
    x <- many1 parseExprAux
    return $ Song x

matchSong :: Bird -> Bird -> Maybe Bird
matchSong (BirdV x) y = Just y
matchSong (Bird  x) b@(Bird y) | x == y = Just b
matchSong (Song xs) s@(Song ys) | length xs == length ys
    = case sequence $ zipWith matchSong xs ys of
        Nothing -> Nothing
        Just _  -> Just s
matchSong _ _ = Nothing
