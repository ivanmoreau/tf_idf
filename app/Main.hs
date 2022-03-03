{- |
Copyright: (c) 2022 Iván Molina Rebolledo

SPDX-License-Identifier: GPL-3.0-only
Maintainer: Iván Molina Rebolledo <ivanmolinarebolledo@gmail.com>

See README for more info
-}
   
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# OPTIONS_GHC -fno-cse #-}

module Main (main) where

import           TFIDF (someFunc, genMatrix, search)
import qualified Data.ByteString as BS
import           Data.List
import qualified Data.Map as Dm
import           Data.Serialize

import           Data.Serialize.Text ()
import           Data.Text
import           Data.Text.IO as DT (readFile, putStrLn)
import System.Console.CmdArgs
import           Query (doQuery)

type Matrix = (Dm.Map Text (Dm.Map Int Double))

readTest :: FilePath -> IO Matrix
readTest name = do
  c <- DT.readFile name
  let r = genMatrix c
  return r

save :: Serialize a => a -> FilePath -> IO ()
save e name = do
  BS.writeFile name (encode e)

handleMatrix :: Text -> Text -> IO (Either String a)
handleMatrix input output = do
  matrix <- readTest (unpack input)
  save matrix (unpack output)
  return (Left "Done.")


load :: Serialize a => Text -> IO (Either String a)
load name = do
  bstr <- BS.readFile (unpack name)
  let m = decode bstr
  return m

--  | (fst c) `elem` (fst $ unzip le) = pack ("[" ++ show c₀ ++ "] " ++ (unpack l) ++ " (W: " ++ show (snd) ++ ")"):stripLines lines (cc) (c₀ + 1)
--  | otherwise = stripLines lines (c:cc) (c₀ + 1)

stripLines ::  [Text] -> [(Int, Double)] -> [Text]
stripLines _ [] = []
stripLines [] _ = []
stripLines l (c:cc) = case Data.List.find (\(a,b) -> a==(fst c)) le of
  Just (n, t) -> pack ("[" ++ show n ++ "] " ++ (unpack t) ++ " (W: " ++ show (snd c) ++ ")") : stripLines l cc
  Nothing -> stripLines l cc
  where le = Data.List.zip [0..] l :: [(Int, Text)]

handleQuery :: Text -> Text -> String -> IO (Either String Text)
handleQuery query matrix_ defs =
  case doQuery query of
    Right i -> do
      val <- load matrix_
      case val of
        Right matrix -> do
          let l = search i matrix
          fs <- DT.readFile defs
          let ss = splitOn "\n" fs
          let yy = stripLines ss (Data.List.reverse $ sortOn snd l)
          return $ Right (Data.Text.intercalate "\n" yy)
        Left err -> do return $ Left (show err)
    Left err -> do return $ Left (show err)


handle :: Text -> Matrix -> IO (Either String Matrix)
handle text m = f (Data.List.filter (/= "") (splitOn " " text))
  where f (":matrix":input:output:[]) = handleMatrix input output
        f (":load":input:[]) = load input
        f _ = error "text"

something :: TFIDF -> IO (Either String Text)
something (Matrix from to) = handleMatrix (pack from) (pack to)
something (Query defs from q) = handleQuery (pack q) (pack from) defs


data TFIDF = Matrix {from :: String, to :: String}
  | Query {ogfile :: String, matrix :: String, query :: String}
  deriving (Show, Data, Typeable)

genmatrix = Matrix {from = def, to = def}
doquery = Query {ogfile = def, matrix = def, query = def}


main :: IO ()
main = do
    args <- cmdArgs (modes [genmatrix,doquery])
    f <- something args
    case f of
      Right x -> DT.putStrLn x
      Left x -> Prelude.putStrLn x
    
