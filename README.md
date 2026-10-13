# stripe

Crystal implementation of the Stripe API

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     stripe:
       github: jgaskins/stripe
   ```

2. Run `shards install`

## Usage

The `Stripe::Client` takes an API key argument or you can set the `STRIPE_API_KEY` environment variable.

```crystal
require "stripe"

# Pass the API key explicitly
stripe = Stripe::Client.new(api_key)

# ... or pull it from the `STRIPE_API_KEY` env var
stripe = Stripe::Client.new
```

To create a `PaymentIntent`:

```crystal
payment_intent = stripe.payment_intents.create(
  amount: 13_37, # $13.37
  currency: :usd,
  customer: user.stripe_customer_id,
  confirm: true,
)
```

See the [Stripe docs](https://docs.stripe.com/api/payment_intents/create) for details on what these options do.

### Idempotent requests

Any method that issues a `POST` request (`create`, `update`, `attach`, etc.) accepts an `idempotency_key` argument, which is sent as the `Idempotency-Key` header. Stripe will return the same result for retries of a request that uses the same key, so you can safely retry after a network failure without, for example, charging a customer twice.

```crystal
payment_intent = stripe.payment_intents.create(
  amount: 13_37,
  currency: :usd,
  customer: user.stripe_customer_id,
  confirm: true,
  idempotency_key: "order-#{order.id}",
)
```

See the [Stripe docs](https://docs.stripe.com/api/idempotent_requests) for details.

## Contributing

1. Fork it (<https://github.com/jgaskins/stripe/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer
