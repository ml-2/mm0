module CAST (module CAST, Ident, DepType(..), SortData(..)) where

import Control.Monad.Except
import qualified Data.ByteString as B
import qualified Data.Map.Strict as M
import qualified Data.Text as T
import Text.Megaparsec.Pos
import Environment (Ident, SortData(..))
import Util

data AtPos a = AtPos SourcePos a
data Span a = Span SourcePos a SourcePos

instance Functor AtPos where
  fmap f (AtPos l a) = AtPos l (f a)

type AST = [AtPos Stmt]

data Visibility = Public | Abstract | Local
data DeclKind = DKTerm | DKAxiom | DKTheorem | DKDef
data Stmt =
    Sort Ident SortData
  | Decl Visibility DeclKind Ident [Binder] (Maybe [Type]) (Maybe LispVal)
  | Theorems [Binder] LispVal
  | Notation Notation
  | Inout Inout
  | Annot LispVal Stmt
  | Do [LispVal]

data Notation =
    Delimiter Const
  | Prefix Ident Const Prec
  | Infix Bool Ident Const Prec
  | Coercion Ident Ident Ident
  | NNotation Ident [Binder] DepType [Literal]

data Literal = NConst Const Prec | NVar Ident

data Const = Const T.Text
type Prec = Int

type InputKind = String
type OutputKind = String

data Inout =
    Input InputKind [Either Ident Formula]
  | Output OutputKind [Either Ident Formula]

data Local = LBound Ident | LReg Ident | LDummy Ident | LAnon

data DepType = DepType (AtPos Ident) [AtPos Ident]

data Type = TType DepType | TFormula Formula

data Formula = Formula SourcePos T.Text

data Binder = Binder SourcePos Local (Maybe Type)

isLBound :: Local -> Bool
isLBound (LBound _) = True
isLBound _ = False

localName :: Local -> Maybe Ident
localName (LBound v) = Just v
localName (LReg v) = Just v
localName (LDummy v) = Just v
localName LAnon = Nothing

data LispVal =
    Atom T.Text
  | List [LispVal]
  | Cons LispVal LispVal
  | Number Integer
  | String T.Text
  | Bool Bool
  | LFormula Formula

cons :: LispVal -> LispVal -> LispVal
cons l (List r) = List (l : r)
cons l r = Cons l r