import Lean.Elab.Command
import Lean.Elab.InfoTree

import Verso
import Verso.Doc.ArgParse
import Verso.Code

import SubVerso.Examples.Slice
import SubVerso.Highlighting

open Lean Elab
open Verso ArgParse Doc Elab Html Code
open SubVerso.Examples.Slice
open SubVerso.Highlighting Highlighted

structure Block where
  name : Name
  id : String

def VersoProofFlow.Block.lean : Block where
  name := `VersoProofFlow.Block.lean
  id := "lean"

def parserInputString [Monad m] [MonadFileMap m] (str : TSyntax `str) : m String := do
  let preString := (← getFileMap).source.extract 0 (str.raw.getPos?.getD 0)
  let mut code := ""
  let mut iter := preString.iter
  while !iter.atEnd do
    if iter.curr == '\n' then code := code.push '\n'
    else
      for _ in [0:iter.curr.utf8Size] do
        code := code.push ' '
    iter := iter.next
  code := code ++ str.getString
  return code

def processString (altStr : String) :  DocElabM (Array (TSyntax `term)) := do
  dbg_trace "Processing {altStr}"
  let ictx := Parser.mkInputContext altStr (← getFileName)
  let cctx : Command.Context := { fileName := ← getFileName, fileMap := FileMap.ofString altStr, cancelTk? := none, snap? := none}
  let mut cmdState : Command.State := {env := ← getEnv, maxRecDepth := ← MonadRecDepth.getMaxRecDepth, scopes := [{header := ""}, {header := ""}]}
  let mut pstate := {pos := 0, recovering := false}
  let mut exercises := #[]
  let mut solutions := #[]

  repeat
    let scope := cmdState.scopes.head!
    let pmctx := { env := cmdState.env, options := scope.opts, currNamespace := scope.currNamespace, openDecls := scope.openDecls }
    let (cmd, ps', messages) := Parser.parseCommand ictx pmctx pstate cmdState.messages
    pstate := ps'
    cmdState := {cmdState with messages := messages}

    -- dbg_trace "Unsliced is {cmd}"
    let slices : Slices ← DocElabM.withFileMap (FileMap.ofString altStr) (sliceSyntax cmd)
    let sol := slices.sliced.getD "solution" slices.residual
    solutions := solutions.push sol
    -- let ex := slices.sliced.getD "exercise" slices.residual
    -- exercises := exercises.push ex

    cmdState ← withInfoTreeContext (mkInfoTree := pure ∘ InfoTree.node (.ofCommandInfo {elaborator := `DemoTextbook.Exts.lean, stx := cmd})) do
      let mut cmdState := cmdState
      -- dbg_trace "Elaborating {ex}"
      -- match (← liftM <| EIO.toIO' <| (Command.elabCommand ex cctx).run cmdState) with
      -- | Except.error e => logError e.toMessageData
      -- | Except.ok ((), s) =>
      --   cmdState := {s with env := cmdState.env}

      -- dbg_trace "Elaborating {sol}"
      match (← liftM <| EIO.toIO' <| (Command.elabCommand sol cctx).run cmdState) with
      | Except.error e => logError e.toMessageData
      | Except.ok ((), s) =>
        cmdState := s

      pure cmdState

    if Parser.isTerminalCommand cmd then break

  setEnv cmdState.env
  for t in cmdState.infoState.trees do
    -- dbg_trace (← t.format)
    pushInfoTree t

  for msg in cmdState.messages.msgs do
    logMessage msg

  let mut hls := Highlighted.empty
  for cmd in exercises do
    hls := hls ++ (← highlight cmd cmdState.messages.msgs.toArray cmdState.infoState.trees)

  pure #[]


@[code_block_expander lean]
def lean : CodeBlockExpander
  | _, str => do
    let altStr ← parserInputString str
    processString altStr

def VersoProofFlow.Block.math : Block where
  name := `VersoProofFlow.Block.math
  id := "math"

@[directive_expander math]
def math : DirectiveExpander
  | #[], stxs => do
    let args ← stxs.mapM elabBlock
    let val ← ``(Block.other VersoProofFlow.Block.math #[ $[ $args ],* ])
    pure #[val]
  | _, _ => Lean.Elab.throwUnsupportedSyntax

def VersoProofFlow.Block.collapsible : Block where
  name := `VersoProofFlow.Block.collapsible
  id := "collapsible"

@[directive_expander collapsible]
def collapsible : DirectiveExpander
  | #[], stxs => do
    let args ← stxs.mapM elabBlock
    let val ← ``(Block.other VersoProofFlow.Block.collapsible #[ $[ $args ],* ])
    pure #[val]
  | _, _ => Lean.Elab.throwUnsupportedSyntax

def VersoProofFlow.Block.multilean : Block where
  name := `VersoProofFlow.Block.multilean
  id := "multilean"

def extractString (stxs : Array Syntax) : DocElabM (String) := do
  let mut code := ""
  let mut lastIdx := 0
  for stx in stxs do
    match stx with
    | `(block|``` $_nameStx:ident $_argsStx* | $contents:str ```) => do
      let preString := (← getFileMap).source.extract lastIdx (contents.raw.getPos?.getD 0)
      let mut iter := preString.iter
      while !iter.atEnd do
        if iter.curr == '\n' then
          code := code.push '\n'
        else
          for _ in [0:iter.curr.utf8Size] do
            code := code.push ' '
        iter := iter.next

      lastIdx := contents.raw.getTailPos?.getD lastIdx
      code := (code ++ contents.getString)
    | _ => pure ()
  pure code
    -- stxs.foldlM (fun str syn =>
    --   match syn with
    --   | `(block|``` $_nameStx:ident $_argsStx* | $contents:str ```) =>
    --     pure (str ++ contents.getString)
    --   | b => pure ""
  -- ) ""
@[directive_expander multilean]
def multilean : DirectiveExpander
  | #[], stxs => do
    let str ← extractString stxs
    let val ← processString str
    -- let args ← stxs.mapM elabBlock
    let val ← ``(Block.other VersoProofFlow.Block.multilean #[])
    pure #[val]
  | _, _ => Lean.Elab.throwUnsupportedSyntax

def VersoProofFlow.Block.input : Block where
  name := `VersoProofFlow.Block.input
  id := "input"

@[directive_expander input]
def input : DirectiveExpander
  | #[], stxs => do
    let args ← stxs.mapM elabBlock
    let val ← ``(Block.other VersoProofFlow.Block.input #[ $[ $args ],* ])
    pure #[val]
  | _, _ => Lean.Elab.throwUnsupportedSyntax

/-- Sections can have a type that is being parsed by the editor -/
structure VersoProofFlow.PartMetadata where
  type : String

def VersoProofFlow : Genre where
  -- No inline nor block
  Inline := Empty
  Block := Block
  -- We only have the part metadata
  PartMetadata := VersoProofFlow.PartMetadata
  -- No Traverse state or context
  TraverseContext := Unit
  TraverseState := Unit
