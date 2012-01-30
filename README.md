This is a client for 88pages.

## How To

    @query = EightyeightpagesClient::Query.new 'YOUR SITE HERE', 'localhost'

    @page = @query.pages.where(handle: 'home').first

## Querying

    # Ordering
    query.pages.order_by(title: 'asc')

    # Pagination
    query.pages.skip(2)

    query.pages.limit(2)

    # Any in
    query.pages.any_in(title: ['One', 'Two'])

## Contributing

Email carl@88pages.com to contribute.
