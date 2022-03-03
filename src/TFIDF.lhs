\section{TF/IDF}

Esta sección es Literate Haskell. EL mmimso código es parte del ejecutable y 
parte del documento.

Licencia:
\begin{code}
{- |
Copyright: (c) 2022 Iván Molina Rebolledo

SPDX-License-Identifier: GPL-3.0-only
Maintainer: Iván Molina Rebolledo <ivanmolinarebolledo@gmail.com>

See README for more info
-}
\end{code}

Boilerplate:
\begin{code}
{-# LANGUAGE OverloadedStrings #-}

module TFIDF
  ( someFunc, genMatrix, search
  )
where

import           Data.List (delete, nub, elemIndices)
import qualified Data.Map as Dm
import           Data.Map (Map, fromList, insert, (!))
import           Data.Serialize.Text ()
import           Data.Text (Text, pack, replace, splitOn)
import           Query
import Debug.Trace

type MatrixW = Map Text (Map Int Double)
\end{code}

Lista de palabras a ignorar: 
\begin{code}
rone :: [Text]
rone = ["$user tweeted ", " $ht", "$ht ", " $user", "$user "]
\end{code}

Es necesario
limpiar todas las lineas del corpus (eliminar una lista de palabras)
\begin{code}
fixWords :: Text -> [Text] -> Text
fixWords xs [] = xs
fixWords xs (l : ls) = fixWords (replace l (pack "") xs) ls
\end{code}
con el fin de
obtener una matriz limpia con las palabras.
\begin{code}
getWords :: Text -> MatrixW
getWords l =
  fromList
    ( map
        (\x -> (x, fromList [(0, 0)]))
        (Data.List.delete "" (nub (splitOn " " (replace "\n" " " l))))
    )
\end{code}

Se ha de inicializar la matriz con el número de documentos:
\begin{code}
emptymatrix :: MatrixW -> Int -> MatrixW
emptymatrix m c = Dm.map (\_ -> fromList (map (\x -> (x, 0)) [0 .. c])) m
\end{code}

En este código se
establece la existencia de una palabra para el documento n; establece o
actualiza la frecuencia.
\begin{code}
aa :: MatrixW -> Text -> Int -> Double -> MatrixW
aa m t i val = let r = m ! ( t) in insert t (insert i val r) m
\end{code}

Se define la variante del peso TF, idf y el tf-idf:
\begin{code}
tf :: Text -> Text -> Double
tf i t = let o = Prelude.length $ elemIndices i $ splitOn " " t in
  if o > 0 then
    1.0 + logBase 2.0 (fromIntegral o)
  else 
    0

findcol :: Text -> Text -> Bool
findcol term text = (>0) $ Prelude.length $ filter (==term) $ splitOn " " text
findtex :: Text -> [Text] -> Int
findtex term textl = Prelude.length $ filter (==True) $ map (findcol term) textl 

idf :: Text -- Termino.
  -> [Text] -- [Lineas].
  -> Double
idf t m = let n = findtex t m in
  logBase 2.0 $ (fromIntegral $ Prelude.length m) / (fromIntegral n)


tfidf :: Text -> Text -> [Text] -> Double
tfidf term line lines_ = (tf term line) * (idf term lines_) 
\end{code}

Se llena la matriz por linea:
\begin{code}
byLine :: [Text] -> [Text] -> MatrixW -> Int -> MatrixW
byLine [] _ m _ = m
byLine (l : ls) lines_ m c = 
  let words_ = filter (/="") $ splitOn " " l 
      w_ = map (\w -> (w, tfidf w l lines_)) words_ in
  byLine ls lines_ (f m ( w_)) (c + 1)
  where f m_ [] = m_
        f m_ ((w, w_):xs) = f (aa m_ w c w_) xs
\end{code}

Se genera la matriz:
\begin{code}
genMatrix :: Text -> MatrixW
genMatrix t =
  let ff = fixWords t rone
      gw = getWords ff
      ts = (splitOn "\n" ff)
      em = emptymatrix gw (length ts)
   in byLine ts ts em 0
\end{code}

Busca la palabra y regresa los indices de los documentos:
\begin{code}
readd :: Text -> MatrixW -> [(Int, Double)]
readd t m = case Dm.lookup t m of
  Just v -> (Dm.toList (Dm.filter (>0) v))
  Nothing -> []
\end{code}

Se evalua el árbol de Query:
\begin{code}
lmin :: [(Int, Double)]-> [(Int, Double)] -> [(Int, Double)]
lmin _ [] = []
lmin l0 (l1:ls1) = lmin (filter (\(x, _) -> x /= (fst l1)) l0) ls1

lunion :: [(Int, Double)]-> [(Int, Double)] -> [(Int, Double)]
lunion l0 l1 = let n = filter (\(x,_) -> x `notElem` (fst $ unzip l0)) l1 in
  l0 ++ n

lintersect :: [(Int, Double)]-> [(Int, Double)] -> [(Int, Double)]
lintersect l0 l1 = let n = filter (\(x,_) -> x `elem` (fst $ unzip l0)) l1 in
  n

pw :: Query -> Int -> MatrixW -> [(Int, Double)]
pw (QAnd l r) t m = (pw l t m) `lintersect` (pw r t m)
pw (QOr l r) t m = (pw l t m) `lunion` (pw r t m)
pw (QNot e) t m = (zip [0..t] (replicate t 0)) `lmin` (pw e t m)
pw (QP v) _ m = readd v m
\end{code}

Se realiza una consulta con una Query:
\begin{code}
search :: Query -> MatrixW -> [(Int, Double)]
search q m = pw q (Dm.size (snd (Dm.elemAt 0 m))) m
\end{code}

\begin{code}
-- Este código no importa :) 
someFunc :: IO ()
someFunc = putStrLn ("someFunc" :: String)
\end{code}