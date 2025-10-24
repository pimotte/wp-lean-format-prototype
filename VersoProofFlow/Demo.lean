import VersoProofFlow

set_option pp.rawOnError true

#doc (VersoProofFlow) "ProofFlow Demo!" =>

<hint title="Hint block">
# Hint block (using tags)
Placeholder text
```lean
-- Define five as 5
def five : Nat := 5

-- Define five as 5
def wrongfive : Nat := 6
```
</hint>

Note that the `<hint></hint>` tags do not have semantic meaning in Verso,
so it might be useful to use a directive instead.
Since nesting of directives is not supported, this disables multilean
inside of hints, but multilean is there mainly to split theorem statements
from input areas for exercises, this is not strictly needed.

:::collapsible
Hint block
# Hint block (using directive)
```lean
def five' : Nat := 5
```
:::

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
# Markdown ...

... in between multilean is possible from Verso perspective [link](http://example.com)

Inline lean here is not supported

These tags do not have a semantic meaning in verso.
Because nesting directives is currently not supported, we need to use another marker currently.

<input-area>
```lean
  have : True := by
    trivial
  rfl
```
</input-area>
:::
