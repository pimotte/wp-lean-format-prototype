import Lake
open Lake DSL

require verso from git "https://github.com/leanprover/verso.git"@"v4.20.0"
require verbose from git "https://github.com/PatrickMassot/verbose-lean4.git"
  @ "v4.20.0"

package VersoProofFlow where
  -- add package configuration options here

lean_lib VersoProofFlow where
  srcDir := "."
  roots := #[`VersoProofFlow]

lean_exe versoproofflow where
  srcDir := "."
  root := `VersoProofFlowMain
