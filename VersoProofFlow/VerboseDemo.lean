import VersoProofFlow
import Verbose.English.ExampleLib



#doc (VersoProofFlow) "ProofFlow Demo!" =>


# Example with explantion

```lean
Example "Constant sequences converge."
  Given: (u : ℕ → ℝ) (l : ℝ)
  Assume: (h : ∀ n, u n = l)
  Conclusion: u converges to l
Proof:
  Fix ε > 0
  Let's prove that ∃ N, ∀ n ≥ N, |u n - l| ≤ ε
  Let's prove that 0 works
  Fix n ≥ 0
  Calc |u n - l| = |l - l| from h
   _             = 0       by computation
   _             ≤ ε       from ε_pos
QED
```

# Exercise with reference solution

:::multilean
```lean
Exercise "Continuity implies sequential continuity"
  Given: (f : ℝ → ℝ) (u : ℕ → ℝ) (x₀ : ℝ)
  Assume: (hu : u converges to x₀) (hf : f is continuous at x₀)
  Conclusion: (f ∘ u) converges to f x₀
Proof:
```
<input-area>
```lean
  Let's prove that ∀ ε > 0, ∃ N, ∀ n ≥ N, |f (u n) - f x₀| ≤ ε
  Fix ε > 0
  By hf applied to ε using that ε > 0 we get δ such that
    (δ_pos : δ > 0) and (Hf : ∀ x, |x - x₀| ≤ δ ⇒ |f x - f x₀| ≤ ε)
  By hu applied to δ using that δ > 0 we get N such that Hu : ∀ n ≥ N, |u n - x₀| ≤ δ
  Let's prove that N works : ∀ n ≥ N, |f (u n) - f x₀| ≤ ε
  Fix n ≥ N
  By Hf applied to u n it suffices to prove |u n - x₀| ≤ δ
  We conclude by Hu applied to n using that n ≥ N
```
<input-area>
```lean
QED
```
:::

# Exercise without solution

:::multilean
```lean
Example "A sequence converging to a positive limit is ultimately positive."
  Given: (u : ℕ → ℝ) (l : ℝ)
  Assume: (hl : l > 0) (h : u converges to l)
  Conclusion: ∃ N, ∀ n ≥ N, u n ≥ l/2
Proof:
```
<input-area>
```lean
```
<input-area>
```lean
QED
```
:::
