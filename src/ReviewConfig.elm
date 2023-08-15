module ReviewConfig exposing (config)

import CognitiveComplexity
import Docs.NoMissing exposing (allModules, everything)
import Docs.ReviewAtDocs
import Docs.ReviewLinksAndSections
import Docs.UpToDateReadmeLinks
import NoBooleanCase
import NoConfusingPrefixOperator
import NoDebug.Log
import NoDebug.TodoOrToString
import NoDeprecated
import NoDuplicatePorts
import NoEmptyText
import NoExposingEverything
import NoFloatIds
import NoImportingEverything
import NoInconsistentAliases
import NoInvalidRGBValues
import NoLeftPizza
import NoLongImportLines
import NoMissingSubscriptionsCall
import NoMissingTypeAnnotation
import NoMissingTypeAnnotationInLetIn
import NoMissingTypeConstructor
import NoMissingTypeExpose
import NoModuleOnExposedNames
import NoPrematureLetComputation
import NoPrimitiveTypeAlias
import NoRecordAliasConstructor
import NoRecursiveUpdate
import NoRedundantConcat
import NoRedundantCons
import NoSimpleLetBody
import NoSinglePatternCase
import NoUnmatchedUnit
import NoUnnecessaryTrailingUnderscore
import NoUnoptimizedRecursion
import NoUnsafeDivision
import NoUnsafePorts
import NoUnsortedCases
import NoUnsortedLetDeclarations
import NoUnsortedRecords
import NoUnsortedTopLevelDeclarations
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import NoUnusedPorts
import NoUselessSubscriptions
import Review.Rule as Rule exposing (Rule)
import ReviewPipelineStyles
import ReviewPipelineStyles.Premade as PremadePipelineRule
import Simplify
import UseCamelCase
import UseMemoizedLazyLambda


