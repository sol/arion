{-# LANGUAGE OverloadedStrings #-}
module Arion.EventProcessorSpec where

import Test.Hspec
import System.FSNotify
import Data.Time.Clock
import Data.Time.Calendar
import Data.Map

import Arion.EventProcessor
import Arion.Types

main :: IO ()
main = hspec spec

spec = do
    describe "Event Processor" $ do
        it "responds to a Modified event on a test file by creating commands to run tests" $ do
            let sourceFilePathA = "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.hs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let modifiedEvent = Modified "mydir/ModuleASpec.hs" sampleTime
            let sourceFolder = "src"
            let expectedCommands = [Echo "mydir/ModuleASpec.hs changed", CabalCommand $ RunHaskell "src" "mydir/ModuleASpec.hs"]

            processEvent sourceToTestFileMap sourceFolder modifiedEvent `shouldBe` expectedCommands
        it "responds to a Modified event on a source file by creating commands to run the associated tests" $ do
            let sourceFilePathA = "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.hs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let modifiedEvent = Modified "src/ModuleA.hs" sampleTime
            let sourceFolder = "src"
            let expectedCommands = [Echo "src/ModuleA.hs changed", CabalCommand $ RunHaskell "src" "test/ModuleASpec.hs",
                                       CabalCommand $ RunHaskell "src" "test/ModuleBSpec.hs"]

            processEvent sourceToTestFileMap sourceFolder modifiedEvent `shouldBe` expectedCommands
        it "responds to a Added event on a test file by creating commands to run tests" $ do
            let sourceFilePathA = "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.hs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let addedEvent = Added "mydir/ModuleASpec.hs" sampleTime
            let sourceFolder = "src"
            let expectedCommands = [Echo "mydir/ModuleASpec.hs changed", CabalCommand $ RunHaskell "src" "mydir/ModuleASpec.hs"]

            processEvent sourceToTestFileMap sourceFolder addedEvent `shouldBe` expectedCommands
        it "responds to a Added event on a source file by creating commands to run the associated tests" $ do
            let sourceFilePathA = "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.hs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let addedEvent = Added "src/ModuleA.hs" sampleTime
            let sourceFolder = "src"
            let expectedCommands = [Echo "src/ModuleA.hs changed", CabalCommand $ RunHaskell "src" "test/ModuleASpec.hs",
                                       CabalCommand $ RunHaskell "src" "test/ModuleBSpec.hs"]


            processEvent sourceToTestFileMap sourceFolder addedEvent `shouldBe` expectedCommands
        it "ignores non haskell source files" $ do
            let sourceFilePathA = "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.hs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let modifiedEvent = Modified "mydir/ModuleASpec.hs~" sampleTime
            let expectedCommands = []
            let sourceFolder = "src"

            processEvent sourceToTestFileMap sourceFolder modifiedEvent `shouldBe` expectedCommands

            let addedEvent = Added "mydir/ModuleASpec.swp" sampleTime

            processEvent sourceToTestFileMap sourceFolder addedEvent `shouldBe` expectedCommands
        it "does not ignore lhs files" $ do
            let sourceFilePathA = "src/ModuleA.lhs"
            let testFileA = TestFile "test/ModuleASpec.lhs" ["ModuleA"]
            let testFileB = TestFile "test/ModuleBSpec.lhs" ["ModuleB"]
            let sourceToTestFileMap = fromList [(sourceFilePathA, [testFileA, testFileB])]
            let addedEvent = Added "mydir/ModuleASpec.lhs" sampleTime
            let sourceFolder = "src"
            let expectedCommands = [Echo "mydir/ModuleASpec.lhs changed", CabalCommand $ RunHaskell "src" "mydir/ModuleASpec.lhs"]

            processEvent sourceToTestFileMap sourceFolder addedEvent `shouldBe` expectedCommands
sampleTime :: UTCTime
sampleTime = UTCTime (ModifiedJulianDay 2) (secondsToDiffTime 2)

