{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module SuperMarioSpec where

import qualified Data.Map as M
import Data.Text hiding (all, map)
import qualified Data.Text as T
import qualified Data.Vector as V
import Faker hiding (defaultFakerSettings)
import Faker.Game.SuperMario
import Test.Hspec
import TestImport
import Faker.Internal

isText :: Text -> Bool
isText x = T.length x >= 1

fakerSettings :: FakerSettings
fakerSettings = defaultFakerSettings

verifyFakes :: [Fake Text] -> IO [Bool]
verifyFakes funs = do
  let fs :: [IO Text] = map (generateWithSettings fakerSettings) funs
      gs :: [IO Bool] = map (\f -> isText <$> f) fs
  sequence gs

spec :: Spec
spec = do
  describe "SuperMario" $ do
    it "sanity checking" $ do
      let functions :: [Fake Text] =
                       [
                        characters,
                        games,
                        locations
                       ]
      bools <- verifyFakes functions
      (and bools) `shouldBe` True
