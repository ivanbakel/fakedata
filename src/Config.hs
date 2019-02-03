{-# LANGUAGE OverloadedStrings #-}

module Config where

import Control.Monad (filterM)
import Control.Monad.Catch
import Control.Monad.IO.Class
import Data.Text (Text, pack, unpack)
import Data.Yaml
import Faker
import System.Directory (doesFileExist, listDirectory)
import System.FilePath (takeExtension, takeFileName)
import System.FilePath

defaultEnDirectory :: FilePath
defaultEnDirectory = "faker/lib/locales/en"

localesDirectory :: FilePath
localesDirectory = "faker/lib/locales"

localesEnDirectory :: FilePath
localesEnDirectory = "faker/lib/locales/en"

isLocaleFile :: FilePath -> IO Bool
isLocaleFile fname = do
  exist <- doesFileExist fname
  pure (exist && (takeExtension fname == ".yml"))

listLocaleFiles :: FilePath -> IO [FilePath]
listLocaleFiles fname = do
  files <- listDirectory fname
  filterM isLocaleFile files

populateLocales :: IO [Text]
populateLocales = do
  files <- listLocaleFiles localesDirectory
  let files' = map (pack . takeFileName) files
  pure files'

data SourceData
  = Address
  | Name
  | Ancient
  | Animal
  | App
  | Appliance
  | ATHF
  | Artist
  | BTTF

sourceFile :: SourceData -> FilePath
sourceFile Address = localesEnDirectory </> "address.yml"
sourceFile Name = localesEnDirectory </> "name.yml"
sourceFile Ancient = localesEnDirectory </> "ancient.yml"
sourceFile Animal = localesEnDirectory </> "animal.yml"
sourceFile App = localesEnDirectory </> "app.yml"
sourceFile Appliance = localesEnDirectory </> "appliance.yml"
sourceFile ATHF = localesEnDirectory </> "aqua_teen_hunger_force.yml"
sourceFile Artist = localesEnDirectory </> "artist.yml"
sourceFile BTTF = localesEnDirectory </> "back_to_the_future.yml"

guessSourceFile :: SourceData -> Text -> FilePath
guessSourceFile sdata sysloc =
  case sysloc of
    "en" -> sourceFile sdata
    oth -> localesDirectory </> (unpack oth <> ".yml")

getSourceFile :: (MonadThrow m, MonadIO m) => FilePath -> m FilePath
getSourceFile fname = do
  exist <- liftIO $ doesFileExist fname
  if exist
    then pure fname
    else throwM $ InvalidLocale fname

fetchData ::
     (MonadThrow m, MonadIO m)
  => FakerSettings
  -> SourceData
  -> (FakerSettings -> Value -> Parser a)
  -> m a
fetchData settings sdata parser = do
  let fname = guessSourceFile sdata (getLocale settings)
  afile <- getSourceFile fname
  yaml <- decodeFileThrow afile
  parseMonad (parser settings) yaml
