import VersoProofFlow

set_option pp.rawOnError true

#doc (VersoProofFlow) "ProofFlow Demo!" =>

<hint title="Hint block">
#Collapsible block for imports
Placeholder text
```lean
-- Define five as 5
def five : Nat := 5

-- Define five as 5
def wrongfive : Nat := 6
```
</hint>

# Correct Proof
.

```lean
-- Prove that five equals 5
theorem five_eq_5 : five = 5 := by
  have : True := by
    trivial

  rfl
```

# Exercise with reference solution
:::multilean
```lean
-- Prove that five equals 5
theorem five_eq_5' : five = 5 := by
```
<input-area>
```lean
  have : True := by
    trivial
  rfl
```
</input-area>
:::
