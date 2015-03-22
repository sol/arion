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
            let sourceFileA = SourceFile "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs"
            let testFileB = TestFile "test/ModuleBSpec.hs"
            let sourceToTestFileMap = fromList [(sourceFileA, [testFileA, testFileB])]
            let modifiedEvent = Modified "mydir/ModuleASpec.hs" sampleTime
            let expectedCommands = [Command "runhaskell mydir/ModuleASpec.hs"]

            processEvent sourceToTestFileMap modifiedEvent `shouldBe` expectedCommands
        it "responds to a Modified event on a source file by creating commands to run the associated tests" $ do
            let sourceFileA = SourceFile "src/ModuleA.hs"
            let testFileA = TestFile "test/ModuleASpec.hs"
            let testFileB = TestFile "test/ModuleBSpec.hs"
            let sourceToTestFileMap = fromList [(sourceFileA, [testFileA, testFileB])]
            let modifiedEvent = Modified "src/ModuleA.hs" sampleTime
            let expectedCommands = [Command "runhaskell test/ModuleASpec.hs",
                                    Command "runhaskell test/ModuleBSpec.hs"]

            processEvent sourceToTestFileMap modifiedEvent `shouldBe` expectedCommands

sampleTime :: UTCTime
sampleTime = UTCTime (ModifiedJulianDay 2) (secondsToDiffTime 2)