{-| `elm-review` config
-}
config : List Rule
config =
    [ -- Check cognitive complexity (branching, not branches) of code
      CognitiveComplexity.rule 15

    -- Make sure that every TLD is documented
    , Docs.NoMissing.rule
        { document = everything
        , from = allModules
        }
        |> Rule.ignoreErrorsForDirectories [ "tests" ]

    -- Ensure links in documentation are not broken or malformed
    , Docs.ReviewLinksAndSections.rule

    -- Ensure `@docs` doesn't appear malformed or where it doesn't belong
    , Docs.ReviewAtDocs.rule

    -- Reports links in the README.md that point to this project's package documentation on https://package.elm-lang.org/, where the version is set to latest or a different version than the current version of the package.
    , Docs.UpToDateReadmeLinks.rule

    -- Disallow pattern matching on boolean values.
    , NoBooleanCase.rule

    -- Forbid `(-) 1` and `(++) xs` and the like (non-commutative operators)
    , NoConfusingPrefixOperator.rule

    -- Forbid `Debug.log`
    , NoDebug.Log.rule

    -- Forbid `Debug.todo` and `Debug.toString`
    , NoDebug.TodoOrToString.rule

    -- Forbid use of deprecated functions
    , NoDeprecated.rule NoDeprecated.defaults

    -- Ensure port names are unique within a project
    , NoDuplicatePorts.rule

    -- Forbid `Html.text ""` instead of `HtmlX.nothing`
    , NoEmptyText.rule

    -- Forbid `module A exposing (..)`
    , NoExposingEverything.rule

    -- Detect use of `Float`s as ids
    , NoFloatIds.rule

    -- Forbid `import A exposing (..)`
    , NoImportingEverything.rule []

    -- Ensure consistent import aliases and enforce their use
    , NoInconsistentAliases.config
        [ ( "Array.Extra", "ArrayX" )
        , ( "Html.Attributes", "Attr" )
        , ( "Html.Extra", "HtmlX" )
        , ( "Json.Decode", "Decode" )
        , ( "Json.Decode.Ancillary", "DecodeA" )
        , ( "Json.Decode.Extra", "DecodeX" )
        , ( "Json.Encode", "Encode" )
        , ( "Json.Encode.Extra", "EncodeX" )
        , ( "List.Extra", "ListX" )
        , ( "List.Nonempty", "NE" )
        , ( "List.Nonempty.Ancillary", "NEA" )
        , ( "Maybe.Extra", "MaybeX" )
        , ( "Random.Extra", "RandomX" )
        , ( "Result.Extra", "ResultX" )
        , ( "Svg.Attributes", "SvgAttr" )
        ]
        |> NoInconsistentAliases.noMissingAliases
        |> NoInconsistentAliases.rule

    -- Make sure rgb and rgb255 arguments are within the ranges [0, 1] and [0, 255] respectively.
    , NoInvalidRGBValues.rule

    -- Disallow unnecessary function application operators, e.g. `a <| b`
    , NoLeftPizza.rule NoLeftPizza.Redundant

    -- Forbid import lines longer than 120 characters
    , NoLongImportLines.rule

    -- Reports likely missing calls to a `subscriptions` function.
    , NoMissingSubscriptionsCall.rule

    -- Forbid missing type annotations for TLDs
    , NoMissingTypeAnnotation.rule

    -- Forbid missing type annotations in let expressions
    , NoMissingTypeAnnotationInLetIn.rule

    -- Report missing constructors for lists of all constructors, e.g. `Color = Red | Blue | Green` will error with `[Red, Blue]`
    , NoMissingTypeConstructor.rule

    -- Forbid not exposing the type for any types that appear in exported functions or values
    , NoMissingTypeExpose.rule
        |> Rule.ignoreErrorsForFiles [ "src/Main.elm" ]

    -- Disallow qualified use of names imported unqualified
    , NoModuleOnExposedNames.rule

    -- Forbid let declarations that are computed earlier than needed
    , NoPrematureLetComputation.rule

    -- Forbid `type alias Days = Int` instead of `type Days = Days Int`
    , NoPrimitiveTypeAlias.rule

    -- Forbid calling `update` within `update`
    , NoRecursiveUpdate.rule

    -- Warn about unnecessary `++`'s, e.g. `[a] ++ [b]` instead of `[a, b]`
    , NoRedundantConcat.rule

    -- Forbids consing to a literal list, e.g. `foo::[bar]` instead of `[foo,bar]`
    , NoRedundantCons.rule

    -- Forbid `let a = 5 in`
    , NoSimpleLetBody.rule

    -- Forbid unnecessary/overly verbose `case` blocks
    , NoSinglePatternCase.fixInArgument
        |> NoSinglePatternCase.replaceUnusedBindings
        |> NoSinglePatternCase.rule

    -- Forbid all use of type alias constructors
    , NoRecordAliasConstructor.rule

    -- Disallow matching `()` with `_`
    , NoUnmatchedUnit.rule

    -- Disallow `\p_ ->` if there is no `p` in scope
    , NoUnnecessaryTrailingUnderscore.rule

    -- Disallow division that could crash or create unexpected results, e.g. 1 / 0
    , NoUnsafeDivision.rule

    -- Disallow ports that do not use JSON (preventing run-time errors)
    , NoUnsafePorts.rule NoUnsafePorts.any

    -- Forbid recursion without TCO
    , NoUnoptimizedRecursion.optOutWithComment "IGNORE TCO"
        |> NoUnoptimizedRecursion.rule

    -- Report unused custom type constructors
    , NoUnused.CustomTypeConstructors.rule []

    -- Report unused custom type fields
    , NoUnused.CustomTypeConstructorArgs.rule

    -- Report unused dependencies
    , NoUnused.Dependencies.rule

    -- Report exports and modules never used in other modules
    , NoUnused.Exports.rule

    -- Report unused function parameters
    , NoUnused.Parameters.rule

    -- Report unused parameters in pattern matching
    , NoUnused.Patterns.rule

    -- Report variables that are declared but never used
    , NoUnused.Variables.rule

    -- Ensure all ports are used
    , NoUnusedPorts.rule

    -- Reports `subscriptions` functions that never return a subscription.
    , NoUselessSubscriptions.rule

    -- Enforce ordering of case patterns
    , NoUnsortedCases.rule
        (NoUnsortedCases.defaults
            |> NoUnsortedCases.sortListPatternsByLength
        )

    -- Enforce ordering of let declarations
    , NoUnsortedLetDeclarations.rule
        (NoUnsortedLetDeclarations.sortLetDeclarations
            |> NoUnsortedLetDeclarations.usedInExpressionFirst
            |> NoUnsortedLetDeclarations.alphabetically
            |> NoUnsortedLetDeclarations.glueHelpersAfter
        )

    -- Enforce ordering of record fields
    , NoUnsortedRecords.rule
        (NoUnsortedRecords.defaults
            |> NoUnsortedRecords.treatAllSubrecordsAsCanonical
            -- This is only on to help me find bugs
            |> NoUnsortedRecords.typecheckAllRecords
            |> NoUnsortedRecords.reportAmbiguousRecordsWithoutFix
        )

    -- Enforce ordering of TLDs
    , NoUnsortedTopLevelDeclarations.rule
        (NoUnsortedTopLevelDeclarations.sortTopLevelDeclarations
            |> NoUnsortedTopLevelDeclarations.portsFirst
            |> NoUnsortedTopLevelDeclarations.exposedOrderWithPrivateLast
            |> NoUnsortedTopLevelDeclarations.typesFirst
            |> NoUnsortedTopLevelDeclarations.alphabetically
            |> NoUnsortedTopLevelDeclarations.glueHelpersAfter
        )

    -- Enforce pipeline style guidelines
    , List.concat
        [ -- <| should not be multiline except in tests
          PremadePipelineRule.noMultilineLeftPizza

        -- << should not be multiline
        , PremadePipelineRule.noMultilineLeftComposition

        -- >> should only be multiline
        , PremadePipelineRule.noSingleLineRightComposition

        -- |> should only be multiline
        , PremadePipelineRule.noSingleLineRightPizza

        -- |> should never have an input like `a |> b |> c` vs `b a |> c`
        -- <| should never have an unnecessary input like `a <| b <| c` vs `a <| b c`
        , PremadePipelineRule.noPipelinesWithSimpleInputs

        -- Parenthetical application should never be nested more than once
        , PremadePipelineRule.noRepeatedParentheticalApplication

        -- Forbid use of non-commutative functions like `(++)`
        , PremadePipelineRule.noPipelinesWithConfusingNonCommutativeFunctions

        -- Forbid use of semantically "infix" functions like `Maybe.andThen` in left pipelines
        , PremadePipelineRule.noSemanticallyInfixFunctionsInLeftPipelines
        ]
        |> ReviewPipelineStyles.rule

    -- Detect simplifiable expressions, e.g. `a == True` can be simplified to `a`
    , Simplify.rule Simplify.defaults

    -- Enforce naming in camelCase and PascalCase
    , UseCamelCase.rule UseCamelCase.default

    -- Enforce a constrained use of `Html.lazy` to ensure it actually is memoized properly
    , UseMemoizedLazyLambda.rule
    ]
