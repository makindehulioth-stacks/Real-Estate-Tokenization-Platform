(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-insufficient-balance (err u104))
(define-constant err-invalid-amount (err u105))
(define-constant err-property-not-active (err u106))
(define-constant err-sale-not-active (err u107))
(define-constant err-insufficient-tokens (err u108))
(define-constant err-transfer-failed (err u109))

(define-map properties
    { property-id: uint }
    {
        owner: principal,
        name: (string-ascii 100),
        location: (string-ascii 100),
        total-tokens: uint,
        price-per-token: uint,
        available-tokens: uint,
        is-active: bool,
        created-at: uint
    }
)

(define-map token-balances
    { property-id: uint, holder: principal }
    { balance: uint }
)

(define-map property-listings
    { listing-id: uint }
    {
        property-id: uint,
        seller: principal,
        tokens-for-sale: uint,
        price-per-token: uint,
        is-active: bool,
        created-at: uint
    }
)

(define-data-var property-nonce uint u0)
(define-data-var listing-nonce uint u0)

(define-read-only (get-property (property-id uint))
    (map-get? properties { property-id: property-id })
)

(define-read-only (get-token-balance (property-id uint) (holder principal))
    (default-to { balance: u0 }
        (map-get? token-balances { property-id: property-id, holder: holder })
    )
)

(define-read-only (get-listing (listing-id uint))
    (map-get? property-listings { listing-id: listing-id })
)

(define-read-only (get-property-nonce)
    (ok (var-get property-nonce))
)

(define-read-only (get-listing-nonce)
    (ok (var-get listing-nonce))
)

(define-public (create-property (name (string-ascii 100)) (location (string-ascii 100)) (total-tokens uint) (price-per-token uint))
    (let
        (
            (property-id (+ (var-get property-nonce) u1))
            (current-block stacks-block-height)
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> total-tokens u0) err-invalid-amount)
        (asserts! (> price-per-token u0) err-invalid-amount)
        (map-set properties
            { property-id: property-id }
            {
                owner: tx-sender,
                name: name,
                location: location,
                total-tokens: total-tokens,
                price-per-token: price-per-token,
                available-tokens: total-tokens,
                is-active: true,
                created-at: current-block
            }
        )
        (map-set token-balances
            { property-id: property-id, holder: tx-sender }
            { balance: total-tokens }
        )
        (var-set property-nonce property-id)
        (ok property-id)
    )
)

(define-public (purchase-tokens (property-id uint) (token-amount uint))
    (let
        (
            (property (unwrap! (map-get? properties { property-id: property-id }) err-not-found))
            (seller-balance (get balance (get-token-balance property-id (get owner property))))
            (buyer-balance (get balance (get-token-balance property-id tx-sender)))
            (total-cost (* token-amount (get price-per-token property)))
        )
        (asserts! (get is-active property) err-property-not-active)
        (asserts! (> token-amount u0) err-invalid-amount)
        (asserts! (>= (get available-tokens property) token-amount) err-insufficient-tokens)
        (try! (stx-transfer? total-cost tx-sender (get owner property)))
        (map-set token-balances
            { property-id: property-id, holder: (get owner property) }
            { balance: (- seller-balance token-amount) }
        )
        (map-set token-balances
            { property-id: property-id, holder: tx-sender }
            { balance: (+ buyer-balance token-amount) }
        )
        (map-set properties
            { property-id: property-id }
            (merge property { available-tokens: (- (get available-tokens property) token-amount) })
        )
        (ok true)
    )
)

(define-public (create-listing (property-id uint) (tokens-for-sale uint) (price-per-token uint))
    (let
        (
            (property (unwrap! (map-get? properties { property-id: property-id }) err-not-found))
            (seller-balance (get balance (get-token-balance property-id tx-sender)))
            (listing-id (+ (var-get listing-nonce) u1))
            (current-block stacks-block-height)
        )
        (asserts! (> tokens-for-sale u0) err-invalid-amount)
        (asserts! (> price-per-token u0) err-invalid-amount)
        (asserts! (>= seller-balance tokens-for-sale) err-insufficient-tokens)
        (map-set property-listings
            { listing-id: listing-id }
            {
                property-id: property-id,
                seller: tx-sender,
                tokens-for-sale: tokens-for-sale,
                price-per-token: price-per-token,
                is-active: true,
                created-at: current-block
            }
        )
        (var-set listing-nonce listing-id)
        (ok listing-id)
    )
)

(define-public (buy-from-listing (listing-id uint) (token-amount uint))
    (let
        (
            (listing (unwrap! (map-get? property-listings { listing-id: listing-id }) err-not-found))
            (property-id (get property-id listing))
            (seller (get seller listing))
            (seller-balance (get balance (get-token-balance property-id seller)))
            (buyer-balance (get balance (get-token-balance property-id tx-sender)))
            (total-cost (* token-amount (get price-per-token listing)))
        )
        (asserts! (get is-active listing) err-sale-not-active)
        (asserts! (> token-amount u0) err-invalid-amount)
        (asserts! (>= (get tokens-for-sale listing) token-amount) err-insufficient-tokens)
        (asserts! (>= seller-balance token-amount) err-insufficient-tokens)
        (try! (stx-transfer? total-cost tx-sender seller))
        (map-set token-balances
            { property-id: property-id, holder: seller }
            { balance: (- seller-balance token-amount) }
        )
        (map-set token-balances
            { property-id: property-id, holder: tx-sender }
            { balance: (+ buyer-balance token-amount) }
        )
        (if (is-eq token-amount (get tokens-for-sale listing))
            (map-set property-listings
                { listing-id: listing-id }
                (merge listing { is-active: false, tokens-for-sale: u0 })
            )
            (map-set property-listings
                { listing-id: listing-id }
                (merge listing { tokens-for-sale: (- (get tokens-for-sale listing) token-amount) })
            )
        )
        (ok true)
    )
)

(define-public (cancel-listing (listing-id uint))
    (let
        (
            (listing (unwrap! (map-get? property-listings { listing-id: listing-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender (get seller listing)) err-unauthorized)
        (asserts! (get is-active listing) err-sale-not-active)
        (map-set property-listings
            { listing-id: listing-id }
            (merge listing { is-active: false })
        )
        (ok true)
    )
)

(define-public (transfer-tokens (property-id uint) (recipient principal) (token-amount uint))
    (let
        (
            (sender-balance (get balance (get-token-balance property-id tx-sender)))
            (recipient-balance (get balance (get-token-balance property-id recipient)))
        )
        (asserts! (> token-amount u0) err-invalid-amount)
        (asserts! (>= sender-balance token-amount) err-insufficient-tokens)
        (map-set token-balances
            { property-id: property-id, holder: tx-sender }
            { balance: (- sender-balance token-amount) }
        )
        (map-set token-balances
            { property-id: property-id, holder: recipient }
            { balance: (+ recipient-balance token-amount) }
        )
        (ok true)
    )
)

(define-public (toggle-property-status (property-id uint))
    (let
        (
            (property (unwrap! (map-get? properties { property-id: property-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set properties
            { property-id: property-id }
            (merge property { is-active: (not (get is-active property)) })
        )
        (ok true)
    )
)

(define-public (update-property-price (property-id uint) (new-price uint))
    (let
        (
            (property (unwrap! (map-get? properties { property-id: property-id }) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> new-price u0) err-invalid-amount)
        (map-set properties
            { property-id: property-id }
            (merge property { price-per-token: new-price })
        )
        (ok true)
    )
)

