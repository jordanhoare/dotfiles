# Good and Bad Tests

## Good Tests

**Integration-style**: tests through real interfaces, not mocks of internal parts.

```python
# GOOD: tests observable behaviour
def test_user_can_checkout_with_valid_cart():
    cart = create_cart()
    cart.add(product)
    result = checkout(cart, payment_method)
    assert result.status == "confirmed"
```

Characteristics:

- Tests behaviour users / callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test (multiple `assert` lines are fine when
  they describe one outcome from different angles)

## Bad Tests

**Implementation-detail tests**: coupled to internal structure.

```python
# BAD: tests implementation details (mocks an internal collaborator
# and asserts on call shape rather than behaviour)
def test_checkout_calls_payment_service_process(mocker):
    mock_payment = mocker.patch("myapp.payment_service.process")
    checkout(cart, payment)
    mock_payment.assert_called_with(cart.total)
```

Red flags:

- Mocking internal collaborators (mock the boundary, not your own code)
- Testing private methods (test through the public interface)
- Asserting on call counts / order rather than observable outcome
- Test breaks when refactoring without behaviour change
- Test name describes HOW not WHAT
- Verifying through external means rather than the interface

```python
# BAD: bypasses the public interface to verify a side effect directly
def test_create_user_saves_to_database(db):
    create_user(name="Alice")
    row = db.execute("SELECT * FROM users WHERE name = :n", {"n": "Alice"}).fetchone()
    assert row is not None


# GOOD: verifies through the interface the application actually uses
def test_create_user_makes_user_retrievable():
    user = create_user(name="Alice")
    retrieved = get_user(user.id)
    assert retrieved.name == "Alice"
```

## Pytest conventions

- Use plain `assert` statements - pytest rewrites them with rich
  introspection. Avoid `unittest.TestCase.assertEqual` etc.
- Prefer `@pytest.fixture` for shared setup; prefer
  `@pytest.mark.parametrize` over repeated test functions when one logical
  test exercises many cases.
- Name tests `test_<unit>_<scenario>_<expected>` so the failure line in CI
  reads as a sentence: `test_compile_source_raises_compile_error_on_syntax_failure`.
- Always include a docstring stating the behaviour under test - it doubles
  as the specification when reviewing failures.
