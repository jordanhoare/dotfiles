# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB or fixtures)
- Time and randomness
- File system (sometimes)

Don't mock:

- Your own classes / modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock or substitute:

**1. Use dependency injection**

Pass external dependencies in rather than constructing them internally:

```python
# Easy to substitute in tests
def process_payment(order: Order, payment_client: PaymentClient) -> Receipt:
    return payment_client.charge(order.total)


# Hard to substitute - the function reaches out to env and constructs its own client
def process_payment(order: Order) -> Receipt:
    client = StripeClient(os.environ["STRIPE_KEY"])
    return client.charge(order.total)
```

In tests, pass a fake implementation directly:

```python
class FakePaymentClient:
    def charge(self, amount: Decimal) -> Receipt:
        return Receipt(amount=amount, status="confirmed")


def test_process_payment_returns_confirmed_receipt():
    receipt = process_payment(Order(total=Decimal("10")), FakePaymentClient())
    assert receipt.status == "confirmed"
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic
function with conditional logic:

```python
# GOOD: each method is independently substitutable
class API(Protocol):
    def get_user(self, user_id: str) -> User: ...
    def get_orders(self, user_id: str) -> list[Order]: ...
    def create_order(self, data: OrderData) -> Order: ...


# BAD: substituting requires conditional logic inside the fake
class API(Protocol):
    def fetch(self, endpoint: str, **options: Any) -> Any: ...
```

The SDK approach means:

- Each fake method returns one specific shape - no isinstance checks
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint via `Protocol` + a concrete fake

**3. Prefer fakes over `unittest.mock` for collaborators you own**

`pytest-mock` and `unittest.mock` are fine for stubbing third-party calls at
the boundary. For your own collaborators, a hand-rolled fake (a small class
with the same Protocol) usually beats `MagicMock` - it's typed, refactor-safe,
and reads as a real implementation. Reach for `MagicMock` only when the
collaborator is genuinely external or test setup would be repetitive.
