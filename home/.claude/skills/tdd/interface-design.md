# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```python
   # Testable - the test passes its own gateway
   def process_order(order: Order, gateway: PaymentGateway) -> Receipt: ...


   # Hard to test - the function constructs a real gateway internally
   def process_order(order: Order) -> Receipt:
       gateway = StripeGateway()
       ...
   ```

2. **Return results, don't produce side effects**

   ```python
   # Testable - pure function, assertable return value
   def calculate_discount(cart: Cart) -> Discount: ...


   # Hard to test - mutates input, return type lies about the work
   def apply_discount(cart: Cart) -> None:
       cart.total -= discount
   ```

3. **Small surface area**

   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup
   - One reason for the caller to learn the module = one reason for tests
     to change

4. **Prefer Protocols over inheritance for substitution points**

   ```python
   from typing import Protocol


   class PaymentGateway(Protocol):
       def charge(self, amount: Decimal) -> Receipt: ...


   # Tests pass any duck-typed implementation; no base class to inherit
   class FakeGateway:
       def charge(self, amount: Decimal) -> Receipt:
           return Receipt(amount=amount, status="confirmed")
   ```

   `Protocol` keeps the substitution surface narrow and avoids dragging
   tests into a class hierarchy they don't otherwise need.
