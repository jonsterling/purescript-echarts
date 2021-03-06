module Scatter3 where

import Prelude
import Control.Monad.Eff.Console (print)
import Control.Monad.Eff
import Control.Monad.Eff.Random
import Data.Tuple
import Data.Tuple.Nested
import Data.Array hiding (init)
import Math
import Data.Traversable


import ECharts.Chart
import ECharts.Options
import ECharts.Series
import ECharts.Item.Value
import ECharts.Item.Data
import ECharts.Axis
import Data.Maybe
import qualified Utils as U
showIt = {show: true}


sinData = do 
  randomIs <- U.randomLst 10000.0
  randomXs <- U.randomLst 10000.0
  let randoms = zipWith (\i x -> Tuple (U.precise 3.0 $ i * 10.0) x)  randomIs randomXs

  let mapfn = \(Tuple i rnd) ->
    Tuple i (U.precise 3.0 $ sin i - i * (if i `mod` 2.0 > 0.0 then 0.1 else -0.1) * rnd)
  return $ mapfn <$> randoms

cosData = do
  randomIs <- U.randomLst 10000.0
  randomXs <- U.randomLst 10000.0
  let randoms = zipWith (\i x -> Tuple (U.precise 3.0 $ i * 10.0) x)  randomIs randomXs
  let mapfn = \(Tuple i rnd) -> 
        Tuple i (U.precise 3.0 $ cos i - i * (if i % 2.0 > 0.0 then 0.1 else -0.1) * rnd)
  return $ mapfn <$> randoms

simpleData (Tuple a b) = Value $ XYR {
  x: a,
  y: b,
  r: Nothing
  }

options :: Eff _ _ 
options = do
  sines <- sinData
  coses <- cosData
  return $ Option $ optionDefault {
    xAxis = Just $ OneAxis $ Axis axisDefault {"type" = Just ValueAxis},
    yAxis = Just $ OneAxis $ Axis axisDefault {"type" = Just ValueAxis},
    series = Just $ Just <$> [
       ScatterSeries {
          common: universalSeriesDefault{
             name = Just "sin"
             },
          scatterSeries: scatterSeriesDefault {
            large =  Just true,
            "data" = Just $ simpleData <$> sines
            }
          },
       ScatterSeries {
         common: universalSeriesDefault{
            name = Just "cos"
            },
         scatterSeries: scatterSeriesDefault {
           large = Just true,
           "data" = Just $ simpleData <$> coses
           }
         }
       ]
    }

scatter3 id = do
  mbEl <- U.getElementById id
  case mbEl  of
    Nothing -> print "incorrect id in scatter3"
    Just el -> do
      opts <- options
      init Nothing el >>= setOption opts true >>= \_ -> return unit


